module DynamicIterators
using Trajectories

export collectfrom, DynamicIterator

export Key, NextKey # keywords

export Evolution, evolve, timelift_evolve, from # evolution
export Bind, bind, Evolve, TimeLift, mix, synchronize, mixture # combinators

export trace, endtime, lastiterate # trajectories

export control, timed # control

# random
export WhiteNoise, Randn, InhomogeneousPoisson,
    MetropolisHastings #,Sampled

using Random, Base.Iterators

using Base.Iterators
using Base: SizeUnknown, HasEltype
import Base: iterate, IteratorSize, @propagate_inbounds, IsInfinite, eltype, IteratorEltype,
    rand, EltypeUnknown, HasEltype, bind


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
abstract type Message1 <: Message # to elements
end
abstract type Message2 <: Message # to elements
end

struct Start{T} <: Message1
    value::T
end
iterate(start::Start) = start.value, nothing
iterate(start::Start, ::Nothing) = nothing

struct Control{T} <: Message1
    state::T
end
iterate(start::Control) = start.state, nothing
iterate(start::Control, ::Nothing) = nothing

struct Value{T,S} <: Message2
    value::T
    state::S
end

struct Steps{T} <: Message2
    state::T
    n::Int
end
struct Sample{T,RNG} <: Message2
    state::T
    rng::RNG
end
struct NewKey{S,T} <: Message2
    state::S
    value::T
end
struct Key{S,T} <: Message2
    state::S
    value::T
end
struct NextKey{S,T} <: Message2
    state::S
    value::T
end


Sample(x) = Sample(x, Random.GLOBAL_RNG)

iterate(M::Message2) = getfield(M, 1), 1
iterate(M::Message2, Any) = getfield(M, 2), nothing
iterate(M::Message2, ::Nothing) = nothing

iterate(M::Message1) = getfield(M, 1), nothing
iterate(M::Message1, Any) = nothing

export Message, Message1, Message2, Start, Control, Value, Steps, Sample,
    NewKey, Key, NextKey

function evolve
end

dub(x) = x === nothing ? nothing : (x, x)
dedub(x) = x === nothing ? nothing : x[1]



# keyword functions shouldn't shadow non-keyword functions
# when keywords are absent
dyniterate(iter, state) = iteratefallback(iter, state)
iteratefallback(iter, state) = iterate(iter, state)
iteratefallback(iter, ::Nothing) = iterate(iter)
#dyniterate(iter::DynamicIterator, ::Nothing) = error("No starting point known for $iter. Use `from`.")
dyniterate(iter, ::Start{Nothing}) = iterate(iter)

iterate(iter::DynamicIterator) = dyniterate(iter, nothing)
iterate(iter::DynamicIterator, state) = dyniterate(iter, state)

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
