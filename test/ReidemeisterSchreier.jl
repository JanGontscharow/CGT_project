@testset "Reidemeister-Schreier" begin
    Π = P.pres"|a^2, b^2"
    U = [P.word"abAB"]
    V = P.rel(Π)

    ca = P.coset_enumeration(P.rel(Π), U)
    rep = P.coset_representatives(ca)
    @test Set(values(rep)) == Set([P.word"", P.word"a", P.word"b", P.word"ba"])
    sch = P.schreier_generators(ca, rep)
    @test Set(values(sch)) == Set([P.word"", P.word"", P.word"aa", P.word"", P.word"abAB", P.word"bb", P.word"abaB", P.word"bb"])
    reide_rel = P.reidemeister_relators(ca, sch, rep, V)
    @test Set(values(reide_rel)) == Set([P.word"aa", P.word"bb", P.word"abABabaB", P.word"abABb^3aBA"])
    
end
