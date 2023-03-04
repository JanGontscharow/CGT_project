#push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))

using MyPackage
using Test

P = MyPackage

include("myWord.jl")
include("presentation.jl")
include("rewriting.jl")
include("IndexAutomaton.jl")
include("tietze_transformations.jl") 