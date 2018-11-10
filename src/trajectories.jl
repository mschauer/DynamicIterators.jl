
endtime(T) = (t, _)::Pair -> t >= T


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

@propagate_inbounds iterate(i::From) = dyniterate(i.itr, (value=i.x,))
@propagate_inbounds iterate(i::From, u) = dyniterate(i.itr, u)


eltype(::Type{From{I,T}}) where {I<:DynamicIterator,T} = T
eltype(::Type{<:From{I}}) where {I} = eltype(I)

IteratorEltype(::Type{<:From{<:DynamicIterator}}) = HasEltype()
IteratorEltype(::Type{<:From{I}}) where {I} = IteratorEltype(I)

IteratorSize(::Type{<:From{I}}) where {I} = Iterators.rest_iteratorsize(IteratorSize(I))


"""
    trace(P, u::Pair, stop; register = x->true)

Trace the trajectoy of a keyed Dynamic iterator
as `Trajectory`.
"""
function trace(P, u::Pair, stop; register = x->true)
    X = trajectory((u,))
    while !stop(u)
        u = evolve(P, u)
        register(u) && push!(X, u)
    end
    X
end

function lastiterate(P::DynamicIterator, u, stop=u->false)
    while !stop(u)
        u = evolve(P, u)
        u === nothing && return u
    end
    u
end
lastiterate(P, u, stop=u->false) = _lastiterate(P, u, stop)

function _lastiterate(P, u, stop=u->false)
    if !stop(u)
        ϕ = dyniterate(P, (value=u,))
        ϕ === nothing && return u
        u, state = ϕ
        while !stop(u)
            ϕ = dyniterate(P, state, (value=u,))
            ϕ === nothing && return u
            u, state = ϕ
        end
    end
    u
end
