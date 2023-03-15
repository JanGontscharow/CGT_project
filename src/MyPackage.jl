module MyPackage

# Conversion between Ints and String
char_to_int(l::Char) = Int(l) > 96 ? Int(l)-96 : -(Int(l)-64)
function int_to_char(n::Int) 
    if 0 < abs(n) <= 26
        return n > 0 ? Char(n+96) : Char(-n+64) 
    else
        subscript = int_to_subscript(abs(n)-26)
        return n > 0 ? 'z'*subscript : 'Z'*subscript
    end
end
vec_to_string(v::Vector{Int}) = map(int_to_char, v)
string_to_vec(s::String) = join(map(char_to_int, s))

include("MyWord.jl")
include("word_macro.jl")
include("Presentation.jl")
include("presentation_macro.jl")
include("rewriting.jl")
include("IndexAutomaton.jl")
include("CosetAutomaton.jl")

include("tietze_transformations.jl")
include("substring_search.jl")
include("weighted_substring_search.jl")
include("my_tietze_program.jl")
include("ReidemeisterSchreier.jl")
include("comparisons.jl")

"""
    TODO
    make using MyPackage work.
    add tests for cyclic_rewrite and free_rewrite and LenLex
    add tests for weighted_substring_search
    implement another tietze programm based on substring search
"""


end # module MyPackage
