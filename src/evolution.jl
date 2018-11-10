

"""
    Evolution

Evolutions define
```
    evolve(iter, value::T)::T
```
and possibly
```
    evolve(iter, key=>value)
```

They guarantee `HasEltype()` and `eltype(iter) == T`.
"""
abstract type Evolution <: DynamicIterator
end

evolve(r::UnitRange, i) = i < last(r) ?  i + 1 : nothing
function evolve(r::StepRange, i) # Fixme
    i = i + step(r)
    i <= last(r) ?  i : nothing
end


@inline _iterate(r::Union{UnitRange, StepRange}; value=first(r)) = iterate(r, value)
@inline _iterate(r::Union{UnitRange, StepRange}, i; value=i) = iterate(r, value)

iterate(E::Evolution, x=first(E)) = dub(evolve(E, x))
IteratorSize(::Evolution) = SizeUnknown()

@inline _iterate(E::Evolution, state; value=state) = dub(evolve(E, value))
@inline _iterate(E::Evolution; value=first(E)) = dub(evolve(E, value))

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
struct Evolve{T} <: Evolution
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

"""
    from(P, x)

Attach a starting state to a `DynamicIterator`.


## Example
```
collect(from(1:20, 10))
```
"""
struct From{I,T} <: DynamicIterator
    itr::I
    x::T
end
from(i, x) = From(i, x)

collectfrom(it, x) = collect(from(it, x))
collectfrom(it, x, n) = collect(take(from(it, x), n))

@propagate_inbounds iterate(i::From) = i.x, i.x
@propagate_inbounds iterate(i::From, x) = iterate(i.itr, x)

eltype(::Type{From{I,T}}) where {I<:DynamicIterator,T} = T
eltype(::Type{<:From{I}}) where {I} = eltype(I)

IteratorEltype(::Type{<:From{<:DynamicIterator}}) = HasEltype()
IteratorEltype(::Type{<:From{I}}) where {I} = IteratorEltype(I)

IteratorSize(::Type{<:From{I}}) where {I} = Iterators.rest_iteratorsize(IteratorSize(I))
