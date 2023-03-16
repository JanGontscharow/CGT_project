@testset "Reidemeister-Schreier" begin
    # From alexander hulpke cgt notes (example 35)
    Π = P.pres"|a^2, b^3, ababababab"
    U = [P.word"a", P.word"baB"]
    P.reidemeister_schreier(Π, U)

    ca = P.coset_enumeration(U, P.rel(Π), P.deg(Π))
    rep = P.coset_representatives(ca)
    schreier, sch = P.schreier_generators(ca, rep)
    reide_rel = P.reidemeister_relators(ca, sch, rep, P.rel(Π))
    @test length(values(rep)) == 6
    @test length(schreier) == 7

    # Example from https://math.stackexchange.com/questions/59273/presentations-of-subgroups-of-groups-given-by-presentations
    Π = P.pres"|c^2, b^2, cbcbcbcb, ababab, abcabc, acbacb"
    U = [P.word"a", P.word"b"]
    P.reidemeister_schreier(Π, U)

    ca = P.coset_enumeration(U, P.rel(Π), P.deg(Π))
    rep = P.coset_representatives(ca)
    schreier, sch = P.schreier_generators(ca, rep)
    reide_rel = P.reidemeister_relators(ca, sch, rep, P.rel(Π))
    @test length(values(rep)) == 4
    @test length(schreier) == 9

    # G₁, H₁ from Havas Paper
    Π = P.pres"|a^3, b^6, abababab, ab^2ab^2ab^2ab^2, ab^3ab^3ab^3, ab^2a^2b^2ab^2a^-1b^-2a^-2b^-2a^-1b^-2"
    U = [P.word"a", P.word"b^2"]
    P.reidemeister_schreier(Π, U)

    ca = P.coset_enumeration(U, P.rel(Π), P.deg(Π))
    rep = P.coset_representatives(ca)
    schreier, sch = P.schreier_generators(ca, rep)
    reide_rel = P.reidemeister_relators(ca, sch, rep, P.rel(Π))
    @test length(values(rep)) == 26
    @test length(schreier) == 27


    # from Robertson Paper
    #Π = P.pres"|ab^2ABa^3B, ba^2BAb^3A"
    #U = [P.word"abAB", P.word"aBAb"]
    #P.reidemeister_schreier(Π, U)

    #ca = P.coset_enumeration(U, P.rel(Π), P.deg(Π))
    #rep = P.coset_representatives(ca)
    #schreier, sch = P.schreier_generators(ca, rep)
    #reide_rel = P.reidemeister_relators(ca, sch, rep, P.rel(Π))
    #@test length(values(rep)) == 72
    #@test length(schreier) == 73
end
