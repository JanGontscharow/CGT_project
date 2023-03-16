@testset "tietze_programs.jl" begin

    Π = P.pres"|a, b, c, ac, Bc, cdb, dfd, fGfgfg, fefe"
    @test P.weighted_eliminate_len1!(Π, P.weights()) == P.pres"|a^2"
    
    Π = P.pres"|a^2, Bc, cBcd, df, ebFEa, hah"
    @test P.weighted_eliminate_nonsquare_len2!(Π, P.weights()) == P.pres"a,b,c,d|a^2"

    Π = P.pres"|ab, bc, cd, EaEbEcEd"
    @test P.weighted_eliminate_nonsquare_len2!(Π, P.weights()) == P.pres"|BaBABaBA"

    Π = P.pres"|a^3, b^6, abababab, ab^2ab^2ab^2ab^2, ab^3ab^3ab^3, ab^2a^2b^2ab^2a^-1b^-2a^-2b^-2a^-1b^-2"
    U = [P.word"a", P.word"b^2"]
    P.reidemeister_schreier(Π, U)

    @test P.havas_program!(Π) == P.weighted_havas_program!(Π, P.weights())
end