@testset "Rules" begin
    w = P.word"c"
    v = P.word"a^-1b"
    
    @test typeof(P.rule(w,v)) == P.Rule
    @test typeof(P.rule(w)) == P.Rule
    @test P.rule(w,v) == P.rule(v,w) == (v => w)
end


@testset "Rewriting System" begin
    ε = P.word""
    a = P.word"a"
    b = P.word"b"
    A = inv(a)
    B = inv(b)

    r1 = a*a*a
    r2 = b*b*b
    r3 = a*b*A*B
     
    Π = P.Presentation([r1, r2, r3])
    rws = P.RewritingSystem(Π)
    rules = [a*A=>ε, b*B=>ε, r1=>ε, r2=>ε, r3=>ε]
    @test P.rwrules(rws) == rules

    r1 = P.rule(a*A)
    r2 = P.rule(A*a)
    r3 = P.rule(b*B)
    r4 = P.rule(B*b)
    r5 = P.rule(a*b, b*a)
    r6 = P.rule(b*A, A*b)
    r7 = P.rule(B*a, a*B)
    r8 = P.rule(A*B, B*A)
    rws = P.RewritingSystem([r1, r2, r3, r4, r5])
    @test P.rwrules(P.knuthbendix(rws)) == [r1, r2, r3, r4, r5, r6, r7, r8]
end