@testset "weighted_substring_search.jl" begin
    w₁, v₁ = P.word"abc", P.word"abc"
    w₂, v₂ = P.word"abc", P.word"ddabc"
    w₃, v₃ = P.word"abcdd", P.word"ccccADD"
    w₄, v₄ = P.word"a^10bab", P.word"a^11baabA^11b"

    for (w, v) in [(w₁, v₁), (w₂, v₂), (w₃, v₃), (w₄, v₄)]
        @test P.substring_search(w, v) == P.weighted_substring_search(w, v, P.weights())
    end

    n, l, m = 50, 20, 10

    for _ in 1:n
        w = P.MyWord(rand(1:2, l))
        v = P.MyWord(rand(1:2, l+10))
        @test P.substring_search(w, v) == P.weighted_substring_search(w, v, P.weights())
    end

end