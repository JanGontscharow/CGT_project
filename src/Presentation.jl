

# normal form for presentations
# Presentation always has generators 1:degree
# relators are sorted in ascending order
# relators are freely reduced and cylicylly reduced

struct Presentation
    degree::Int
    relators::Vector{MyWord}
    
    function Presentation(deg::Int, relators::Vector{MyWord})
        @assert deg > 0 "degree must be positive"
        @assert deg >= maximum(map(degree, relators)) "degree of words must be smaller then degree of the presentation"
        rel = map(x -> cyclic_rewrite!(one(x),x), relators)
        rel = sort(rel, lt=lt)
        new(deg, rel)
    end

    function Presentation(relators::Vector{MyWord})
        deg = maximum(map(degree, relators))
        Presentation(deg, relators)
    end
end

rel(Π::Presentation) = Π.relators
deg(Π::Presentation) = Π.degree
gens(Π::Presentation) = 1:deg(Π)

function free_rewrite!(out::MyWord, w::MyWord)
    resize!(out, 0)
    for l in w
        if isone(out)
            push!(out, l)
        elseif last(out) == -l
            resize!(out, length(out) - 1)
        else
            push!(out, l)
        end
    end
    return out
end

"""
    Let w=uvu^-1 be freely reduced where u is choosen with maximal length
    then we have ww = uvvu^-1. In particular we can obtain x := uv and
    y := vu^-1, which lets us compute v via freely reducing yx = vuu^-1v  
"""
function cyclic_rewrite!(out::MyWord, w::MyWord)
    free_rewrite!(out, w)
    out = out*out
    free_rewrite!(out, copy(out))
    
    mid = Int(length(out)/2)
    x = MyWord(out[1:mid])
    y = MyWord(out[(mid+1):end])

    free_rewrite!(out, y*x)
    mid = Int(length(out)/2)
    
    return MyWord(out[1:mid])
end


function Base.show(io::IO, Π::Presentation)
    print(io, "<", gens(Π), " | ")
    join(io, rel(Π), ", ")
    print(io, ">")
end
"""
function push!(Π::Presentation, w::MyWord)
    push!(rel(Π), w)
    sort!(rel(Π), lt=lt)
end
"""
function relabel!(Π::Presentation, s::Int, t::Int)
    @assert 0<s<=deg(Π) && 0<t<=deg(Π)
    for w in rel(Π)
        for (i, l) in enumerate(w)
            if abs(l)==s
                w[i] = sign(l)*t
            elseif abs(l)==t
                w[i] = sign(l)*s
            end
        end
    end 
end


