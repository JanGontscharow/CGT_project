
"""
Presentation with three invariants
1. Presentation has always generators from 1:n
2. relators are non-trivial and in ascending order
3. relators are cyliclly reduced
"""

mutable struct Presentation
    degree::Int
    relators::Vector{MyWord}
    
    function Presentation(deg::Int, relators::Vector{MyWord})
        @assert deg > 0 "degree must be positive"
        #@info "fdstreeterz $deg, $relators"
        isempty(relators) && return new(deg, [])
        @assert maximum(map(degree, relators))<=deg "degree of words must be smaller then degree of the presentation"

        # enforce invariants
        rel = map(x -> cyclic_rewrite(x), relators)
        unique!(rel)
        sort!(rel, lt=lt)
        isone(first(rel)) && deleteat!(rel, 1)
        new(deg, rel)
    end

    function Presentation(relators::Vector{MyWord})
        @assert !isempty(relators)
        deg = maximum(map(degree, relators))
        Presentation(deg, relators)
    end
end

Base.copy(Π::Presentation) = Presentation(rel(Π))
Base.:(==)(Π::Presentation, Π2::Presentation) = rel(Π)==rel(Π2) && deg(Π)==deg(Π2)

rel(Π::Presentation) = Π.relators
deg(Π::Presentation) = Π.degree
gens(Π::Presentation) = 1:deg(Π)
decdeg!(Π::Presentation) = decdeg!(Π, 1)
decdeg!(Π::Presentation, n::Int) = setdeg!(Π, deg(Π)-n)
function setdeg!(Π::Presentation, deg::Int)
    #isempty(rel(Π)) || @assert maximum(map(degree, rel(Π))) <= deg "degree of relators must be less or equal to the degree"
    @assert 0 < deg "degree must be positive $deg, $Π"
    Π.degree = deg
end

free_rewrite(w::MyWord) = free_rewrite!(one(w), w)
function free_rewrite!(out::MyWord, w::MyWord)
    resize!(out, 0)
    for l in w
        if length(out)==0
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
    Let w = uvu^-1 be freely reduced where u is choosen with maximal length
    then we have ww = uvvu^-1. In particular we can obtain x := uv and
    y := vu^-1, which lets us compute v via freely reducing yx = vuu^-1v  
"""
cyclic_rewrite(w::MyWord) = cyclic_rewrite!(one(w), w) 
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
    print(io, "<", join(map(int_to_char, gens(Π)), ", "), " | ")
    join(io, rel(Π), ", ")
    print(io, ">")
end

# for adding relators in a sorted manner
function Base.push!(Π::Presentation, w::MyWord; duplicates=false, lt=lt)
    # insert according to lt
    for (i,v) in enumerate(rel(Π))
        lt(v, w) && continue
        # if duplicate no insert
        (v == w && duplicates) || insert!(Π.relators, i, w)
        return
    end
    # biggest relators
    push!(rel(Π), w) 
end
# for replacing relations
function replace_rel!(Π::Presentation, index::Int, w::MyWord; duplicates=false, lt=lt)
    deleteat!(Π.relators, index)
    push!(Π, w, lt=lt)
end


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

function relabel!(Π::Presentation, dict::Dict{Int,Int})
    isempty(dict) && return nothing
    @assert maximum(abs.(values(dict)))<=deg(Π) "cannot relabel a letter to one that exceeds the degree"
    @assert minimum(keys(dict)) > 0 "keys must be positive"
    to_relabel = collect(keys(dict))
    for w in rel(Π)
        for (i, l) in enumerate(w)
            if abs(l) ∈ to_relabel
                w[i] = sign(l)*dict[abs(l)]
            end
        end
    end
end


