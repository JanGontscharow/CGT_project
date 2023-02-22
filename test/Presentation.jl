@testset "Presentation" begin
    r1 = MyPackage.MyWord([-1, -1, 2, 3])
    r2 = MyPackage.MyWord([-2, 3, 1])
    Π = MyPackage.Presentation([r1, r2])

    @test MyPackage.gens(Π) == 1:3
    @test MyPackage.rel(Π) == [r2,r1]
    
    w1 = MyPackage.MyWord([-2, -2, 1, 3])
    w2 = MyPackage.MyWord([-1, 3, 2])
    Π2 = MyPackage.Presentation([w1,w2])
    MyPackage.relabel!(Π, 1, 2)
    @test MyPackage.rel(Π) == MyPackage.rel(Π2)

    #v1 = MyPackage.MyWord([-3, -3, 2, 1])
    #v2 = MyPackage.MyWord([-2, 1, 3])
    #Π2 = MyPackage.Presentation([v1,v2])
    #MyPackage.relabel!(Π, Dict(1=>2, 2=>3, 3=>1))
    #@test MyPackage.rel(Π) == MyPackage.rel(Π2)

    w = MyPackage.MyWord([1, 2, -2, 3, 3, -3, 4, 1, -1, -3, -1])
    @test MyPackage.cyclic_rewrite!(one(w), w) == MyPackage.MyWord([4])
end