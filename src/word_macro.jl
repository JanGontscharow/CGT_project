
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
    pattern = r"([a-zA-Z])((\^\-?\d+)|([¹²³⁴⁵⁶⁷⁸⁹⁰]+))?"
    return eachmatch(pattern, str)
    #r"([a-zA-Z])(\^\-?\d+)?"
end

#exp_to_base = Dict('¹'=>'1', '²'=>'2', '³'=>'3', '⁴'=>'4', '⁵'=>'5', '⁶'=>'6', '⁷'=>'7', '⁸'=>'8', '⁹'=>'9', '⁰'=>'0', '⁻'=>'-')
exp_to_base = Dict('¹'=>1, '²'=>2, '³'=>3, '⁴'=>4, '⁵'=>5, '⁶'=>6, '⁷'=>7, '⁸'=>8, '⁹'=>9, '⁰'=>9)


function parse_pairs(syllables)
    pairs = []
    for syllable in syllables
        gen, exp = syllable.captures
        if isnothing(exp)
            exp = 1
        else
            exp = (exp[1] == '^') ? parse(Int, exp[2:end]) :  parse(Int, join([string(exp_to_base[x]) for x in exp]))
        end
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