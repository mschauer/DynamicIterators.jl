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



function evolve
end

dub(x) = x === nothing ? nothing : (x, x)
dedub(x) = x === nothing ? nothing : x[1]

# keyword functions shouldn't shadow non-keyword functions
# when keywords are absent
_iterate(iter, state) = iterate(iter, state)
_iterate(iter) = iterate(iter)


# todo: remove
iterate(P::DynamicIterator, x) = dub(evolve(P, x))
_iterate(P::DynamicIterator, state; value=state) = dub(evolve(P, value))
_iterate(P::DynamicIterator; value=nothing) = value == nothing ?  dub(evolve(P)) : dub(evolve(P, value))

IteratorSize(::DynamicIterator) = SizeUnknown()


include("evolution.jl")
include("combinators.jl")
include("trajectories.jl")
include("random.jl")
include("control.jl")
# Examples

end
