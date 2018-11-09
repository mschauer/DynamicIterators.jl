module DynamicIterators
using Trajectories

export evolve, collectfrom, DynamicIterator

export Evolve, mix # combinators

export trace, endtime # trajectories

export control, timed # control

export WhiteNoise, Randn, Sample

using Random, Base.Iterators

using Base.Iterators
using Base: SizeUnknown, HasEltype
import Base: iterate, IteratorSize, @propagate_inbounds, IsInfinite, eltype, IteratorEltype


abstract type DynamicIterator
end

function evolve
end

dedub(x) = x === nothing ? nothing : x[1]
evolve(r::UnitRange, i) = i < last(r) ?  i + 1 : nothing

dub(x) = x === nothing ? nothing : (x, x)
Base.iterate(P::DynamicIterator, x) = dub(evolve(P, x))
Base.IteratorSize(::DynamicIterator) = SizeUnknown()


include("evolution.jl")
include("combinators.jl")
include("trajectories.jl")
include("random.jl")

# Examples

end
