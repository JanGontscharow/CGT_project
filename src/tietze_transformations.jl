
# T1: Tietze-transfomtaion corresponding to adding a consequence
function t1!(Π::Presentation, w::MyWord; check::Bool=true) 
    check && @assert t1_check(Π, w) "relator must be a consequence of the presentation"
    push!(Π, w)
end
function t1_check(Π::Presentation, w::MyWord)
    rws = RewritingSystem(Π)
    R = knuthbendix(rws)
    return isone(rewrite(w, R))
end
# T1 with RewritingSystem
function t1!(Π::Presentation, w::MyWord, R::RewritingSystem)
    isone(rewrite(w, R)) && push!(Π, w); return true
    return false 
end 

# T2: Tietze-transfomtaion corresponding to removing a consequence
function t2!(Π::Presentation, w::MyWord; check::Bool=true)
    check && @assert t2_check(Π, rel) "relator must be a consequence of the other relators"
    filter!(v -> v != w, rel(Π))
end
function t2_check(Π::Presentation, w::MyWord)
    @assert w ∈ rel(Π) "word is not a relator of the presentation"
    rel = filter!(v -> v != w, rel(Π))
    Π2 = Presentation(deg(Π), rel)
    return isone(rewrite!(w, Π2))
end
# T2 with RewritingSystem
function t2!(Π::Presentation, w::MyWord, R_w::RewritingSystem)
    isone(rewrite(w, R_w)) && filter!(v -> v != w, rel(Π)); return true
    return false 
end


# Tietze-transfomtaion corresponding to adding a generator
function t3!(Π::Presentation, w::MyWord)
    @assert degree(w) <= deg(Π) "the relator must be a word over the current generators"
    # add new generator
    s = deg(Π)+1
    setdeg!(Π,s)
    s = MyWord(s)
    push!(Π, inv(s)*w)
end

# Tietze-transfomtaion corresponding to removing a generator
function t4!(Π::Presentation, s::Int)
    @assert t4_check(Π, s) "generator must occur less than once all relators"
    # remove all relators in which s occurs
    filter!(w -> !hasletter(w,s), rel(Π))
    # swap s and the last generator
    s == deg(Π) || relabel!(Π, s, deg(Π))
    # remove the last generator
    decdeg!(Π)
end
function t4_check(Π::Presentation, s::Int)
    @assert abs(s) <= deg(Π) "must be a generator of the presentation"
    return all([count(==(s), abs(w)) < 2 for w ∈ rel(Π)])
end










