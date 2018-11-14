

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
const GEvolution = Union{Evolution, UnitRange, StepRange}
const GDynamicIterator = Union{DynamicIterator, UnitRange, StepRange}

"""
    statefrom(E, x)

Create state for E following `x`.
"""
statefrom(E, x) = dyniterate(i.itr, (value=i.x,))
evolve(r::UnitRange, i::Integer) = i < last(r) ?  i + 1 : nothing
evolve(r::UnitRange, ::Nothing) = r.start
function evolve(r::StepRange, i) # Fixme
    i = i + step(r)
    i <= last(r) ?  i : nothing
end
evolve(r::StepRange, ::Nothing) = r.start


@inline dyniterate(r::Union{UnitRange, StepRange}, ::Nothing) = iterate(r)
@inline dyniterate(r::Union{UnitRange, StepRange}, start::Start) = iterate(r, start.value)
@inline dyniterate(r::Union{UnitRange, StepRange}, (value,)::Value) = iterate(r, value)

#@inline dyniterate(r::Union{UnitRange, StepRange}, i::Int, (value,)::Value2=(value=i,)) = iterate(r, value)

#dyniterate(E::Evolution, (value, nextkey)::NamedTuple{(:value,:nextkey)}) = dub(evolve(E, value, nextkey))
#dyniterate(E::Evolution, state, (value, nextkey)::NamedTuple{(:value,:nextkey)}) = dub(evolve(E, value, nextkey))
dyniterate(E::Evolution, (start,)::Control{<:Union{Start,Value}}, control) = dub(evolve(E, start.value, control))
#dyniterate(E::Evolution, state, (value, control)::NamedTuple{(:value,:control)}) = dub(evolve(E, value, control))
dyniterate(E::GEvolution, value::Pair) = dub(evolve(E, value))

dyniterate(E::Evolution, (value,)::Control, control) = dub(evolve(E, value, control))


#iterate(E::Evolution) = dub(evolve(E, x))
IteratorSize(::Evolution) = SizeUnknown()

dyniterate(E::Evolution, start::Union{Value,Start}) =  dub(evolve(E, start.value))
dyniterate(E::GEvolution, state) = dub(evolve(E, state))

#dyniterate(E::Evolution, state, (value,)::NamedTuple{(:value,)}) = dub(evolve(E, value))
#dyniterate(E::Evolution, ::Nothing, (value,)::NamedTuple{(:value,)}) = dub(evolve(E, value))

"""
    evolve(f)

Create the DynamicIterator corresponding to the evolution
```
    x = f(x)
```

Integer keys default to increments.
Integer control default to keys (and repetitions).

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
evolve(F::Evolve, u::Pair, args...) = timelift_evolve(F, u, args...)
#dyniterate(E::Evolve, value::Pair, (nextkey,)::Control2) = dub(evolve(E, value, nextkey))
dyniterate(E::Evolve, (value,)::Control{<:Pair}, nextkey) = dub(evolve(E, value, nextkey))


timelift_evolve(E, (i,x)::Pair) = i+1 => evolve(E, x)
function timelift_evolve(E, (i,x)::Pair{T}, j::T) where {T}
    @assert j ≥ i
    for k in 1:j-i
        x = evolve(E, x)
        x === nothing && return nothing
    end
    j => x
end
