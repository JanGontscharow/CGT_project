@testset "substring_search.jl" begin

    w₁, v₁, u₁ = P.word"abc", P.word"abc", P.word"bca"
    @test P.substring_search(w₁, v₁) == (u₁, 2, 2, false)

    w₂, v₂, u₂ = P.word"abc", P.word"ddabc", P.word"abc"
    P.substring_search(w₂, v₂) == (u₂, 1, 3, false)

    w₃, v₃, u₃ = P.word"abcdd", P.word"ccccADD", P.word"ADD"
    P.substring_search(w₃, v₃) == (u₃, 1, 5, true) 

    w₄, v₄, u₄ = P.word"a^10bab", P.word"a^11baabA^11b", P.word"a^10ba"
    @test P.substring_search(w₄, v₄) == (u₄, 1, 2, false)

end