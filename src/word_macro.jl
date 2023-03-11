
"""
    word"..."

# Examples:
```jldoctest
julia> w = word"a^2a^-1bb^2B^0C"
7-element MyPackage.MyWord:
  1
  1
 -1
  2
  2
  2
 -3

julia> show(w)
a²Ab³C

julia> typeof(w)
MyWord

julia> degree(w)
3
```
"""

# syllables referring to a letter to a power
function parse_syllables(str::AbstractString)
    # match letter with opotional exponent
    pattern = r"([a-zA-Z])(\^\-?\d+)?"
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