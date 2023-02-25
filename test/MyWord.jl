@testset "Word macro" begin
    @test P.word"ab" == P.MyWord([1,2])
    @test P.word"a^-1" == P.MyWord([-1])
    @test P.word"" == P.MyWord()
    @test P.word"a^-2c^1b^0" == P.MyWord([-1,-1,3])
end

@testset "Words" begin
    w = P.word"a^-1ab"
    v = P.word"b"

    @test isone(one(w))
    @test length(w) == 3
    @test length(v) == 1
    
    @test inv(w) == P.word"b^-1a^-1a"
    @test w*v == P.word"a^-1abb" 
    @test P.degree(w) == 2
    @test P.degree(v) == 2
    
    @test P.run_decomposition(w*v) == [(-1, 1), (1, 1), (2, 2)]
    #@test show(w*v) == "a^-1ab^2" 

    a = P.word"a"
    b = P.word"b"
    u = a*b*a*b*a*b
    @test P.isprefix(a*b, u)
    @test !P.isprefix(b*a, u)
    @test P.issuffix(b*a*b, u)
    @test !P.issuffix(a, u)
    @test length(P.suffixes(u)) == length(P.prefixes(u)) == 6
    @test length(P.proper_subwords(u)) == 10
    @test w == copy(w)
end