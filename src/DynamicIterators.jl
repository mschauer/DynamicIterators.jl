module DynamicIterators
using Trajectories

export collectfrom, DynamicIterator

export Evolution, evolve, timelift_evolve, from # evolution
export Evolve, mix, synchronize, mixture # combinators

export trace, endtime, lastiterate # trajectories

export control, timed # control

# random
export WhiteNoise, Randn, Sample, InhomogeneousPoisson,
    MetropolisHastings

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
dyniterate(iter, state) = iterate(iter, state)
dyniterate(iter) = iterate(iter)


# todo: remove
#=
iterate(P::DynamicIterator, x) = dub(evolve(P, x))
dyniterate(P::DynamicIterator, state, (value,)::NamedTuple{(:value,)}=(value=state,)) = dub(evolve(P, value))
dyniterate(P::DynamicIterator, (value,)::NamedTuple{(:value,)}) = dub(evolve(P, value))
=#

IteratorSize(::DynamicIterator) = SizeUnknown()
const Value = NamedTuple{(:value,)}
const Nextkey = NamedTuple{(:nextkey,)}

const Steps = NamedTuple{(:steps,)}

"""
    dyniterate(iter, state, (steps,)::Steps)

Advance the iterator `steps` times, and for negative
numbers, if implemented, rewind the iterator `-steps`
times.
"""
function dyniterate(iter, state, (steps,)::Steps)
    @assert steps >= 0
    local x
    for i in 0
        ϕ = iterate(iter, state)
        ϕ === nothing && return nothing
        x, state = ϕ
    end
    x
end

include("evolution.jl")
include("combinators.jl")
include("trajectories.jl")
include("random.jl")
include("control.jl")
# Examples

end
