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


function hasedge(ca ::CosetAutomaton, σ::State, label::Integer)
    return hasedge(σ, label) && !isfail(trace(ca, label, σ))
end
trace(ca::CosetAutomaton, label::Integer, σ=initial(ca)) = σ[label]
function trace(ca::CosetAutomaton, w::AbstractVector, σ::State=initial(ca))
    w = word_to_idxvec(ca, w)
    for (i, l) in enumerate(w)
		hasedge(ca, σ, l) ? σ = trace(ca, l, σ) : (return i-1, σ)
	end
	return length(w), σ
end

partition(ca::CosetAutomaton) = ca.partition
function union!(ca::CosetAutomaton, σ::State, τ::State)
    (find(ca, σ) != find(ca, τ)) && (ca.partition[σ] = τ)
end
function find(ca::CosetAutomaton, σ::State)
    #@info "$(partition(ca))"
    σ == partition(ca)[σ] ? (return σ) : return find(ca, partition(ca)[σ])
end


function unsafe_add_state!(ca::CosetAutomaton{S}) where S
	σ = S(input_size(ca))
	push!(ca.states, σ)
	return σ
end

# Also adds backward edge
function unsafe_add_edge!(ca::CosetAutomaton, σ::State, label, τ::State)
    lab_index = letter_to_index(ca, label)
    lab_inv_index = letter_to_index(ca, -label)

    σ[lab_index] = τ
	if σ ≠ τ || lab_index ≠ lab_inv_index
		τ[lab_inv_index] = σ
	end
	return ca	
end

function define!(ca::CosetAutomaton, σ::State, label)
    τ = unsafe_add_state!(ca)
    unsafe_add_edge!(ca, σ, label, τ)
    return τ
end

function join!(ca::CosetAutomaton, σ::State, label, τ::State)
    lab_index = letter_to_index(ca, label)
    @assert !hasedge(ca, σ, lab_index) "σ has already an edge with the label $lab_index"
    # second assertion should be redudant given the definition of unsafe_add_edge!
    #@assert !hasedge(ca, τ, inv_label) "σ has already an edge with the label label"
    unsafe_add_edge!(ca, σ, lab_index, τ)
end

function unsafe_remove!(ca::CosetAutomaton, σ::State, label, τ::State)
    lab_index = letter_to_index(ca, label)
    lab_inv_index = letter_to_index(ca, -label)

    # assign fail state
    σ[lab_index] = fail(ca)
    τ[lab_inv_index] = fail(ca)
end

function coincidence!(ca::CosetAutomaton, σ₁::State, σ₂::State)
    # initialize classes
    for state in states(ca)
        #@info "initilizing $state"
        ca.partition[state] = state 
    end

    # identify σ and τ
    union!(ca, σ₁, σ₂)

    # complete equivalence relation
    for l in 1:input_size(ca)
        hasedge(ca, σ₁, l) && hasedge(ca, σ₂, l) && union!(ca, trace(ca, l, σ₁), trace(ca, l, σ₂))
    end

    for σ in states(ca)
        for l in 1:input_size(ca)
            if hasedge(ca, σ, l)
                τ = trace(ca, l, σ)
                # move edges according to partition
                unsafe_remove!(ca, σ, l, τ)
                join!(ca, find(ca, σ), l, find(ca, τ))
            end 
        end
    end

    # remove non-representatives
    nonrep = filter(s -> s != find(ca, s), states(ca))
    filter!(s -> s ∉ nonrep, ca.states)

    #delete!(ca.partition, nonrep)
end

function trace_and_reverse!(ca::CosetAutomaton, w::MyWord; σ::State=initial(ca))
    
    len, τ = trace(ca, w, σ)
    len_rev, τ_rev = trace(ca, inv(w), σ)
    #@info "TRACE AND REVERSE with $w and |$len|$len_rev|, states:$(length(states(ca)))"
    while (len + len_rev <= length(w)) || (τ != τ_rev)
        # t == ε
        (len + len_rev == length(w)) && (coincidence!(ca, τ, τ_rev); return ca)
        # |t| == 1
        (len + len_rev == length(w)-1) && (join!(ca, τ, w[len+1], τ_rev); return ca) 
        # |t| > 1
 
        define!(ca, τ, w[len+1])
        len, τ = trace(ca, w, σ)
        define!(ca, τ_rev, inv(w)[len_rev+1])
        len_rev, τ_rev = trace(ca, inv(w), σ)
        #@info "|$len:$(MyWord(w[len]))|$len_rev:$(MyWord(inv(w)[len_rev]))|"
    end    
end

function coset_enumeration(U::Vector{MyWord}, V::Vector{MyWord})
	deg = maximum(map(degree, U))
    ca = CosetAutomaton(deg)
	for u in U
		w = free_rewrite!(one(u), u)  # we're freely reducing u here
		trace_and_reverse!(ca, w)
	end

    for σ ∈ states(ca)
        for v ∈ V
            trace_and_reverse!(ca, v, σ = σ)
            find(ca, σ) == σ || break
        end 
        if find(ca, σ) == σ
            for i in 1:deg
                hasedge(ca, σ, i) || define!(ca, σ, i)
            end
        end
    end

	return ca
end


