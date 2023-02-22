module MyPackage

#export char_to_int, int_to_char, string_to_vec, vec_to_string

# Conversion between Ints and String
char_to_int(l::Char) = Int(l)-96
int_to_char(n::Int) = Char(n+96)
string_to_vec(v::Vector{Int64}) = map(int_to_char, v)
vec_to_string(s::String) = join(map(char_to_int, s))

export @word_str

include("myWord.jl")
include("presentation.jl")
include("rewriting.jl")

"""
    make using MyPackage work.
    share git-link with kaluba.
    make macros work.
    implement test for replace! with dict in Presentation.jl.
    implement reduce in rewriting.jl
    implement Tietze-transformations.
    
"""


end # module MyPackage
