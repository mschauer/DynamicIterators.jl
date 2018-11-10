


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
