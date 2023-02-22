
"""
    word"..."

String macro to parse.

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

macro word_str(str::String)
    # match letter with opotional exponent
    pattern = r"([a-z])(\^\-?\d+)?"
    matches = eachmatch(pattern, str)

    # extract exponents
    exponents = Vector{Int}()
    exp = nothing
    for match in matches
        if !isnothing(match[2])
            exp = parse(Int, match[2][2:end])
        else
            exp = 1
        end
        push!(exponents, exp)
    end

    # apply exponents
    ints = [char_to_int(l) for l in str if isletter(l)]
    pairs = zip(ints, exponents)
    segments = [repeat([sign(e)*n], abs(e)) for (n, e) in pairs] 
    vec = vcat(segments)
    
    return :($MyWord($vec))
end