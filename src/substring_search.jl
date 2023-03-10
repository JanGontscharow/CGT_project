halflen(w::MyWord) = div(length(w),2)

"""
    find_long_matching_substring(w, v; fast=false)

# Arguments
- `w::MyWord`: shorter relator of a presentation
- `v::MyWord`: longer relator of a presentation
- `fast::bool`: determines whether the function returns the first or the longest match
# Returns
a common substring `u` of `w` and `v` such that 
`u` has at least half the length of `w`

"""
function find_long_matching_substring(w::MyWord, v::MyWord; fast=false)
    @assert length(w) <= length(v)
    # long match has to contain either l_1 or l_half or thier inverses
    l_first, l_half = w[1], w[halflen(w)+length(w)%2]
    candidates1 = findall(isequal(l_first), v)
    candidates2 = findall(isequal(l_half), v)
    inv_candidates1 = findall(isequal(-l_first), v)
    inv_candidates2 = findall(isequal(-l_half), v)
    ww = w*w # used for searching in a cyclic permutation of w
    vv = v*v # used for searching in a cyclic permutation of v
    match = nothing # stores longest valid length
    @info "$candidates1, $candidates2, $inv_candidates1, $inv_candidates2"

    """
        The algorithm for the majority follows the algorithm decribed in the papers.
        In particular we make use of the following observartion  
            any "long" common substring must contain the first letter of the 
            short relator or a letter half way round that relator
        So my implementation only looks for matchings that contain the first letter or
        the middle letter of w.
        1. identifies the places where there could be such a substring, 
            i.e. the candidates
        2. get maximal matching substrings at the candidates by
            2.1 scanning first left from the candidate until they no longer match up
            2.2 then we do the same but scanning to the right
    """

    candidates_arr = [candidates1, candidates2, inv_candidates1, inv_candidates2]
    x_arr = [1, halflen(w)+length(w)%2, length(w), halflen(w)+1]
    for i in 1:4
        x = x_arr[i]
        candidates = candidates_arr[i]
        i == 3 && inv!(ww)
        while !isempty(candidates)
            y = pop!(candidates) 
            @info "x:$x, y:$y"
            # actual work is done here
            m, m_begin_ww, m_begin_vv = maximal_matching_string(x, y, ww, vv, length(w), length(v))
            # visualization of the match
            @info "vv: $(MyWord(vv[1:m_begin_vv-1])) ⋅ $m ⋅ $(MyWord(vv[m_begin_vv+length(m):end]))"
            str = i<3 ? "ww" : "WW"
            @info "$str: $(MyWord(ww[1:m_begin_ww-1])) ⋅ $m ⋅ $(MyWord(ww[m_begin_ww+length(m):end]))"
            
            if length(m) > halflen(w)
                fast && return m  # return first match that is long enough
                # store the longest match
                if isnothing(match)
                    match = m
                else
                    match = length(m)>length(match) ? m : match
                end 
            end
        end
    end

    return match
end


function maximal_matching_string(x::Int, y::Int, ww::MyWord, vv::MyWord, len_w, len_v)
    # center ww at x for matching
    circshift!(ww, x-1) 
    # center vv at y for matching 
    circshift!(vv, y-1) 
    # find beginning of match
    m_begin = len_v+1

    #@info "find beginning..."
    for i ∈ 0:-1:2-len_w
        #@info "$(MyWord(vv[len_v+i])) == $(MyWord(ww[len_w+i]))?"
        vv[len_v+i] == ww[len_w+i] || break
        m_begin = len_v+i
    end

    # find end of match
    m_end = len_v+1
    #@info "find end..."
    for i in 2:len_w+m_begin-(len_v+1)
        #@info "$(MyWord(vv[len_v+i])) == $(MyWord(ww[len_w+i]))?"
        vv[len_v+i] == ww[len_w+i] || break
        m_end = len_v+i
    end
   
    m = MyWord(vv[m_begin:m_end])
    
    # undo shifting 
    circshift!(ww, -x+1)
    circshift!(vv, -y+1)
    
    # compute beginnings indices in ww, vv 
    m_begin_ww = (m_begin + len_w - len_v)+x-1 % len_w
    m_begin_vv = m_begin+y-1 % len_v
    
    return m, m_begin_ww, m_begin_vv
end