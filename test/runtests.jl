push!(LOAD_PATH, joinpath(@__DIR__, "..", "src"))

using MyPackage
using Test

include("myWord.jl")
include("presentation.jl")
include("rewriting.jl")