S = State{UInt32, UInt32}

function coset_representatives(ca::CosetAutomaton; info=false)
    n = input_size(ca)
    α = initial(ca)
    rep = Dict{State, MyWord}()
    visited = Dict()
    for σ ∈ states(ca)
        visited[σ] = false
    end
    visited[α] = true
    queue = [α]
    rep[α] = word""
    
    while !isempty(queue)
        info && @info "$(length(queue))"
        σ = pop!(queue)
        for i in 1:n
            if hasedge(ca, σ, i) 
                τ = trace(ca, i, σ)
                s = index_to_letter(ca, i)
                visited[τ] || (visited[τ]=true; rep[τ] = rep[σ]*s; push!(queue, τ))
            end 
        end
    end

    @assert is_connected(ca)
    @assert all([σ ∈ keys(rep) for σ ∈ states(ca)]) "not all states reached $(adjacency_matrix(ca))"

    return rep
end


function adjacency_matrix(ca::CosetAutomaton; info=false)
    n = length(ca.states)
    m = input_size(ca)
    adj = zeros(Bool, n, n)
    for i in 1:n
        for l in 1:m
            
            info && @info "$i $(index_to_letter(ca, l)) edge?"

            if hasedge(ca, ca.states[i], l)
                τ = ca.states[i][l]
                j = findfirst(x -> x==τ, states(ca))
                @assert !isnothing(τ)
                @assert !isnothing(j)
                info && @info "found $i $(index_to_letter(ca, l)) $j"
                
                adj[i,j] = true
            end
        end
    end

    
    print("    ")
    for i in 1:n
        print(lpad(string(i),3))
    end
    println()

    # Print matrix rows
    for i in 1:n
        print(lpad(string(i),3), " ")
        for j in 1:n
            if adj[i, j]
                print("  1")
            else
                print("   ")
            end
        end
        println()
       
    end 
    println()
    
    @assert all([adj[i,j] == adj[j,i] for i in 1:n, j in 1:n]) "no longer symmetric"

end


function schreier_generators(ca::CosetAutomaton, rep; info=false)
    deg = div(input_size(ca), 2)
    sch_dict = Dict{Tuple{State, Int}, MyWord}()
    for σ ∈ states(ca), i in 1:deg
        s = MyWord(i)
        c = rep[σ]
        rep_cs = rep[trace(ca, c*s)[2]]
        value = c * s * inv(rep_cs)
        info && @info "$i| $s ⋅ $c ⋅ $(inv(rep_cs)) == $(free_rewrite(value))"
        sch_dict[(σ, i)] = free_rewrite(value)
    end
    return sch_dict
end

function reidemeister_rewrite(ca, sch::Dict{Tuple{State, Int}, MyWord}, w::MyWord)
    v = word""
    for (i,l) in enumerate(w) 
        #@info "     $(MyWord(l)) trace(w[1:$(l<0 ? i : i-1)]) = trace($(MyWord(w[ (l<0 ? (1:i) : (1:i-1)) ]))) $(l<0 ? trace(ca, w[1:i])[1] : trace(ca, w[1:i-1])[1])"
        σ = l<0 ? trace(ca, MyWord(w[1:i]))[2] : trace(ca, MyWord(w[1:i-1]))[2]
        v *= l<0 ? inv(sch[(σ, -l)]) : sch[(σ, l)]
        #@info "     $v"
    end
    return v
end

function reidemeister_relators(ca::CosetAutomaton, sch_dict::Dict{Tuple{State, Int}, MyWord}, rep::Dict{State, MyWord}, V::Vector{MyWord}; info=false)
    reidemeister_relator = Dict{Tuple{State, MyWord}, MyWord}()
    # get the schreier elements
    schreier = unique(values(sch_dict))
    filter!(x->!isone(x), schreier)
    # map them onto generators
    sch_gen = Dict{MyWord, MyWord}(s => MyWord(i) for (i,s) ∈ enumerate(schreier))
    sch_gen[word""] = word""
    sch = Dict{Tuple{State, Int}, MyWord}(key => sch_gen[sch_dict[key]] for key in keys(sch_dict))
    
    info && @info "$sch_gen"
    info && @info "$sch"

    relators = MyWord[]
    for σ ∈ states(ca), v ∈ V
        value = rep[σ] * v * inv(rep[σ])
        value = free_rewrite(value)
        push!(relators, reidemeister_rewrite(ca, sch, value))

        info && @info "$(rep[σ]) ⋅ $v ⋅ $(inv(rep[σ])) = $value"
        info && @info "→ $(reidemeister_rewrite(ca, sch, value))"
    end
    return relators
end


function reidemeister_schreier(Π::Presentation, U::Vector{MyWord}; info=false)
    V = rel(Π)
    ca = coset_enumeration(U, V, deg(Π), info=info)
    info && adjacency_matrix(ca)

    rep = coset_representatives(ca)
    info && @info "$(values(rep))"

    sch = schreier_generators(ca, rep)
    info && @info "$(values(sch))"

    reide_rel = reidemeister_relators(ca, sch, rep, V)
    info && @info "$reide_rel"

    relations = collect(values(reide_rel))
    return Presentation(relations)
end