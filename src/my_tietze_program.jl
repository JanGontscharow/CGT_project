"""
    Strategy continously trying to apply T2 and T4 and after each change 
    eliminate relators of length 1 and nonsquare relators of length 2 
"""
function my_tietze_programm!(Π::Presentation; maxrules=50)
    changes_made = true
    while changes_made
        changes_made = false
        eliminate_len1!(Π)
        eliminate_nonsquare_len2!(Π)
        # T2 loop
        for w ∈ rel(Π)
            # consider the Presentation Π_w obtained by leaving out w
            Π_w = Presentation(deg(Π), [v for w ∈ rel(Π) if v != w])
            rws_w = RewritingSystem(Π_w) 
            R_w = knuthbendix(rws_w; maxrules=maxrules)
            isnothing(R_w) && continue
            # if knuth-bendix can be applied try T2(Π,w)
            changes_made = t2!(Π, w, R_w)
            changes_made && break
        end
        # try appyling T4
        for s in gens(Π)
            if t4_check(Π, s)
                t4!(Π, s)
                changes_made = true
                break
            end
        end
    end
    return Π
end

function eliminate_nonsquare_len2!(Π::Presentation)
    isempty(rel(Π)) && return Π # nothing to eliminate
    @assert length(first(rel(Π))) > 1 "eliminate relators of length 1 first"

    # We use MyUnionFind to determine the equivalence of the generators and thier inverses
    uf = MyUnionFind(collect(gens(Π)))

    while true    
        nonsquare_len2 = []
        for (i,w) in enumerate(rel(Π))
            length(w) > 2 && break
            s, t = w
            myunion!(uf, s, -t)
            s==t || push!(nonsquare_len2, i)
        end
        isempty(nonsquare_len2) && break  # nothing to eliminate
        deleteat!(rel(Π), nonsquare_len2)

        # relabel the relators according to the equivalence of generators
        dict = Dict{Int, Int}()
        for s in gens(Π)
            myfind(uf, s) == s && continue
            dict[abs(s)] = sign(s)*myfind(uf, s)
        end
        relabel!(Π, dict)

        # restore invariants except generator invariant
        restore_reduced_invariant!(Π)
        restore_nontrivial_invariant!(Π)

        # eliminate relators of length 1
        eliminate_len1!(Π)

        # nothing more to eliminate
        isempty(rel(Π)) && break
    end     

    unused_gens = [s for s in gens(Π) if s != myfind(uf, s)]
    restore_generator_invariant!(Π, unused_gens)
    return Π
end




struct MyUnionFind
    parent::Dict{Int, Int}
end
function MyUnionFind(generators::Vector{Int})
    parent = Dict{Int,Int}()
    for s in generators
        parent[s] = s
        parent[-s] = -s
    end
    return MyUnionFind(parent)
end
function myfind(uf::MyUnionFind, s::Int)
    uf.parent[s] == s ? (return s) : return myfind(uf, uf.parent[s])
end
function myunion!(uf::MyUnionFind, s::Int, t::Int)
    s = myfind(uf, s)
    t = myfind(uf, t)
    s == t && return
    if s == -t
        # choose the positiv generator as representative
        uf.parent[-abs(s)] = abs(s)
    else
        # choose the generator of smaller absolute value as representative.
        s, t = abs(s) > abs(t) ? (s, t) : (t, s)
        uf.parent[s] = t
        # keep the equivalence classes symmetric.
        uf.parent[-s] = -t
    end
end




function eliminate_len1!(Π::Presentation)
    isempty(rel(Π)) && return Π # nothing to eliminate

    has_len1 = length(first(rel(Π))) == 1
    trivial_gens = Int[]

    while has_len1

        # cutoff relators of length less than 1 and store trivial relators in stack
        stack = Int[]
        cutoff = 0
        for (i,w) in enumerate(rel(Π))
            length(w) > 1 && break
            s = abs(first(w))
            push!(stack, s)
            cutoff = i
        end
        deleteat!(rel(Π), 1:cutoff)

        # remember which generators to remove 
        append!(trivial_gens, stack)

        # remove trivial generators from relators 
        map!(w -> mod_letters(w, stack), rel(Π), rel(Π))

        # restore invariants except generator invariant
        sort!(rel(Π), lt=lt)
        restore_reduced_invariant!(Π)

        restore_nontrivial_invariant!(Π)    

        isempty(rel(Π)) && break
        has_len1 = length(first(rel(Π))) == 1
    end
    # Fill holes left by the trivial generators to restore the Presentation invariants.
    restore_generator_invariant!(Π, trivial_gens)
    return Π
end

# Fill holes left by the unused generators to restore the generator invariant of Presentations.
function restore_generator_invariant!(Π::Presentation, unused_gens::Vector{Int})    
    # Fill by relabeling the top non-unused generators
    number_of_holes = length(unused_gens)
    sort!(unused_gens, rev=true) # go through unused generators in ascending order via pop!
    dict = Dict{Int,Int}()
    for s in reverse(gens(Π))
        s ∈ unused_gens && continue # cannot fill hole with unused generators
        isempty(unused_gens) && break # no more holes to fill
        t = pop!(unused_gens)
        s < t && break # every hole has been filled
        dict[s] = t
    end
    relabel!(Π, dict)
    decdeg!(Π, number_of_holes)
end

# Assumes Presentation is sorted
function restore_reduced_invariant!(Π::Presentation)
    for (i,w) ∈ enumerate(rel(Π))
        w == cyclic_rewrite(w) && continue
        w = cyclic_rewrite(w)
        """
            we cannot use replace_rel! since (in the case of a duplicate) it changes the length of
            the relator-array and thus influences the indices of the relators which occur at 
            [i+1:length(rel(Π))] in the original relator-arry
        """
        deleteat!(rel(Π), i)
        # insert the reduced w according to lt 
        for (j,v) in enumerate(rel(Π))
            lt(v, w) && continue
            insert!(Π.relators, j, w) 
            break
        end
    end
end

function restore_nontrivial_invariant!(Π::Presentation)
    #cutoff = 0
    #for (i,w) ∈ enumerate(rel(Π))
    #    !isone(w) && break
    #    cutoff = i
    #end
    #unique!(Π.relators)
    unique!(Π.relators)
    isone(first(rel(Π))) && deleteat!(Π.relators, 1)
end
