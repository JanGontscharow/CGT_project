@testset "Reidemeister-Schreier" begin
    # from alexander hulpke cgt notes 
    Π = P.pres"|a^2, b^3, ababababab"
    U = [P.word"a", P.word"baB"]
    P.reidemeister_schreier(Π, U)

    # Example from https://math.stackexchange.com/questions/59273/presentations-of-subgroups-of-groups-given-by-presentations
    Π = P.pres"|b^2, c^2, cbcbcbcb, ababab, abcabc, acbacb"
    U = [P.word"a", P.word"b"]
    P.reidemeister_schreier(Π, U)

    # Paper
    Π = P.pres"|a^3, b^6, abababab, ab^2ab^2ab^2ab^2, ab^3ab^3ab^3, ab^2a^2b^2ab^2a^-1b^-2a^-2b^-2a^-1b^-2"
    U = [P.word"a", P.word"b^2"]
    P.reidemeister_schreier(Π, U)
end
