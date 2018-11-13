module DynamicIterators
using Trajectories

export collectfrom, DynamicIterator

export Key, Control2, NextKey, Value2 # keywords

export Evolution, evolve, timelift_evolve, from # evolution
export Evolve, TimeLift, mix, synchronize, mixture # combinators

export trace, endtime, lastiterate # trajectories

export control, timed # control

# random
export WhiteNoise, Randn, InhomogeneousPoisson,
    MetropolisHastings #,Sample

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

abstract type Message
end

struct Start{T} <: Message
    value::T
end

struct Control{T} <: Message
    state::T
end

struct Value{T,S} <: Message
    value::T
    state::S
end

iterate(M::Message) = getfield(M, 1), 1
iterate(M::Message, n) = getfield(M, n + 1), n + 1

export Message, Start, Control, Value

function evolve
end

dub(x) = x === nothing ? nothing : (x, x)
dedub(x) = x === nothing ? nothing : x[1]



# keyword functions shouldn't shadow non-keyword functions
# when keywords are absent
dyniterate(iter, state) = iterate(iter, state)
dyniterate(iter, ::Nothing) = iterate(iter)
dyniterate(iter) = dyniterate(iter, nothing)

macro returnnothing(exp)
    quote let ϕ = $(esc(exp)); if ϕ === nothing; return nothing; end; ϕ end end
end

# todo: remove
#=
iterate(P::DynamicIterator, x) = dub(evolve(P, x))
dyniterate(P::DynamicIterator, state, (value,)::NamedTuple{(:value,)}=(value=state,)) = dub(evolve(P, value))
dyniterate(P::DynamicIterator, (value,)::NamedTuple{(:value,)}) = dub(evolve(P, value))
=#

IteratorSize(::DynamicIterator) = SizeUnknown()
const Value2 = NamedTuple{(:value,)}
const Key = NamedTuple{(:key,)}
const NextKey = NamedTuple{(:nextkey,)}
const NewKey = NamedTuple{(:newkey,)}
const Control2 = NamedTuple{(:control,)}
const Steps = NamedTuple{(:steps,)}

macro NT(args...)
    :(NamedTuple{($(args)...,)})
end


include("evolution.jl")
include("time.jl")
include("combinators.jl")
include("trajectories.jl")
include("random.jl")
include("control.jl")
# Examples

end
