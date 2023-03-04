module MyPackage

#export char_to_int, int_to_char, string_to_vec, vec_to_string

# Conversion between Ints and String
char_to_int(l::Char) = Int(l)-96
int_to_char(n::Int) = Char(n+96)
string_to_vec(v::Vector{Int}) = map(int_to_char, v)
vec_to_string(s::String) = join(map(char_to_int, s))

include("MyWord.jl")
include("word_macro.jl")
include("Presentation.jl")
include("presentation_macro.jl")
include("rewriting.jl")
include("IndexAutomaton.jl")
include("tietze_transformations.jl")

"""
    make using MyPackage work.
    add test for cyclic_rewrite and free_rewrite and LenLex
    write replace! with dict in Presentation.jl.
"""


end # module MyPackage
