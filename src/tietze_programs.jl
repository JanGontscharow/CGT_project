"""
function safer_havas_program!(Π::Presentation)
    changes_made = true
    while changes_made
        changes_made = false
        
        eliminate_len1!(Π)
        eliminate_nonsquare_len2!(Π)
        # try applyling T4
        for s in gens(Π)
            if t4_check(Π, s)
                t4!(Π, s, check=false)
                changes_made = true
                break
            end
        end
        sort!(rel(Π), lt=lt)
        
        for (i,w) ∈ enumerate(rel(Π))
            changes_made && break 

            for (j,v) ∈ enumerate(rel(Π)[i+1:end])
                # substring search
                match, begin_w, begin_v, inverse = substring_search(w, v)
                isone(match) && continue
                changes_made = true

                # align the w and v such that the beginning of the match is the beginning of the word 
                inverse && inv!(w)
                circshift!(w, begin_w-1)
                circshift!(v, begin_v-1)

                # replace match in v with the inverse of the non-matching part of w
                w_rest_rev = -w[length(match)+1:end] # the inverse of the non matching part but reversed
                reverse!(v) # reversing for easy replacement
                resize!(v, length(v)-length(match)) # remove matching part
                append!(v, w_rest_rev) # append the inverse of non-matching part of w
                cyclic_rewrite!(v, copy(v))
                reverse!(v) # unreverse
                
                deleteat!(rel(Π), i+j)
                sort!(rel(Π))
                #replace_rel!(Π, i+j, v) 
                break
            end
            restore_nontrivial_invariant!(Π) # also restores uniqueness
        end
    end
    return Π
end
"""


function havas_program!(Π::Presentation)
    changes_made = true
    while changes_made
        changes_made = false
        
        eliminate_len1!(Π)
        eliminate_nonsquare_len2!(Π)
        # try applyling T4
        for s in gens(Π)
            if t4_check(Π, s)
                t4!(Π, s, check=false)
                changes_made = true
                break
            end
        end
        
        for (i,w) ∈ enumerate(rel(Π))
            changes_made && break 

            for (j,v) ∈ enumerate(rel(Π)[i+1:end])
                # substring search
                match, begin_w, begin_v, inverse = substring_search(w, v)
                isone(match) && continue
                changes_made = true

                # align the w and v such that the beginning of the match is the beginning of the word 
                inverse && inv!(w)
                circshift!(w, begin_w-1)
                circshift!(v, begin_v-1)

                # replace match in v with the inverse of the non-matching part of w
                w_rest_rev = -w[length(match)+1:end] # the inverse of the non matching part but reversed
                reverse!(v) # reversing for easy replacement
                resize!(v, length(v)-length(match)) # remove matching part
                append!(v, w_rest_rev) # append the inverse of non-matching part of w
                cyclic_rewrite!(v, copy(v))
                reverse!(v) # unreverse
                
                replace_rel!(Π, i+j, v, duplicates=true) 
                # replace_rel! keeps the slice [i+j:end] of rel(Π) the same, so no need to break
                # uniqueness however gets lost so we need to restore it later
            end
            restore_nontrivial_invariant!(Π) # also restores uniqueness
        end
    end
    return Π
end


function weighted_havas_program!(Π::Presentation, wt)
    # Important
    sort!(rel(Π), lt=lt(wt))
    changes_made = true
    iter=0
    t4s=0
    matches=0
    while changes_made
        @assert iter<500 "$t4s, $t4s, $matches"
        changes_made = false
        weighted_eliminate_len1!(Π, wt)
        weighted_eliminate_nonsquare_len2!(Π, wt)
        # try applyling T4
        for s in gens(Π)
            if t4_check(Π, s)
                t4!(Π, s, check=false)
                changes_made = true
                t4s+=1
                break
            end
        end
        # need to sort because of relabeling of gens
        sort!(rel(Π), lt=lt(wt))

        for (i,w) ∈ enumerate(rel(Π))
            changes_made && break 
            for (j,v) ∈ enumerate(rel(Π)[i+1:end])
                # substring search
                match, begin_w, begin_v, inverse = weighted_substring_search(w, v, wt)
                isone(match) && continue
                changes_made = true
                matches+=1
                # align the w and v such that the beginning of the match is the beginning of the word 
                inverse && inv!(w)
                circshift!(w, begin_w-1)
                circshift!(v, begin_v-1)

                # replace match in v with the inverse of the non-matching part of w
                w_rest_rev = -w[length(match)+1:end] # the inverse of the non matching part but reversed
                reverse!(v) # reversing for easy replacement
                resize!(v, length(v)-length(match)) # remove matching part
                append!(v, w_rest_rev) # append the inverse of non-matching part of w
                cyclic_rewrite!(v, copy(v))
                reverse!(v) # unreverse
                
                replace_rel!(Π, i+j, v, duplicates=true, lt=lt(wt)) 
                # replace_rel! keeps the slice [i+j:end] of rel(Π) the same, so no need to break
                # uniqueness however gets lost so we need to restore it later
            end
            restore_nontrivial_invariant!(Π) # also restores uniqueness
        end
    end
    return Π
end





"""
    The weighted versions of the eliminations only change the sorting of the relators
    and how the length 1 relators are search for (we can no longer just cut off the 
    bottom part of the relators)
"""
# assumes Presentation to be sorted be lt(wt)
function weighted_eliminate_nonsquare_len2!(Π::Presentation, wt=wt)
    isempty(rel(Π)) && return Π # nothing to eliminate
    @assert all([length(w) > 1 for w in rel(Π)]) "eliminate relators of length 1 first"

    # We use MyUnionFind to determine the equivalence of the generators and thier inverses
    uf = MyUnionFind(collect(gens(Π)))

    while true    
        nonsquare_len2 = []
        for (i,w) in enumerate(rel(Π))
            length(w) > 2 && continue
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
        restore_reduced_invariant!(Π, lt=lt(wt))
        restore_nontrivial_invariant!(Π)

        # eliminate relators of length 1
        weighted_eliminate_len1!(Π, wt)

        # nothing more to eliminate
        isempty(rel(Π)) && break
    end     

    unused_gens = [s for s in gens(Π) if s != myfind(uf, s)]
    restore_generator_invariant!(Π, unused_gens)
    return Π
end



# assumes Presentation to be sorted by lt(wt)
function weighted_eliminate_len1!(Π::Presentation, wt)
    isempty(rel(Π)) && return Π # nothing to eliminate

    has_len1 = length(first(rel(Π))) == 1
    trivial_gens = Int[]
    while true
        # find length 1 relators and pop them and store them into stack
        stack = Int[]
        to_delete = Int[]
        for (i,w) in enumerate(rel(Π))
            length(w) > 1 && continue
            s = abs(first(w))
            push!(stack, s)
            push!(to_delete, i)
        end
        isempty(to_delete) && break # ending condition 
        deleteat!(rel(Π), to_delete)

        # remember which generators to remove 
        append!(trivial_gens, stack)
        # remove trivial generators from relators 
        map!(w -> mod_letters(w, stack), rel(Π), rel(Π))
        # restore invariants except generator invariant 
        sort!(rel(Π), lt=lt(wt))    
        restore_reduced_invariant!(Π, lt=lt(wt))
        restore_nontrivial_invariant!(Π)    

        isempty(rel(Π)) && break
    end
    # Fill holes left by the trivial generators to restore the Presentation invariants.
    restore_generator_invariant!(Π, trivial_gens)
    return Π
end

