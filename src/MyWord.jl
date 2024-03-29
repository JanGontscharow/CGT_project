# I want a common Alphabet for every word which has an infinite supply of letters --> Integers as Alphabet
# Inverse of a letter l is realized as -l
struct MyWord <: AbstractVector{Int}
    letters::Vector{Int}
    
    MyWord() = new(Vector{Int}())
    MyWord(s::Int) = MyWord([s])
    function MyWord(vec::Vector{Int})
        new(vec)
    end
end

# Implement AbstractVector interface
Base.length(w::MyWord) = length(w.letters)
Base.getindex(w::MyWord, i) = w.letters[i]
Base.setindex!(w::MyWord, x, i) = w.letters[i] = x
Base.size(w::MyWord) = (length(w),)

# empty word
Base.one(w::MyWord) = MyWord()
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
Base.inv(w::MyWord) = MyWord(reverse(-w))
inv!(w::MyWord) = reverse!(w.*=-1)
degree(w::MyWord) = maximum(abs(w))
Base.abs(w::MyWord) = abs.(w.letters)

# For Tietze-programs
function hasletter(w::MyWord, s::Int)
    for l in w
        abs(s) == abs(l) && return true
    end
    return false
end
function mod_letters!(w::MyWord, letters::Vector{Int})
    filter!(l -> abs(l) ∉ letters, w.letters)
end
function mod_letters(w::MyWord, letters::Vector{Int})
    return MyWord(filter(l -> abs(l) ∉ letters, w))
end

# for showing words
# computes the "run" of each letter in the word
function run_decomposition(w::MyWord)
    isone(w) && return nothing
    length(w)==1 && return [(w[1], 1)]

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
            if run == 1
                print(io, int_to_char(n))
            else
                print(io, int_to_char(n), int_to_exp(sign(n)*run))
            end
        end
    end
end
digit_to_exp = Dict(1=>'¹', 2=>'²', 3=>'³', 4=>'⁴', 5=>'⁵', 6=>'⁶', 7=>'⁷', 8=>'⁸', 9=>'⁹',
-1=>'¹', -2=>'²', -3=>'³', -4=>'⁴', -5=>'⁵', -6=>'⁶', -7=>'⁷', -8=>'⁸', -9=>'⁹', 0=>'⁰')
digit_to_subscript = Dict(1=>'₁', 2=>'₂', 3=>'₃', 4=>'₄', 5=>'₅', 6=>'₆', 7=>'₇', 8=>'₈', 9=>'₉', 0=>'₀',
-1=>'₁', -2=>'₂', -3=>'₃', -4=>'₄', -5=>'₅', -6=>'₆', -7=>'₇', -8=>'₈', -9=>'₉')

function int_to_exp(n::Int)
    n == 0 && return ""
    exp = [digit_to_exp[d] for d in reverse(digits(n))]
    #n < 0 && pushfirst!(exp, '⁻')
    return join(exp)
end

function int_to_subscript(n::Int)
    n == 0 && return ""
    subscript = [digit_to_subscript[d] for d in reverse(digits(n))]
    return join(subscript)
end