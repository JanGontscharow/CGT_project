#push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))

using MyPackage
using Test

P = MyPackage

include("myWord.jl")
include("presentation.jl")
include("rewriting.jl")
include("IndexAutomaton.jl")
include("CosetAutomaton.jl")
include("ReidemeisterSchreier.jl")

include("substring_search.jl")
include("weighted_substring_search.jl")
include("tietze_transformations.jl") 
include("my_tietze_program.jl") 