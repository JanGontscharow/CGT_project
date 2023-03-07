using Random

@testset "State" begin
	S = P.State{UInt32, P.Rule}
	σ = S(2)
	τ1 = S(2, 3)
	τ2 = S(2, 4)
	σ[1] = τ1
	σ[2] = τ2

	@test P.hasedge(σ, 1)
	@test P.hasedge(σ, 2)
	@test P.max_degree(τ1) == 2
	@test P.degree(τ1) == 0 
end

@testset "IndexAutomaton" begin
	S = P.State{UInt32, P.Rule}
	σ = S(2)
	σ1 = S(2)
	σ2 = S(2)
	σ[1] = σ1
	σ[2] = σ2
	idxA = P.IndexAutomaton(1, σ)

	@test P.trace(idxA, 1, σ) == σ1
	@test P.trace(idxA, 2, σ) == σ2
	@test isnothing(P.trace(idxA, 1, σ1)) 

	σ12 = S(1)
	σ121 = S(0)
	σ1[2] = σ12
	σ12[1] = σ121
	@test P.trace(idxA, [1,2,2], σ) == (2, σ12)
	@test P.trace(idxA, [1,2,1], σ) == (3, σ121)
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