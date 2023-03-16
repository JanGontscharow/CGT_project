
"""
    number of generators
    number of relators
    total length of relators
    length of longest relator
"""
metric_a(Π::Presentation) = deg(Π)
metric_b(Π::Presentation) = length(rel(Π))
metric_c(Π::Presentation) = maximum(map(root_length, rel(Π)))
metric_d(Π::Presentation) = sum(map(root_length, rel(Π)))

# determine the length of a word ignoring the outer exponent
# for example the root length of (abc^2)^3 is 4  
function root_length(w::MyWord)
    for root_len in 1:halflen(w)
        length(w) % root_len == 0 || continue
        if all([w[1:root_len]==w[1+root_len*(k-1):root_len*k] for k in 2:div(length(w), root_len)])
            return root_len
        end
    end
    return length(w)
end

# From Havas Paper
Π₁ = pres"|a^3, b^6, abababab, ab^2ab^2ab^2ab^2, ab^3ab^3ab^3, ab^2a^2b^2ab^2a^-1b^-2a^-2b^-2a^-1b^-2"
U₁ = [word"a", word"b^2"]

Π₂ = pres"|a^4, b^4, abababab, AbAbAbAb, aabaabaabaab, abbabbabbabb, aabbaabbaabbaabb, abABabABabABabAB, AbabAbabAbabAbab"
U₂ = [word"a", word"b^2"]

Π₃ = pres"|a^11, b^5, c^4, bc^2bc^2, abcabcabc, a^4c^2a^4c^2a^4c^2, b^2c^-1b^-1c, a^4b^-1a^-1b"
U₃ = [word"a", word"b", word"c^2"]

Π₄ = pres"|a^11, b^5, c^4, acacac, b^2c^-1b^-1c, a^4b^-1a^-1b"
U₄ = [word"a", word"b", word"c^2"]

Π₅ = pres"|a^3, b^7, c^13, abab, bcbc, caca, abcabc"
U₅ = [word"ab", word"c"]

Π₆ = pres"|a^3, b^7, c^14, abab, bcbc, caca, abcabc"
U₆ = [word"ab", word"c"]

"""
    results are inconsistent since the ReidemeisterSchreier presentation is 
    also different from excecute to excecute
"""
function results()
    presentation_subgroup_pairs = [(Π₁, U₁), (Π₂, U₂), (Π₃, U₃), (Π₄, U₄), (Π₅, U₅), (Π₆, U₆)] 
    metrics = [metric_a, metric_b, metric_c, metric_d]
    test_presentations = [reidemeister_schreier(Π, U) for (Π, U) in presentation_subgroup_pairs]
    strategies = [x -> x, havas_program!, x -> weighted_havas_program!(x, weights(1))]
    for strategy in strategies
        for Π in test_presentations
            Π₀ = strategy(deepcopy(Π))
            for metric in metrics 
                print(metric(Π₀), " ")
            end
            println()
        end
        print("\n\n")
    end
end