module MyPackage

#export char_to_int, int_to_char, string_to_vec, vec_to_string

# Conversion between Ints and String
char_to_int(l::Char) = Int(l)-96
int_to_char(n::Int) = n < 0 ? Char(-n+64) : Char(n+96) 
string_to_vec(v::Vector{Int}) = map(int_to_char, v)
vec_to_string(s::String) = join(map(char_to_int, s))

include("MyWord.jl")
include("word_macro.jl")
include("Presentation.jl")
include("presentation_macro.jl")
include("rewriting.jl")
include("IndexAutomaton.jl")
include("tietze_transformations.jl")
include("tietze_programm.jl")
include("comparisons.jl")
include("substring_search.jl")
include("weighted_substring_search.jl")

"""
    TODO
    make using MyPackage work.
    add tests for cyclic_rewrite and free_rewrite and LenLex
    add tests for substring search
    implement a substring search that works with inverses
    implement another tietze programm based on substring search
    implement weighted substring search
"""


end # module MyPackage
