S = State{UInt32, UInt32}

function coset_representatives(ca::CosetAutomaton)
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
        σ = pop!(queue)
        for i in 1:n
            if hasedge(ca, σ, i) 
                τ = trace(ca, i, σ)
                s = index_to_letter(ca, i)
                visited[τ] || (visited[τ]=true; rep[τ] = rep[σ]*s; push!(queue, τ))
            end 
        end
    end

    return rep
end

function schreier_generators(ca::CosetAutomaton, rep)
    deg = div(input_size(ca), 2)
    schreier = Dict{Tuple{State, Int}, MyWord}()
    for σ ∈ states(ca)
        for i in 1:deg
            s = MyWord(i)
            c = rep[σ]
            rep_sc = rep[trace(ca, s*c)[2]]
            value = s * c * inv(rep_sc)
            #@info "$i| $s ⋅ $c ⋅ $(inv(rep_sc)) == $(free_rewrite(value))"
            schreier[(σ, i)] = free_rewrite(value)
        end
    end
    return schreier
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

function reidemeister_relators(ca::CosetAutomaton, sch::Dict{Tuple{State, Int}, MyWord}, rep::Dict{State, MyWord}, V::Vector{MyWord})
    reidemeister_relator = Dict{Tuple{State, MyWord}, MyWord}()
    for σ ∈ states(ca)
        for v ∈ V
            value = rep[σ] * v * inv(rep[σ])
            value = free_rewrite(value)
            #@info "$(rep[σ]) ⋅ $v ⋅ $(inv(rep[σ])) = $value"
            reidemeister_relator[(σ, v)] = reidemeister_rewrite(ca, sch, value)
        end
    end
    return reidemeister_relator
end


function reidemeister_schreier(Π::Presentation, U::Vector{MyWord})
    V = rel(Π)
    ca = coset_enumeration(V, U)
    rep = coset_representatives(ca)
    sch = schreier_generators(ca, rep)
    reide_rel = reidemeister_relators(ca, sch, rep, V)
    rel = values(reide_rel)
    return Presentation(rel)
end