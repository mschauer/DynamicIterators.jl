

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

evolve(r::UnitRange, i::Integer) = i < last(r) ?  i + 1 : nothing
evolve(r::UnitRange, ::Nothing) = r.start
function evolve(r::StepRange, i) # Fixme
    i = i + step(r)
    i <= last(r) ?  i : nothing
end
evolve(r::StepRange, ::Nothing) = r.start


@inline dyniterate(r::Union{UnitRange, StepRange}, ::Nothing) = iterate(r)
@inline dyniterate(r::Union{UnitRange, StepRange}, start::Start) = iterate(r, start.value)


dyniterate(E::Evolution, (start,)::Control{<:Union{Start,Value}}, control) = dubwith(evolve(E, start.value, control), Control)
dyniterate(E::GEvolution, value::Pair) = dub(evolve(E, value))
dyniterate(E::Evolution, (value,)::Control, control) = dubwith(evolve(E, value, control), Control)


IteratorSize(::Evolution) = SizeUnknown()

dyniterate(E::Evolution, start::Union{Value,Start}) = dub(evolve(E, start.value))
dyniterate(E::GEvolution, state) = dub(evolve(E, state))

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

dyniterate(E::Evolve, (value,)::Control{<:Pair}, nextkey) = dubwith(evolve(E, value, nextkey), Control)


timelift_evolve(E, (i,x)::Pair) = i+1 => evolve(E, x)
function timelift_evolve(E, (i,x)::Pair{T}, j::T) where {T}
    @assert j ≥ i
    for k in 1:j-i
        x = evolve(E, x)
        x === nothing && return nothing
    end
    j => x
end
