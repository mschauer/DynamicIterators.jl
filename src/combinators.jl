
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
