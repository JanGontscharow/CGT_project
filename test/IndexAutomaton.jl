using Random

@testset "State" begin
	S = P.State{UInt32, P.Rule}
	σ = S(2)
	τ₁ = S(2, 3)
	τ₂ = S(2, 4)
	σ[1] = τ₁
	σ[2] = τ₂

	@test P.hasedge(σ, 1)
	@test P.hasedge(σ, 2)
	@test P.max_degree(τ₁) == 2
	@test P.degree(τ₂) == 0 
end

@testset "IndexAutomaton" begin
	S = P.State{UInt32, P.Rule}
	σ = S(2)
	σ₁ = S(2)
	σ₂ = S(2)
	σ[1] = σ₁
	σ[2] = σ₂
	idxA = P.IndexAutomaton(2, σ)
	@test P.letter_to_index(idxA, -1) == 2

	@test P.trace(idxA, 1, σ) == σ₁
	@test P.trace(idxA, 2, σ) == σ₂
	@test isnothing(P.trace(idxA, 1, σ₁)) 

	σ₁₂ = S(1)
	σ₁₂₁ = S(0)
	σ₁[2] = σ₁₂
	σ₁₂[1] = σ₁₂₁
	@test P.trace(idxA, [1,2,2], σ) == (2, σ₁₂)
	@test P.trace(idxA, [1,2,1], σ) == (3, σ₁₂₁)
	@test P.trace(idxA, P.word"aAa") == (3, σ₁₂₁)
end

@testset "Index rewrite" begin
	rws = let
		a = P.word"a"
        A = inv(a)
		b = P.word"b"
        B = inv(b)
		ε = P.word""
		rws = P.RewritingSystem(
			[a*A=>ε, A*a=>ε, b*B=>ε, B*b=>ε, b*a=>a*b]
		)
		P.reduce(P.knuthbendix(rws))
	end

	idxA = P.IndexAutomaton(rws, 2)
	n,l = (10,100)

	for i in 1:n
		w = P.MyWord(rand(1:2, l))
		@test P.rewrite(w, rws) == P.rewrite(w, idxA)
	end
end