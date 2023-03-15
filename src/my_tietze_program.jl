

function my_tietze_programm!(Π::Presentation; maxrules=50)
    eliminate_len1!(Π)
    eliminate_len2!(Π)
    changes_made = true
    while changes_made
        changes_made = false
        for w ∈ collect(rel(Π))
            # consider the Presentation Π_w obtained by leaving out w
            Π_w = copy(Π)
            filter!(v -> v != w, rel(Π_w))
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

function eliminate_len2!(Π::Presentation)
    isempty(rel(Π)) && return nothing # nothing to eliminate
    @assert length(first(rel(Π))) > 1 "eliminate relators of length 1 first"
    has_len2 = length(first(rel(Π))) == 2
    while has_len2    
        # cutoff relators of length 2
        # Reduced relators of length 2 identify to generators with each other.
        # We use MyUnionFind to identify the equivalence classes
        cutoff = 0
        uf = MyUnionFind(collect(gens(Π)))
        for (i,w) in enumerate(rel(Π))
            length(w) > 2 && break
            s, t = w
            myunion!(uf, s, t)
            cutoff = i
        end
        deleteat!(rel(Π), 1:cutoff)

        # relabel the generators in the relators with thier equivalent representatives
        dict = Dict{Int, Int}()
        for s in gens(Π)
            uf.parent[s] == s && continue
            dict[abs(s)] = sign(s)*uf.parent[s]
        end
        relabel!(Π, dict)

        # restore generator invariant
        unused_gens = collect(keys(dict))
        restore_generator_invariant!(Π, unused_gens)

        # restore cyclic-reduced invariant
        for (i,w) in enumerate(rel(Π)) 
            rel(Π)[i] = cyclic_rewrite(w)
        end
        sort!(rel(Π))

        eliminate_len1!(Π)
        isempty(rel(Π)) && break # nothing more to eliminate
        has_len2 = length(first(rel(Π))) <= 2
    end     
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
function myfind!(uf::MyUnionFind, s::Int)
    uf.parent[s] == s && return s
    uf.parent[s] = myfind!(uf, uf.parent[s])
    return uf.parent[s]
end
function myunion!(uf::MyUnionFind, s::Int, t::Int)
    s = myfind!(uf, s)
    t = myfind!(uf, t)
    s == t && return nothing
    # choose the generator that is smallest in absolute value as representative
    # note that s and t cannot be inverses of each other since s*t would be trivial 
    s, t = abs(s) > abs(t) ? (s, t) : (t, s)
    uf.parent[s] = t
    uf.parent[-s] = -t # we keep the equivalence classes symmetric
end

function eliminate_len1!(Π::Presentation)
    isempty(rel(Π)) && return nothing # nothing to eliminate
    
    has_len1 = length(first(rel(Π))) == 1
    trivial_gens = Int[]
    while has_len1
        # cutoff relators of length less than 1 and store trivial relators in stack
        stack = Int[]
        cutoff = 0
        for (i,w) in enumerate(rel(Π))
            length(w) > 1 && break
            cutoff = i
            length(w) == 0 && continue
            s = abs(first(w))
            push!(stack, s)
        end
        deleteat!(rel(Π), 1:cutoff)
        
        # remember which generators to remove 
        append!(trivial_gens, stack)

        # remove generators in stack form relations and simplify
        for (i,w) in enumerate(rel(Π))
            cyclic_rewrite!(rel(Π)[i], filter_letters(w, stack))
        end

        isempty(rel(Π)) && break
        
        sort!(rel(Π), lt=lt)
        has_len1 = length(first(rel(Π))) <= 1
    end
    # Fill holes left by the trivial generators to restore the Presentation invariants.
    restore_generator_invariant!(Π, trivial_gens)
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