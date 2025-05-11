@testset "substring_search.jl" begin

    # identical words → cyclic shift expected
    w₁, v₁, u₁ = P.word"abc", P.word"abc", P.word"bca"
    @test P.substring_search(w₁, v₁) == (u₁, 2, 2, false)

    # exact match in the middle
    w₂, v₂, u₂ = P.word"abc", P.word"xxabcxx", P.word"abc"
    @test P.substring_search(w₂, v₂) == (u₂, 1, 3, false)

    # inverse match
    w₃, v₃, u₃ = P.word"abcdd", P.word"ccccADD", P.word"ADD"
    @test P.substring_search(w₃, v₃) == (u₃, 5, 5, true)

    # many valid matches → choose one (deterministic)
    w₄, v₄, u₄ = P.word"a^10bab", P.word"a^11baabA^11b", P.word"a^10ba"
    @test P.substring_search(w₄, v₄) == (u₄, 1, 2, false)

    # match wraps around in v (cyclic w)
    w₇, v₇, u₇ = P.word"abc", P.word"cxxab", P.word"abc"
    @test P.substring_search(w₇, v₇) == (u₇, 1, 4, false)

    # w longer than v → should throw
    w₈, v₈ = P.word"abcdef", P.word"abc"
    @test_throws AssertionError P.substring_search(w₈, v₈)

    # match exists but too short (< half length) → ignored
    w₉, v₉ = P.word"abcdef", P.word"xxcdeyy"
    @test P.substring_search(w₉, v₉) == (P.word"", 0, 0, false)

    # inverse match too short → ignored
    w₁₁, v₁₁ = P.word"abcd", P.word"xxCBx"
    @test P.substring_search(w₁₁, v₁₁) == (P.word"", 0, 0, false)

end