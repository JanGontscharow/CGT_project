



macro pres_str(str)
    # extract generators
    gens_pattern = r"[a-z](, [a-z])* |"
    matches = eachmatch(gens_pattern, str)
    gens = []
    for match in matches
        push!(gens, char_to_int(match[1]))
    end

    # extract relators
    pattern = r"([a-z])+(\^\-?\d+)?"
    matches = eachmatch(pattern, str)
    relators = [string_to_vec(match[1]) for match in matches]

    return :($Presentation($relators))
end