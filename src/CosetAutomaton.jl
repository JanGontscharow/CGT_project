struct CosetAutomaton{S<:State} <: Automaton
	input_size::Int
	states::Vector{S}
    partition::Dict{S, S}
    ω::State # fail state
end

function CosetAutomaton(n::Int)
    S = State{UInt32, UInt32}
    α = S(2*n)
    ω = S(2*n, fail=true)
    CosetAutomaton{S}(2*n,[α], Dict(), ω)
end

function CosetAutomaton(states::Vector{State{UInt32, UInt32}}, n::Int)
    ω = S(2*n, fail=true)
    CosetAutomaton{State{UInt32, UInt32}}(n, states, Dict(), ω)
end


states(ca::CosetAutomaton) = ca.states
initial(ca::CosetAutomaton) = first(states(ca))
fail(ca::CosetAutomaton) = ca.ω
input_size(ca::CosetAutomaton) = ca.input_size

# Conversion between index space and letter space
letter_to_index(ca::CosetAutomaton, l::Int) = letter_to_index(l, input_size(ca))
word_to_idxvec(ca::CosetAutomaton, w::AbstractVector) = map(l -> letter_to_index(ca, l), w)
index_to_letter(ca::CosetAutomaton, idx::Int) = index_to_letter(idx, input_size(ca))
function index_to_letter(idx::Int, n::Int)
    l = idx > div(n,2) ? -(idx-div(n,2)) : idx
    return MyWord(l)
end


function hasedge(ca::CosetAutomaton, σ::State, label::Integer)
    return !isnothing(σ[label]) && σ[label]!=fail(ca)
end
trace(ca::CosetAutomaton, label::Integer, σ=initial(ca)) = σ[label]

function trace(ca::CosetAutomaton, w::AbstractVector, σ::State=initial(ca); info=false)
    info && @info "tracing $(findfirst(s->s==σ, states(ca))) with $w"
    w = word_to_idxvec(ca, w)
    for (i, l) in enumerate(w)
        if hasedge(ca, σ, l)
            σ = trace(ca, l, σ)
            info && @info "$(index_to_letter(ca, l)) → $(findfirst(s->s==σ, states(ca)))"
            @assert !isnothing(σ)
        else
            return (i-1, σ)
        end
       
	end
	return length(w), σ
end

partition(ca::CosetAutomaton) = ca.partition
function union!(ca::CosetAutomaton, σ::State, τ::State)
    find(ca, σ) == find(ca, τ) && return # alredy unioned
    # Let initial state of ca always be a representative so it does not get factored out
    σ == initial(ca) ?  (ca.partition[τ] = σ) : (ca.partition[σ] = τ)
end

function find(ca::CosetAutomaton, σ::State)
    σ == partition(ca)[σ] && return σ
    return find(ca, partition(ca)[σ])
end


function unsafe_add_state!(ca::CosetAutomaton{S}) where S
	σ = S(input_size(ca))
	push!(ca.states, σ)
	return σ
end

# Also adds backward edge
function unsafe_add_edge!(ca::CosetAutomaton, σ::State, label, τ::State; info=false)
    lab_index = letter_to_index(ca, label)
    lab_inv_index = letter_to_index(ca, -label)

    info && @info "add edge $(findfirst(s->s==σ, states(ca))) $(index_to_letter(ca, lab_index)) $(findfirst(s->s==τ, states(ca)))"
    info && @info "add edge $(findfirst(s->s==τ, states(ca))) $(index_to_letter(ca, lab_inv_index)) $(findfirst(s->s==σ, states(ca)))"

    σ[lab_index] = τ
    τ[lab_inv_index] = σ
    @assert σ[lab_index] == τ && τ[lab_inv_index] == σ

	return ca	
end

function define!(ca::CosetAutomaton, σ::State, label; info=false)
    τ = unsafe_add_state!(ca)
    @assert !isnothing(τ)
    unsafe_add_edge!(ca, σ, label, τ, info=info)
    return τ
end

function join!(ca::CosetAutomaton, σ::State, label, τ::State; info=false)
    info && @info "JOIN $σ and $τ"
    lab_index = letter_to_index(ca, label)
    lab_inv_index = letter_to_index(ca, -label)
    @assert !hasedge(ca, σ, lab_index) "σ has already an edge with the label $lab_index"
    @assert !hasedge(ca, τ, lab_inv_index) "τ has already an edge with the label $lab_inv_index"
    unsafe_add_edge!(ca, σ, lab_index, τ, info=info)
end

function unsafe_remove!(ca::CosetAutomaton, σ::State, label, τ::State)
    lab_index = letter_to_index(ca, label)
    lab_inv_index = letter_to_index(ca, -label)

    # assign fail state
    σ[lab_index] = fail(ca)
    τ[lab_inv_index] = fail(ca)
end

function visualize_partition(ca::CosetAutomaton)
    parts = Dict()
    for σ in states(ca)
        haskey(parts, find(ca, σ)) ? push!(parts[find(ca, σ)], σ) : parts[find(ca, σ)] = [σ]
    end
    
    for (i, (τ, σs)) in enumerate(parts)
        println("Class $i (rep: $(findfirst(s -> s == τ, ca.states)))")
        for σ in σs
            println("\t- $(findfirst(s -> s == σ, ca.states))")
        end
    end
end



function coincidence!(ca::CosetAutomaton, σ₁::State, σ₂::State; info=false)

    info && @info "COIN"
    info && @info "identifing σ₁:$(findfirst(s -> s == σ₁, ca.states)), σ₂:$(findfirst(s -> s == σ₂, ca.states))"

    # initialize classes
    for state in states(ca)
        ca.partition[state] = state 
    end

    # identify σ₁ and σ₂
    union!(ca, σ₁, σ₂)
    
    # complete equivalence relation
    changed = true
    while changed
        changed = false
        for σ ∈ states(ca), τ ∈ states(ca)
            find(ca, σ) == find(ca, τ) || continue
            for l in 1:input_size(ca)
                hasedge(ca, σ, l) || continue
                hasedge(ca, τ, l) || continue
                find(ca, σ[l]) == find(ca, τ[l]) && continue
                union!(ca, σ[l], τ[l])
                changed=true
            end
        end
    end

    info && visualize_partition(ca)
    #info && adjacency_matrix(ca)

    # pop and store transitions with positive letters
    transitions = []
    for σ ∈ states(ca)
        for i in 1:div(input_size(ca), 2)
            if  hasedge(ca, σ, i)
                #info && @info "pop $(findfirst(s -> s == σ, ca.states)) $(MyWord(i)) $(findfirst(s -> s == σ[i], ca.states))"
                push!(transitions, (σ, i , σ[i]))
                unsafe_remove!(ca, σ, i, σ[i])
            end
        end
    end
    
    # apply trasitions to thier representatives
    for (σ, i, τ) in transitions
        !hasedge(ca, find(ca, σ), i) && (join!(ca, find(ca, σ), i, find(ca, τ)); continue)
        @assert find(ca, σ)[i] == find(ca, τ)
    end

    # remove non-representatives
    filter!(s -> s == find(ca, s), states(ca))

    !is_connected(ca) && adjacency_matrix(ca)
    #@assert is_connected(ca) "f"
    # check whether the are single states
    @assert all([ any([hasedge(ca, σ, i) for i in 1:input_size(ca)]) for σ ∈ states(ca)])
end



function trace_and_reverse!(ca::CosetAutomaton, w::MyWord, σ::State=initial(ca); info=false)
    info && @info "TRACE AND REVERSE with $w ($(inv(w))) at state $(findfirst(s->s==σ, states(ca))), #states:$(length(states(ca)))"
    temp = (w == word"ab^2a^2b^2ab^2a^-1b^-2a^-2b^-2a^-1b^-2") && (findfirst(s->s==σ, states(ca)) == 2)

    len, τ = trace(ca, w, σ, info=info)
    len_rev, τ_rev = trace(ca, inv(MyWord(w[len+1:end])), σ, info=info)
    
    info && @info "initial: states |$(findfirst(s->s==τ, states(ca)))|$(findfirst(s->s==τ, states(ca)))| lengths |$len|$len_rev|"
    while (len + len_rev <= length(w)) || (τ != τ_rev)
        # t == ε
        (len + len_rev == length(w)) && (coincidence!(ca, τ, τ_rev, info=info); break)
        # |t| == 1
        (len + len_rev == length(w)-1) && (join!(ca, τ, w[len+1], τ_rev, info=info); break) 
        # |t| > 1
 
        define!(ca, τ, w[len+1], info=info)
        if τ!=τ_rev || (w[len+1] != inv(MyWord(w[len+1:end]))[len_rev+1]) 
            define!(ca, τ_rev, inv(MyWord(w[len+1:end]))[len_rev+1], info=info)
        end

        len, τ = trace(ca, w, σ, info=info)
        len_rev, τ_rev = trace(ca, inv(MyWord(w[len+1:end])), σ, info=info)

        temp && adjacency_matrix(ca)
    
        info && @info "|$len:$(MyWord(w[len]))|$len_rev:$(MyWord(inv(MyWord(w[len+1:end]))[len_rev]))|"
    end    
    info && adjacency_matrix(ca)
    return ca
end





function coset_enumeration(U::Vector{MyWord}, V::Vector{MyWord}, deg::Int; info=false)
    ca = CosetAutomaton(deg)
    
	for u ∈ U
        info && @info "tracing $u" 
		w = free_rewrite(u)  # we're freely reducing u here
		trace_and_reverse!(ca, w, info=info)

        info && adjacency_matrix(ca)
	end


    for (i,σ) ∈ enumerate(states(ca))
        for v ∈ V
            trace_and_reverse!(ca, v, σ, info=info)
            info && adjacency_matrix(ca)
            find(ca, σ) == σ || break # break if state was factored out
        end 
        #info && visualize_partition(ca)
        if find(ca, σ) == σ
            info && @info "add trns to state $i"
            # add missing transitions
            for i in 1:input_size(ca)
                if !hasedge(ca, σ, i)
                    info && @info "add transition $i $(index_to_letter(ca, i))" 
                    define!(ca, σ, i, info=info)
                else
                    #info && @info "$σ $(index_to_letter(ca, i)) $(σ[i])"
                end
            end
        end
        info && @info "Automaton after tracing state $i"
        info && adjacency_matrix(ca)
    end
	return ca
end






function is_connected(ca::CosetAutomaton)

    n = length(ca.states)
    m = input_size(ca)
    adj_matrix = zeros(Bool, n, n)

    for i in 1:n, l in 1:div(m,2)
        if hasedge(ca, ca.states[i], l)
            τ = ca.states[i][l]
            j = findfirst(x -> x==τ, states(ca))
            
            adj_matrix[i,j] = true
            #adj_matrix[j,i] = true
        end
    end

    n = size(adj_matrix, 1)
    visited = falses(n)
    
    function dfs(v)
        visited[v] = true
        for u in findall(adj_matrix[v, :])
            !visited[u] && dfs(u)
        end
    end
    
    dfs(1)
    all(visited)
end

