
"""
    word"..."

# Examples:
```jldoctest
julia> w = word"ab^2c^-2c^-1"
ab^2c^-3

julia> typeof(p)
MyWord

julia> degree(p)
3
```
"""
function parse_syllables(str::AbstractString)
    # match letter with opotional exponent
    pattern = r"([a-z])(\^\-?\d+)?"
    return eachmatch(pattern, str)
end

function parse_pairs(syllables)
    pairs = []
    for syllable in syllables
        gen, exp = syllable.captures
        exp = isnothing(exp) ? 1 : parse(Int, exp[2:end])
        gen = char_to_int(gen[1])
        iszero(exp) || push!(pairs, (gen, exp))
    end
    return pairs
end

function string_to_word(str::AbstractString)
    syllables = parse_syllables(str)
    pairs = parse_pairs(syllables)
    vec = Int[]
    for (s,e) in pairs
        for _ in 1:abs(e)
            push!(vec, sign(e)*s)
        end
    end
    return MyWord(vec)
end

macro word_str(str::AbstractString)
    return :($string_to_word($str))
end