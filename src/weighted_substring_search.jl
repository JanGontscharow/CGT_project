#Weight = Int->Int
weights(s::Int) = t -> t==s ? 100 : 1
weights() = t -> 1
weight(wt, w::MyWord) = sum(map(wt, w))

function halfweight(wt, w::MyWord)
    sum = 0
    for s in w
        sum + wt(s) > div(weight(wt, w), 2) && return sum
        sum += wt(s) 
    end
end
function halfweight_idx(wt, w::MyWord)
    sum = 0
    for (i, s) in enumerate(w)
        sum + wt(s) > div(weight(wt, w), 2) && return i-1
        sum += wt(s) 
    end
end


function weighted_substring_search(w::MyWord, v::MyWord, wt; fast=false)
    @assert weight(wt, w) <= weight(wt, v)
    # long match has to contain either l_1 or l_half or thier inverses
    l_first, l_half = w[1], w[halfweight_idx(wt, w)+length(w)%2]
    candidates1 = findall(isequal(l_first), v)
    candidates2 = findall(isequal(l_half), v)
    inv_candidates1 = findall(isequal(-l_first), v)
    inv_candidates2 = findall(isequal(-l_half), v)
    ww = w*w # used for searching in a cyclic permutation of w
    vv = v*v # used for searching in a cyclic permutation of v
    match, begin_w, begin_v, inverse = (word"", 0, 0, false) # initialize return
    #@info "$candidates1, $candidates2, $inv_candidates1, $inv_candidates2"

    candidates_arr = [candidates1, candidates2, inv_candidates1, inv_candidates2]
    x_arr = [1, halfweight_idx(wt, w)+length(w)%2, length(w), halfweight_idx(wt, w)+1]

    for i in 1:4
        x = x_arr[i]
        candidates = candidates_arr[i]
        i == 3 && inv!(ww)
        while !isempty(candidates)
            y = pop!(candidates) 
            
            # actual work is done here
            m, m_begin_ww, m_begin_vv = maximal_matching_string(x, y, ww, vv, length(w), length(v))
            
            # visualization of the match
            @info "x:$x, y:$y"
            @info "vv: $(MyWord(vv[1:m_begin_vv-1])) ⋅ $m ⋅ $(MyWord(vv[m_begin_vv+length(m):end]))"
            str = i<3 ? "ww" : "WW" 
            @info "$str: $(MyWord(ww[1:m_begin_ww-1])) ⋅ $m ⋅ $(MyWord(ww[m_begin_ww+length(m):end]))"
            
            if weight(wt, m) > halfweight(wt, w)
                fast && return m  # return first match that is heavy enough
                # store the heaviest match
                weight(wt, m)>weight(wt, match) && ((match, begin_w, begin_v, inverse) = (m, m_begin_ww, m_begin_vv, i>2)) 
            end
        end
    end

    return match, begin_w, begin_v, inverse
end