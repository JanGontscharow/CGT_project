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

function trace(ca::CosetAutomaton, w::AbstractVector, σ::State=initial(ca))
    w = word_to_idxvec(ca, w)
    for (i, l) in enumerate(w)
        if hasedge(ca, σ, l)
            σ = trace(ca, l, σ)
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

function unsafe_add_edge!(ca::CosetAutomaton, σ::State, label, τ::State)
    lab_index = letter_to_index(ca, label)
    lab_inv_index = letter_to_index(ca, -label)
    σ[lab_index] = τ
    τ[lab_inv_index] = σ
	return ca	
end

function unsafe_remove!(ca::CosetAutomaton, σ::State, label, τ::State)
    lab_index = letter_to_index(ca, label)
    lab_inv_index = letter_to_index(ca, -label)
    # assign fail state
    σ[lab_index] = fail(ca)
    τ[lab_inv_index] = fail(ca)
end

function define!(ca::CosetAutomaton, σ::State, label)
    τ = unsafe_add_state!(ca)
    @assert !isnothing(τ)
    unsafe_add_edge!(ca, σ, label, τ,)
    return τ
end

function join!(ca::CosetAutomaton, σ::State, label, τ::State)
    lab_index = letter_to_index(ca, label)
    lab_inv_index = letter_to_index(ca, -label)
    @assert !hasedge(ca, σ, lab_index) "σ has already an edge with the label $lab_index"
    @assert !hasedge(ca, τ, lab_inv_index) "τ has already an edge with the label $lab_inv_index"
    unsafe_add_edge!(ca, σ, lab_index, τ)
end

function coincidence!(ca::CosetAutomaton, σ₁::State, σ₂::State)
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
    # pop and store transitions with positive letters
    transitions = []
    for σ ∈ states(ca)
        for i in 1:div(input_size(ca), 2)
            if  hasedge(ca, σ, i)
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
end


function trace_and_reverse!(ca::CosetAutomaton, w::MyWord, σ::State=initial(ca))
    len, τ = trace(ca, w, σ)
    len_rev, τ_rev = trace(ca, inv(MyWord(w[len+1:end])), σ)

    while (len + len_rev <= length(w)) || (τ != τ_rev)
        # t == ε
        (len + len_rev == length(w)) && (coincidence!(ca, τ, τ_rev); break)
        # |t| == 1
        (len + len_rev == length(w)-1) && (join!(ca, τ, w[len+1], τ_rev); break) 
        # |t| > 1
        define!(ca, τ, w[len+1])
        # if both traces end in the same state and need the same transition then we want only one extra edge 
        if τ!=τ_rev || (w[len+1] != inv(MyWord(w[len+1:end]))[len_rev+1])
            define!(ca, τ_rev, inv(MyWord(w[len+1:end]))[len_rev+1])
        end

        len, τ = trace(ca, w, σ)
        len_rev, τ_rev = trace(ca, inv(MyWord(w[len+1:end])), σ)
    end    
    return ca
end


function coset_enumeration(U::Vector{MyWord}, V::Vector{MyWord}, deg::Int)
    ca = CosetAutomaton(deg)
	for u ∈ U
		w = free_rewrite(u)  # we're freely reducing u here
		trace_and_reverse!(ca, w)
	end
    for (i,σ) ∈ enumerate(states(ca))
        for v ∈ V
            trace_and_reverse!(ca, v, σ)
            find(ca, σ) == σ || break # break if state was factored out
        end 
        if find(ca, σ) == σ
            # add missing transitions
            for i in 1:input_size(ca)
                !hasedge(ca, σ, i) && define!(ca, σ, i)
            end
        end
    end
	return ca
end
