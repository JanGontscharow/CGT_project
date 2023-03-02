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
    rules = [a*A=>ε, A*a=>ε,  b*B=>ε, B*b=>ε,  r1=>ε, r2=>ε, r3=>ε]
    @test P.rwrules(rws) == rules

    r1 = a*A => ε
    r2 = A*a => ε
    r3 = b*B => ε
    r4 = B*b => ε
    r5 = b*a => a*b
    r6 = b*A => A*b
    r7 = B*a => a*B
    r8 = B*A => A*B
    rws = P.RewritingSystem([r1, r2, r3, r4, r5])
    @test P.rwrules(P.knuthbendix(rws)) == [r1, r2, r3, r4, r5, r6, r7, r8]
end