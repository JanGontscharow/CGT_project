function t1!(Π::Presentation, w::MyWord) 
    @assert t1_check(Π, rel) "relator must be a consequence of the presentation"
    push!(rwrules(Π), rel)
end

function t1_check(Π::Presentation, w::MyWord)
    rws = RewritingSystem(Π)
    R = knuthbendix(rws)
    return isone(rewrite!(copy(w), R))
end

function t2!(Π::Presentation, w::MyWord)
    @assert t2_check(Π, rel) "relator must be non-essential"
    filter!(v -> v != w, rel(Π))
end

function t2_check(Π::Presentation, w::MyWord)
    @assert w ∈ rel(Π) "word is not a relator of the presentation"
    rel = filter!(v -> v != w, rel(Π))
    Π2 = Presentation(deg(Π), rel)
    return isone(rewrite!(w, Π2))
end

function t3!(Π::Presentation, w::MyWord)
    @assert degree(w) <= deg(Π) "the relator must be a word over the current generators"
    push!(gens(Π), deg(Π)+1)
    push!(rel(Π), w)
end

function t4!(Π::Presentation, s::Int)
    @assert t4_check(Π, s) "generator must be redundant"
    for w ∈ rel(Π)
        filter!(l -> l != s, w)
    end
    relabel!(Π, s, deg(Π))
    resize!(gens(Π), deg(Π)-1)
end

function t4_check(Π::Presentation, s::Int)
    @assert abs(s) <= deg(Π) "must be a generator of the presentation"
    return all([count(==(s), w) < 2 for w ∈ rel(Π)])
end










