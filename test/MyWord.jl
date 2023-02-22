@testset "Words" begin
    #w = word"a^-1ab"
    #v = word"b"

    #w = MyPackage.word"a^-1ab"
    w = MyPackage.MyWord([-1, 1, 2])
    v = MyPackage.MyWord([2])
    
    @test isone(one(w))
    @test length(w) == 3
    @test length(v) == 1
    #@test w*v == word"a^-1abb" 
    @test w*v == MyPackage.MyWord([-1, 1, 2, 2])
    @test w == copy(w)
    #@test inv(w) == word"b^-1a^-1a"
    @test inv(w) == MyPackage.MyWord([-2, -1, 1])
    @test MyPackage.degree(w) == 2
    @test MyPackage.degree(v) == 2
    @test MyPackage.run_decomposition(w*v) == [(-1, 1), (1, 1), (2, 2)]
    #@test show(w*v) == "a^-1ab^2" 
end