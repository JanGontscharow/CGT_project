@testset "Rules" begin
    w = MyPackage.MyWord([3])
    v = MyPackage.MyWord([-1, 2])
    #Rule = Pair{MyPackage.MyWord, MyPackage.MyWord}
    
    @test MyPackage.rule(w,v) isa Rule
    @test MyPackage.rule(w) isa Rule
    @test MyPackage.rule(w,v) == MyPackage.rule(v,w) == (v,w)
end


@testset "Rewriting System" begin
    ε = MyPackage.MyWord([])
    s1 = MyPackage.MyWord([1])
    s2 = MyPackage.MyWord([2])
    r1 = s1*s1*s1
    r2 = s2*s2*s2
    r3 = s1*s2*s1*s2*s1*s2
    Π = MyPackage.Prsentation([r1, r2, r3])
    rws = MyPackage.RewritingSystem(Π)

    @test MyPackage.rwrules(rws) == [(s1*inv(s1), ε), (s2*inv(s2), ε), (r1, ε), (r2, ε), (r3, ε)]

    #rws' = MyPackage.knuthbendix(rws)
end