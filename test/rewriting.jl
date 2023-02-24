@testset "Rules" begin
    w = MyPackage.MyWord([3])
    v = MyPackage.MyWord([-1, 2])
    
    @test typeof(MyPackage.rule(w,v)) == MyPackage.Rule
    @test typeof(MyPackage.rule(w)) == MyPackage.Rule
    @test MyPackage.rule(w,v) == MyPackage.rule(v,w) == (v,w)
end


@testset "Rewriting System" begin
    ε = MyPackage.MyWord([])
    s1 = MyPackage.MyWord([1])
    s2 = MyPackage.MyWord([2])

    r1 = s1*s1*s1
    r2 = s2*s2*s2
    r3 = s1*s2*inv(s1)*inv(s2)
    
    Π = MyPackage.Presentation([r1, r2, r3])
    rws = MyPackage.RewritingSystem(Π)
    rules = [(s1*inv(s1), ε), (s2*inv(s2), ε), (r1, ε), (r2, ε), (r3, ε)]
    @test MyPackage.rwrules(rws) == rules

    r1 = MyPackage.rule(s1*inv(s1))
    r2 = MyPackage.rule(inv(s1)*s1)
    r3 = MyPackage.rule(s2*inv(s2))
    r4 = MyPackage.rule(inv(s2)*s2)
    r5 = MyPackage.rule(s1*s2, s2*s1)
    r6 = MyPackage.rule(s2*inv(s1), inv(s1)*s2)
    r7 = MyPackage.rule(inv(s2)*s1, s1*inv(s2))
    r8 = MyPackage.rule(inv(s1)*inv(s2), inv(s2)*inv(s1))
    rws = MyPackage.RewritingSystem([r1, r2, r3, r4, r5])
    @test MyPackage.rwrules(MyPackage.knuthbendix(rws)) == [r1, r2, r3, r4, r5, r6, r7, r8]
end