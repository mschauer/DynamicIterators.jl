

struct Bind{T,S} <: DynamicIterator
    Y::S
    P::T
end
bind(Y,P::DynamicIterator) = Bind(Y,P)

function dyniterate(M::Bind, start::Start)
    v, q = @returnnothing dyniterate(M.Y, nothing)
    u, p = @returnnothing dyniterate(M.P, start, v)
    u, (q, p)
end
function dyniterate(M::Bind, ::Nothing)
    v, q = @returnnothing dyniterate(M.Y, nothing)
    u, p = @returnnothing dyniterate(M.P, nothing, v)
    u, (q, p)
end
function dyniterate(M::Bind, (q, p)::Tuple)
    v, q = @returnnothing iterate(M.Y, q)
    u, p = @returnnothing dyniterate(M.P, p, v)
    u, (q, p)
end


struct BindAfter{T,S} <: DynamicIterator
    Y::S
    P::T
end
bindafter(Y,P::DynamicIterator) = BindAfter(Y,P)

function dyniterate(M::BindAfter, start::Start)
    v, q = @returnnothing dyniterate(M.Y, nothing)
    u, p = @returnnothing dyniterate(M.P, start)
    u, (v, q, p)
end
function dyniterate(M::BindAfter, ::Nothing)
    v, q = @returnnothing dyniterate(M.Y, nothing)
    u, p = @returnnothing dyniterate(M.P, nothing)
    u, (q, p)
end
function dyniterate(M::BindAfter, (v, q, p)::Tuple)
    w, q = @returnnothing iterate(M.Y, q)
    u, p = @returnnothing dyniterate(M.P, p, v)
    u, (w, q, p)
end


"""
    struct Mix{F,T,S} <: DynamicIterator
        f::F
        P::T
        Q::S
    end

see `mix`
"""
struct Mix{F,T,S} <: DynamicIterator
    f::F
    P::T
    Q::S
end


dyniterate(M::Mix{<:Any, <:GEvolution, <:GEvolution}, u) = dub(evolve(M, u))
dyniterate(M::Mix{<:Any, <:GEvolution, <:GEvolution}, u::Value) = dub(evolve(M, u.value))
dyniterate(M::Mix{<:Any, <:GEvolution, <:GEvolution}, u::Start) = dub(evolve(M, u.value))
evolve(M::Mix{<:Any, <:GEvolution, <:GEvolution}, (i, pq)::Pair) = i+1 => evolve(M, pq)

function evolve(M::Mix{<:Any, <:GEvolution, <:GEvolution}, (p, q)::Tuple)
    p = @returnnothing evolve(M.P, p)
    q = @returnnothing evolve(M.Q, q)
    M.f(p, q)
end

function dyniterate(M::Mix, (value,)::Start)
    x, y = value
    ϕ = @returnnothing dyniterate(M.P, Start(x))
    x, p = ϕ
    ψ = @returnnothing dyniterate(M.Q, Start(y))
    y, q = ψ
    x, y = M.f(x, y)
    (x, y), (p, q)
end
function dyniterate(M::Mix, (value, u)::Value)
    p, q = u
    x, y = value
    ϕ = @returnnothing dyniterate(M.P, Value(x, p))
    x, p = ϕ
    ψ = @returnnothing dyniterate(M.Q, Value(y, q))
    y, q = ψ
    x, y = M.f(x, y)
    (x, y), (p, q)
end

"""

    mix(f, P, Q)

Mix two dynamic iterators by applying the mixing function `f`
to their states:

    x, y = f(x, y)

## Example
```
julia> collectfrom(mix((x,y) -> (x+y, y), 1:10, 1:10), (1,1))
3-element Vector{Tuple{Int64, Int64}}:
 (4, 2)
 (8, 3)
 (13, 4)
```

Each step here corresponds to a hidden step of the "zipped" iterators,
followed by application of `f` before returning. In this case the evolution is

(1,1) -> (2,2) -> (4,2)
(4,2) -> (5,3) -> (8,3)
(8,3) -> (9,4) -> (13,4)
(13,4) -> nothing

This `nothing` causes `mix` to return `nothing` as well, which in turn stops the
`collectfrom`.
"""
mix(f, P, Q) = Mix(f, P, Q)


"""

    mixture(I, Ps)

    evolve(M::Mixture, (i, x))
Choose evolution in `Ps[i]` for `x` using iterate `i` of `I`.
"""
struct Mixture{S,T} <: Evolution
    I::S
    Ps::T
end


evolve(M::Mixture, (i, ix)::Pair) = i+1 => evolve(M, ix)

function evolve(M::Mixture, (i, x)::Tuple)
    i = evolve(M.I, i)
    x = evolve(M.Ps[i], x)
    (i, x)
end

mixture(I, args) = Mixture(I, args)





struct Synchronize{T} <: Evolution
    Ps::T
end

"""
    synchronize
"""
synchronize(args...) = Synchronize(args)



state((t, xs), M::Synchronize) = (t => xs, Tuple(evolve.(M.Ps, Pair.(t, xs))))


function evolve(M::Synchronize, ((t, x), next)::T) where {T}
    all(u === nothing for u in next) && return nothing
    tᵒ = minimum(first.(Iterators.filter(x -> !(t===nothing), next))) #use isnothing
    xᵒ = Any[]
    nextᵒ = Any[]
    for  (P, xᵢ, u) in zip(M.Ps, x, next)
        if !(u === nothing) && u[1] == tᵒ
            xᵢ = u[2]
            u = evolve(P, u)
        end
        push!(xᵒ, xᵢ)
        push!(nextᵒ, u)
    end
    (tᵒ => Tuple(xᵒ), Tuple(nextᵒ))::T
end
