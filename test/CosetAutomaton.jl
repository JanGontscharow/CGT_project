@testset "CosetAutomaton" begin
	S = P.State{UInt32, P.Rule}
	σ = S(2)
	σ₁ = S(2)
	σ₂ = S(2)
	σ[1] = σ₁
	σ[2] = σ₂
	ca = P.CosetAutomaton(2, [σ], Dict{S, S}(), S(2, fail=true))
	@test P.letter_to_index(ca, -1) == 2

	@test P.trace(ca, 1, σ) == σ₁
	@test P.trace(ca, 2, σ) == σ₂ 

	σ₁₂ = S(1)
	σ₁₂₁ = S(0)
	σ₁[2] = σ₁₂
	σ₁₂[1] = σ₁₂₁
	@test P.trace(ca, [1,2,2], σ) == (2, σ₁₂)
	@test P.trace(ca, [1,2,1], σ) == (3, σ₁₂₁)
	@test P.trace(ca, P.word"aAa", σ) == (3, σ₁₂₁)

	ca = P.CosetAutomaton(2)

	α = P.initial(ca)
	@test P.states(ca) == [α]
	@test P.trace(ca, P.word"BBB", α) == (0, α)

	σ₁ = P.define!(ca, α, -2)
	@test P.states(ca) == [α, σ₁]
	@test P.trace(ca, P.word"BBB", α) == (1, σ₁)

	σ₂ = P.define!(ca, σ₁, -2)
	@test P.states(ca) == [α, σ₁, σ₂]
	@test P.trace(ca, P.word"BBB", α) == (2, σ₂)

	ca = P.CosetAutomaton(2)
	P.trace_and_reverse!(ca, P.word"aaa")
	@test length(P.states(ca)) == 3

	ca = P.CosetAutomaton(2)
	P.trace_and_reverse!(ca, P.word"aaaa")
	@test length(P.states(ca)) == 4
end

@testset "Coset enumeration" begin
	# example from lecture
	U = [P.word"ab"]
	V = [P.word"a^3", P.word"b^3", P.word"ababab", P.word"aBaBaB"]
	ca = P.coset_enumeration(U, V, 2)
	P.adjacency_matrix(ca)
	@test length(P.states(ca)) == 9
	
	repr = [P.word"", P.word"a", P.word"A", P.word"b", P.word"ba", P.word"bA", P.word"bab", P.word"AB", P.word"Ab"]
	cosets = map(w -> P.trace(ca, w), repr)
	@test length(cosets) == length(Set(cosets))
end