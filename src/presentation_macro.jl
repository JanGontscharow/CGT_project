

function parse_degree(str::String)
    pattern = r"[a-zA-Z](\,\s?[a-zA-Z])*\s?\|"
    mat = match(pattern, str)
    isnothing(mat) && return nothing
    mat = filter(isletter, mat.match)
    gens = map(char_to_int, collect(mat))
    return maximum(gens)
end

function parse_relators(str::String)
    pattern = r"\|\s?([a-zA-Z]((\^\-?\d+)|([¹²³⁴⁵⁶⁷⁸⁹⁰]+))?)+(\,\s?([a-zA-Z]((\^\-?\d+)|([¹²³⁴⁵⁶⁷⁸⁹⁰]+))?)+)*"
    mat = match(pattern, str)
    isnothing(mat) && return MyWord[]
    mat = filter((c -> !(c in " |")), mat.match)
    mat = split(mat, ',')
    relators = [string_to_word(m) for m in mat]
    return relators
end

macro pres_str(str::String)
    degree = parse_degree(str)
    relators = parse_relators(str)
    if isnothing(degree)
        @assert !isempty(relators) "presentation must be given relators if degree is not specified"
        return :($Presentation($relators))
    end 
    return :($Presentation($degree, $relators))
end