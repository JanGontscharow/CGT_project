

@testset "my_tietze_program.jl" begin
    Π = P.pres"|a, b, c, ac, Bc, cdb, dfd, fGfgfg, fefe"
    @test P.eliminate_len1!(Π) == P.pres"|a^2"
    
    Π = P.pres"|a^2, Bc, cBcd, df, ebFEa, hah"
    @test P.eliminate_nonsquare_len2!(Π) == P.pres"a,b,c,d|a^2"

    Π = P.pres"|ab, bc, cd, EaEbEcEd"
    @test P.eliminate_nonsquare_len2!(Π) == P.pres"|BaBABaBA"
end 