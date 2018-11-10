module DynamicIterators
using Trajectories

export evolve, collectfrom, DynamicIterator

export from # evolution
export Evolve, mix, synchronize # combinators

export trace, endtime, lastiterate # trajectories

export control, timed # control

export WhiteNoise, Randn, Sample, InhomogeneousPoisson

using Random, Base.Iterators

using Base.Iterators
using Base: SizeUnknown, HasEltype
import Base: iterate, IteratorSize, @propagate_inbounds, IsInfinite, eltype, IteratorEltype,
    rand


# keyword arguments:
# jump, key, t

"""
    DynamicIterator

`DynamicIterator`s which extend the iterator protocol by
keywords for the `iterate` function.

"""
abstract type DynamicIterator
end




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


function evolve
end

dedub(x) = x === nothing ? nothing : x[1]
evolve(r::UnitRange, i) = i < last(r) ?  i + 1 : nothing
function evolve(r::StepRange, i) # Fixme
    i = i + step(r)
    i <= last(r) ?  i : nothing
end

dub(x) = x === nothing ? nothing : (x, x)
Base.iterate(P::DynamicIterator, x) = dub(evolve(P, x))
Base.iterate(P::DynamicIterator, state; value=state) = dub(evolve(P, value))
Base.iterate(P::DynamicIterator; value=nothing) = value == nothing ?  dub(evolve(P)) : dub(evolve(P, value))

Base.IteratorSize(::DynamicIterator) = SizeUnknown()


include("evolution.jl")
include("combinators.jl")
include("trajectories.jl")
include("random.jl")
include("control.jl")
# Examples

end
