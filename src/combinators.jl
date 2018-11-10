
"""

    mix(f, P, Q)

Mix two dynamic iterators by applying the mixing function `f`
to their states:

    x, y = f(x, y)

## Example
```
collectfrom(Mix((x,y) -> (x+y, y), 1:0, 1:100), (1,1)))
# last value 100*101/2 + 100
```
"""
struct Mix{F,T,S} <: DynamicIterator
    f::F
    P::T
    Q::S
end

#_iterate(M::Mix{<:Any, <:GEvolution, <:GEvolution}, u) = _iterate_(M, (value=u,))
#_iterate(M::Mix{<:Any, <:GEvolution, <:GEvolution}, v::Value) = _iterate_(M, v)
#_iterate(M::Mix, v::Value) = _iterate_(M, v)
_iterate(M::Mix{<:Any, <:GEvolution, <:GEvolution}, u) = dub(evolve(M, u))
_iterate(M::Mix{<:Any, <:GEvolution, <:GEvolution}, (u,)::Value) = dub(evolve(M, u))

function evolve(M::Mix{<:Any, <:GEvolution, <:GEvolution}, (p, q))
    p = evolve(M.P, p)
    p === nothing && return nothing
    q = evolve(M.Q, q)
    q === nothing && return nothing
    M.f(p, q)
end

function _iterate(M::Mix, (value,)::Value)
    x, y = value
    ϕ = _iterate(M.P, (value=x,))
    ϕ === nothing && return nothing
    x, p = ϕ
    ψ = _iterate(M.Q, (value=y,))
    ψ === nothing && return nothing
    y, q = ψ
    x, y = M.f(x, y)
    (x, y), (p, q)
end
function _iterate(M::Mix, u, (value,)::Value=(value=u))
    p, q = u
    x, y = value
    ϕ = _iterate(M.P, p, (value=x,))
    ϕ === nothing && return nothing
    x, p = ϕ
    ψ = _iterate(M.Q, q, (value=y,))
    ψ === nothing && return nothing
    y, q = ψ
    x, y = M.f(x, y)
    (x, y), (p, q)
end


mix(f, P, Q) = Mix(f, P, Q)




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
    tᵒ = minimum(first.(Iterators.filter(!isnothing, next)))
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
