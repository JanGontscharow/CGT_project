@testset "Presentation macro" begin
    Π = P.pres"|a^2, bb,c^2"
    @test P.rel(Π) == [P.word"aa", P.word"bb", P.word"cc"]
    
    Π = P.pres"a, b |"
    @test isempty(P.rel(Π))
    @test P.deg(Π) == 2
    
    Π = P.pres"d| a^2"
    @test P.rel(Π) == [P.word"aa"]
    @test P.deg(Π) == 4
end

@testset "Presentation" begin
    r1 = P.word"a^-2bc"
    r2 = P.word"b^-1ca"
    Π = P.Presentation([r1, r2])

    @test P.gens(Π) == 1:3
    @test P.rel(Π) == [r2,r1]
    
    w1 = P.word"b^-2ac"
    w2 = P.word"a^-1cb"
    Π2 = P.Presentation([w1,w2])
    P.relabel!(Π, 1, 2)
    @test P.rel(Π) == P.rel(Π2)

    w = P.word"abb^-1ccc^-1daa^-1c^-1a^-1"
    @test P.cyclic_rewrite!(one(w), w) == P.word"d"
end