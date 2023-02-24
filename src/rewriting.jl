
Rule = Tuple{MyWord, MyWord}

function string_repr(
    r::Rule,
    lhspad = 2length(first(r)) - 1,
    rhspad = 2length(last(r)) - 1,
)
    lhs, rhs = r
    L = rpad(string_repr(lhs), lhspad)
    R = lpad(string_repr(rhs), rhspad)
    return "$L → $R"
end

function rule(p::MyWord, q::MyWord)
    return lt(p, q) ? (q, p) : (p, q)
end
# Rule for relators
function rule(w::MyWord)
    rule(w, one(w))
end

struct RewritingSystem
    rwrules::Vector{Rule}
    RewritingSystem(rules::Vector{Rule}) = new(rules)
    function RewritingSystem(Π::Presentation)
        rules = []
        # add free group relations 
        for s in gens(Π)
            push!(rules, rule(MyWord([s,-s])))
        end
        # add relator relations
        for w in rel(Π)
            push!(rules, rule(w))
        end
        return new(rules)
    end
end

rwrules(rws::RewritingSystem) = rws.rwrules

function Base.empty(rws::RewritingSystem)
    return RewritingSystem(empty(rws.rwrules))
end

function Base.push!(rws::RewritingSystem, r::Rule)
    lhs, rhs = r
    return push!(rws, lhs, rhs)
end

function Base.push!(rws::RewritingSystem, p::MyWord, q::MyWord)
    if p == q
		return rws
	end
    a = rewrite(p, rws) # allocate two/three new words
    b = rewrite(q, rws)
    if a ≠ b
        r = rule(a, b)
        #@info ("new rule", rule(a,b))
        push!(rws.rwrules, r) # modifies rws directly
    end
end

rewrite(w::MyWord, rws::RewritingSystem) = rewrite!(one(w), copy(w), rws) 
function rewrite!(out::MyWord, w::MyWord, rws::RewritingSystem)
    resize!(out, 0)
    while !isone(w)
        push!(out, popfirst!(w))
        for (lhs, rhs) in rwrules(rws)
            if issuffix(lhs, out)
                prepend!(w, rhs)
                resize!(out, length(out) - length(lhs))
                break
            end
        end
    end
    return out
end

#is_irreducible(w::MyWord, rws::RewritingSystem) = !is_reducible(rws, w)
function is_irreducible(w::MyWord, rws::RewritingSystem)
    return w == rewrite(w, rws)
end


function resolve_overlaps!(
    rws::RewritingSystem,
    r₁::Rule,
    r₂::Rule,
)
    p₁, q₁ = r₁
    p₂, q₂ = r₂
    for s in suffixes(p₁)
        if isprefix(s, p₂)
            a = MyWord(p₁[begin:end-length(s)])
            b = MyWord(p₂[length(s)+1:end])
            # word a*s*b rewrites in two possible ways:
            # q₁*b and a*q₂
            # we need to resolve this local failure to confluence:
            push!(rws, q₁ * b, a * q₂) # the correct rule is found in push!
		elseif isprefix(p₂, s) # i.e. p₂ is a subword in p₁
		# because rws may not be reduced
            a = MyWord(p₁[begin:end-length(s)])
            b = MyWord(p₁[length(a)+length(p₂)+1:end])
            # word p₁ = a*p₂*b can be rewritten in two possible ways:
            # q₁ and a*q₂*b
            push!(rws, q₁, a * q₂ * b)
        end
    end
    return rws
end

function reduce(rws::RewritingSystem)
    S = empty(rws)
    for r in rwrules(rws)
        p, q = r
        if all([is_irreducible(p̃, rws) for p̃ ∈ proper_subwords(p)])
            push!(S, rule(p, rewrite(q, rws)))
        end
    end
    return S
end

function knuthbendix(R::RewritingSystem; maxrules = 100)
    rws = empty(R)
    for r in rwrules(R)
        push!(rws, deepcopy(r))
    end

    for (i, r₁) in enumerate(rwrules(rws))
        for (j,r₂) in enumerate(rwrules(rws))
			if length(rws.rwrules) > maxrules
                @warn "Maximum number of rules has been exceeded. Try running knuthbendix with larger maxrules kwarg"
				return rws
            end
			#@info (i,j)
            resolve_overlaps!(rws, r₁, r₂)
            r₁ == r₂ && break
            resolve_overlaps!(rws, r₂, r₁)
        end
    end
    return reduce(rws)
end