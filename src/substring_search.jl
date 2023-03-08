#permutations(w::MyWord) = (MyWord(w[i+1:end])*MyWord(w[begin:i]) for i in lastindex(w):-1:firstindex(w))

"""
    find_long_matching_substring(w, v)

# Arguments
- `w::MyWord`: shorter relator of a presentation
- `v::MyWord`: longer relator of a presentation

# Returns
a common substring `u` of `w` and `v` such that 
`u` has at least half the length of `w`

"""
function find_long_matching_substring(w::MyWord, v::MyWord)
    @assert length(w) <= length(v)
    # long match has to contain either l_1 or l_half
    l_first, l_half = w[1], w[halflen(w)]
    candidates1 = findall(isequal(l_first), v)
    candidates2 = findall(isequal(l_half), v)
    ww = w*w
    vv = v*v
    """
        The algorithm is inspired by the following observation in one of the papers:
            any "long" common substring must contain the first letter of the 
            short relator or a letter half way round that relator
        My implementation only looks for matchings that contain the first letter or
        the middle letter of w.
        1. identifies the places where there could be such a substring, 
            i.e. the candidates
        2. get maximal matching substrings at the candidates by
            2.1 scanning first left from the candidate until they no longer match up
            2.2 then we do the same but scanning to the right
    """

    while !isempty(candidates1) || !isempty(candidates2)

        if !isempty(candidates1)
            x = 1
            y = pop!(candidates1) 

            m, m_begin_ww, m_begin_vv = subroutine!(x, y, ww, vv, length(w), length(v))
            @info "$m"
            @info "vv: $(MyWord(vv[1:m_begin_vv-1])) ⋅ $m ⋅ $(MyWord(vv[m_begin_vv+length(m):end]))"
            @info "ww: $(MyWord(ww[1:m_begin_ww-1])) ⋅ $m ⋅ $(MyWord(ww[m_begin_ww+length(m):end]))"
            
            length(m) > halflen(w)-length(w)%2 && return m
        end

        if !isempty(candidates2)
            x = halflen(w)
            y = pop!(candidates2) 

            m, m_begin_ww, m_begin_vv = subroutine!(x, y, ww, vv, length(w), length(v))
            @info "vv: $(MyWord(vv[1:m_begin_vv-1])) ⋅ $m ⋅ $(MyWord(vv[m_begin_vv+length(m):end]))"
            @info "ww: $(MyWord(ww[1:m_begin_ww-1])) ⋅ $m ⋅ $(MyWord(ww[m_begin_ww+length(m):end]))"
            
            length(m) > halflen(w)-length(w)%2 && return m
        end
    end
end

function subroutine!(x::Int, y::Int, ww::MyWord, vv::MyWord, len_w, len_v)
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
    #@info "match looks like this $m"
    
    # undo shifting 
    circshift!(ww, -x+1)
    circshift!(vv, -y+1)
    
    # compute beginnings indices in ww, vv
    m_begin_ww = ((m_begin-x+1) % 2*len_w) + 1
    m_begin_vv = ((m_begin-y+1) % 2*len_v) + 1
    
    return m, m_begin_ww, m_begin_vv
end

halflen(w::MyWord) = round(Int, length(w)/2, RoundUp)