# We want our Alphabet to have an infinite supply of distinct letters --> Integers as Alphabet
# We want a word 
struct MyWord <: AbstractVector{Int64}
    letters::Vector{Int64}
end

# Implement AbstractVector interface
Base.length(w::MyWord) = length(w.letters)
Base.getindex(w::MyWord, i) = w.letters[i]
Base.setindex!(w::MyWord, x, i) = w.letters[i] = x
Base.size(w::MyWord) = (length(w),)

# empty word
Base.one(w::MyWord) = MyWord(Vector{Int64}())
Base.isone(w::MyWord) = iszero(length(w))

# for rewriting
Base.push!(w::MyWord, l::Int) = push!(w.letters, l)
Base.resize!(w::MyWord, n) = resize!(w.letters, n)
Base.popfirst!(w::MyWord) = popfirst!(w.letters)
Base.prepend!(w::MyWord, v::MyWord) = prepend!(w.letters, v)
Base.copy(w::MyWord) = one(w) * w
issuffix(v::MyWord, w::MyWord) = v ∈ suffixes(w)
isprefix(v::MyWord, w::MyWord) = v ∈ prefixes(w)
suffixes(w::MyWord) = (MyWord(w[i:end]) for i in firstindex(w):lastindex(w))
prefixes(w::MyWord) = (MyWord(w[begin:i]) for i in firstindex(w):lastindex(w))
function proper_subwords(w::MyWord)
    subwords = []
    for i in 1:length(w)
        for j in i:length(w)
            push!(subwords, w[i:j])
        end
    end
    # full word appears at iteration: length(w)
    splice!(subwords, length(w))
    # remove duplicates
    unique!(subwords)
    # make them into words
    subwords = map(v -> MyWord(v), subwords)
    return subwords
end

# LenLex(a < a^-1 < b < b^-1 ...)
function lt(v::MyWord, w::MyWord)
    if length(v) != length(w)
        return length(v)<length(w)
    end
    for i in 1:length(w)
        if abs(v[i]) != abs(w[i])
            return abs(v[i]) < abs(w[i])
        elseif v[i] != w[i]
            # inverses are larger
            return v[i] > w[i]
        end
    end
    # words are equal
    return false
end

# group-theoretic behaviour
function Base.:*(w::MyWord, v::MyWord)
    return append!(one(w), w, v)
end
Base.inv(w::MyWord) = MyWord(-reverse(w))
degree(w::MyWord) = maximum(abs.(w.letters))

function run_decomposition(w::MyWord)
    if iszero(length(w))
        return nothing
    elseif  length(w) == 1
        return [(w[1], 1)]
    end

    runs = []
    l̃, run = w[1], 1
    for l in w[2:end]
        if l == l̃
            run += 1
        else
            # a run of l̃s has finished
            Base.push!(runs, (l̃, run))
            l̃, run = l, 1
        end
    end
    Base.push!(runs, (l̃, run))
    return runs
end


function Base.show(io::IO, w::MyWord)
    if isone(w)
        print(io, "ε")
    else
        for (n, run) in run_decomposition(w)
            if run == 1 && n > 0
                print(io, int_to_char(n))
            else
                print(io, int_to_char(abs(n)), "^", sign(n)*run)
            end
        end
    end
end