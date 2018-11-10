
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
function evolve(M::Mix, (p, q))
    p = evolve(M.P, p)
    p === nothing && return nothing
    q = evolve(M.Q, q)
    q === nothing && return nothing
    M.f(p, q)
end

mix(f, P, Q) = Mix(f, P, Q)



"""
    evolve(f)

Create the DynamicIterator corresponding to the evolution
```
    x = f(x)
```

Integer keys default to increments.
Integer control defaults to repetition.

```
julia> collect(take(from(Evolve(x->x + 1), 10), 5))
5-element Array{Any,1}:
 10
 11
 12
 13
 14
```
"""
struct Evolve{T} <: DynamicIterator
    f::T
end

evolve(F::Evolve, x) = F.f(x)
evolve(F::Evolve, (i,x)::Pair) = i+1 => F.f(x)

function evolve(F::Evolve, (i,x)::Pair{T}, j::T) where {T}
    @assert j ≥ i
    for k in 1:j-i
        x = evolve(F, x)
        x === nothing && return nothing
    end
    j => x
end

struct Synchronize{T} <: DynamicIterator
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
