@testset "Tietze-transformations" begin
    Π = P.pres"|a^2, aba^-1b"
    
    P.t3!(Π, P.word"ba")
    @test Π == P.pres"|a^2, c^-1ba, aba^-1b"
    
    P.t1!(Π, P.word"c^2", check=false)
    @test Π == P.pres"|a^2, c^2, c^-1ba, aba^-1b"

    P.t2!(Π, P.word"aba^-1b", check=false)
    @test Π == P.pres"|a^2, c^2, c^-1ba"

    P.t1!(Π, P.word"b^-1ca^-1", check=false)
    @test Π == P.pres"|a^2, c^2, c^-1ba, b^-1ca^-1"

    P.t4!(Π, 2)
    @test Π == P.pres"|a^2, b^2"
end