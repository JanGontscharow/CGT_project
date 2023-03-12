mutable struct State{T, S}
    transitions::Vector{State{T,S}} # vector of fixed size
	fail::Bool
    data::T
    value::S

	function State{T, S}(n::Integer; fail::Bool=false) where {T, S}
        new{T,S}(Vector{State{T,S}}(undef, n), fail)
    end
    function State{T, S}(n::Integer, data; fail::Bool=false) where {T, S}
        new{T,S}(Vector{State{T,S}}(undef, n), fail, data)
    end
end

isterminal(s::State) = isdefined(s, :value)
isfail(s::State) = s.fail

	# σ[i]
function Base.getindex(s::State, i::Integer)
	isfail(s) && return s # return nothing
	!isassigned(s.transitions, i) && return nothing
	return s.transitions[i]
end
	# σ[i] = τ
Base.setindex!(s::State, v::State, i::Integer) = s.transitions[i] = v

hasedge(s::State, i::Integer) = !isnothing(s[i])
	
function value(s::State)
    isterminal(s) && return s.value
	throw("state is not terminal and its value is not assigned")
end

max_degree(s::State) = length(s.transitions)

	# outdegree?
degree(s::State) = count(i->hasedge(s, i), 1:max_degree(s))
# transitions(s::State) = (s[i] for i in 1:max_degree(s) if hasedge(s, i))
	
function Base.show(io::IO, s::State)
	if isterminal(s)
		print(io, "terminal state: ", value(s))
	else
		print(io, "state (data=", s.data, ") with ", degree(s), " transitions")
	end
end




abstract type Automaton end


struct IndexAutomaton{T,S} <: Automaton
	input_size::Int
    initial::State{T,S}
end

"""
	`n` input size of Automaton.
	converts a letters from (-n/2):(n/2) to indices in 1:n.
	This is done by mapping (-n/2):-1 to (n/2)+1:n via
		l ↦ abs(l) + n/2 
	We also need to treat -n:-(n/2) since we might try to 
	convert the inverse of `m` but `m` is already an index
	of a letter `l` in (-n/2):-1. Which means
		letter_to_index(-m)
		 == letter_to_index(-letter_to_index(l))
	In this case we want to Return
		letter_to_index(-l) 
		 == -l
		 == m-n/2
"""
function letter_to_index(m::Int, n::Int)
	-m > (n/2) && (return -m-div(n, 2)) # special case described above
	m < 0 ? (return (-m + div(n, 2))) : return m
end
letter_to_index(idxA::IndexAutomaton, l::Int) = letter_to_index(l, input_size(idxA))
word_to_idxvec(idxA::IndexAutomaton, w::MyWord) = map(l -> letter_to_index(idxA, l), w)

initial(idxA::IndexAutomaton) = idxA.initial
input_size(idxA::IndexAutomaton) = idxA.input_size

hasedge(::IndexAutomaton, σ::State, label::Integer) = hasedge(σ, label)
trace(::IndexAutomaton, label::Integer, σ::State) = σ[label]
trace(idxA::IndexAutomaton, w::MyWord, σ::State) = trace(idxA, word_to_idxvec(idxA, w), σ)


function IndexAutomaton(R::RewritingSystem, n::Int)
	# n is the degree so we need 2*n transitions
	α = State{UInt32, Rule}(2*n, 0)
    idxA = IndexAutomaton(2*n, α)
	append!(idxA, rwrules(R))

    return idxA
end

function Base.append!(idxA::IndexAutomaton, rules)
	idxA, signatures = direct_edges!(idxA, rules)
	idxA = skew_edges!(idxA, signatures) # complete!
	return idxA
end


"""
	hasedge(A::Automaton, σ, label)
Check if `A` contains an edge starting at `σ` labeled by `label` 
"""
function hasedge(A::Automaton, σ, label) 
	return !isnothing(σ[label])
end

"""
	trace(A::Automaton, label, σ)
Return `τ` if `(σ, label, τ)` is in `A`, otherwise return nothing.
"""
function trace(A::Automaton, label, σ) 
	if hasedge(A, σ, label)
		return σ[label]
	end 
end

"""
	trace(A::Automaton, w::AbstractVector{<:Integer} [, σ=initial(A)])
Return a pair `(l, τ)`, where 
 * `l` is the length of the longest prefix of `w` which defines a path starting at `σ` in `A` and
 * `τ` is the last state (node) on the path.
"""
function trace(A::Automaton, w::AbstractVector, σ=initial(A))
	for (i, l) in enumerate(w)
		hasedge(A, σ, l) ? σ = trace(A, l, σ) : (return i-1, σ)
	end
	return length(w), σ
end


function direct_edges!(idxA::IndexAutomaton, rwrules)
	@assert !isempty(rwrules)
	#W = typeof(first(first(rwrules)))
    α = initial(idxA)
	S = typeof(α)
	n = max_degree(α)
	states_prefixes = [α=>word""] # will be kept sorted
	for r in rwrules
        lhs, _ = r
        σ = α
        for (prefix_length, l) in enumerate(lhs)
			# shifting to positive range
			#@info "$lhs, $l"
			l = letter_to_index(l, n)
			#@info "$lhs, $l"
            if !hasedge(idxA, σ, l)
				τ = S(n, prefix_length)
				σ[l] = τ
				st_prefix = τ=>MyWord(lhs[1:prefix_length])
				# insert into sorted list
				k = searchsortedfirst(
					states_prefixes, 
					st_prefix, 
					by=n->first(n).data
				)
				#@info "$(eltype(states_prefixes)), $(typeof(st_prefix))"
 				insert!(states_prefixes, k, st_prefix)
            end
            σ = σ[l]
        end
        σ.value = r
    end
	return idxA, states_prefixes
end

function skew_edges!(idxA, states_prefixes)
	# add missing loops at the root
	α = initial(idxA)
	if degree(α) ≠ max_degree(α)
		for x in 1:max_degree(α)
			if !hasedge(idxA, α, x)
				# addedge!(idxA, (α, x, α))
				α[x] = α
			end
		end
	end

	# this has to be done in breadth-first fashion so that
	# trace(U, A) is defined
	if !issorted(states_prefixes, by=n->first(n).data)
		sort!(states_prefixes, by=n->first(n).data)
	end
	for (σ, prefix) in states_prefixes
		degree(σ) == max_degree(σ) && continue
		
		#@info "$σ, $(prefix)"

		τ = let U = prefix[2:end]
			#@info "$l, $τ, $U"
			U = map(x->letter_to_index(idxA,x), U)
			#@info "$l, $τ, $U"
			l, τ = trace(idxA, U)
			@assert l == length(U) # the whole U defines a path in A
			τ
		end

		for x in 1:max_degree(σ)
			hasedge(idxA, σ, x) && continue
			@assert hasedge(idxA, τ, x)
			# addedge!(idxA, (σ, x, τ[x]))
			σ[x] = τ[x]
		end
	end
	return idxA
end

rewrite(w::MyWord, idxA::IndexAutomaton) = rewrite!(one(w), w, idxA)
function rewrite!(
	v::MyWord, 
	w::MyWord, 
	idxA::IndexAutomaton;
	path=[initial(idxA)]
)
	resize!(v, 0)
	while !isone(w)
		x = popfirst!(w)
		σ = last(path) # current state
		τ = σ[x] # next state
		@assert !isnothing(τ) "ia doesn't seem to be complete!; $σ"
		
		if isterminal(τ)
			lhs, rhs = value(τ)
			# lhs is a suffix of v·x, so we delete it from v
			resize!(v, length(v) - length(lhs) + 1)
			# now we need to rewind the path
			resize!(path, length(path) - length(lhs) + 1)
			# and prepend rhs to w
			prepend!(w, rhs)
			
			# @assert trace(v, ia) == (length(v), last(path))
		else
			push!(v, x)
			push!(path, τ)
		end
	end
	return v	
end

