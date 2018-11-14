module DynamicIterators
using Trajectories

export collectfrom, DynamicIterator

export Key, NextKey # keywords

export Evolution, evolve, timelift_evolve, from # evolution
export Evolve, TimeLift, mix, synchronize, mixture # combinators

export trace, endtime, lastiterate # trajectories

export control, timed # control

# random
export WhiteNoise, Randn, InhomogeneousPoisson,
    MetropolisHastings #,Sampled

using Random, Base.Iterators

using Base.Iterators
using Base: SizeUnknown, HasEltype
import Base: iterate, IteratorSize, @propagate_inbounds, IsInfinite, eltype, IteratorEltype,
    rand, EltypeUnknown, HasEltype


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
struct Steps{T} <: Message
    state::T
    n::Int
end
struct Sample{T,RNG} <: Message
    state::T
    rng::RNG
end
struct NewKey{S,T} <: Message
    state::S
    value::T
end
struct Key{S,T} <: Message
    state::S
    value::T
end
struct NextKey{S,T} <: Message
    state::S
    value::T
end


Sample(x) = Sample(x, Random.GLOBAL_RNG)


iterate(M::Message) = getfield(M, 1), 1
iterate(M::Message, n) = getfield(M, n + 1), n + 1

export Message, Start, Control, Value, Steps, Sample,
    NewKey, Key, NextKey

function evolve
end

dub(x) = x === nothing ? nothing : (x, x)
dedub(x) = x === nothing ? nothing : x[1]



# keyword functions shouldn't shadow non-keyword functions
# when keywords are absent
dyniterate(iter, state) = iterate(iter, state)
dyniterate(iter, ::Nothing) = iterate(iter)
dyniterate(iter, ::Start{Nothing}) = iterate(iter)

macro returnnothing(exp)
    quote let ϕ = $(esc(exp)); if ϕ === nothing; return nothing; end; ϕ end end
end

IteratorSize(::DynamicIterator) = SizeUnknown()



include("evolution.jl")
include("time.jl")
include("combinators.jl")
include("trajectories.jl")
include("random.jl")
include("control.jl")
# Examples

end
