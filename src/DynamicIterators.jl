module DynamicIterators
using Trajectories

export collectfrom, DynamicIterator, dyniterate

export Key, NextKey # keywords

export Evolution, evolve, timelift_evolve, from # evolution
export attach, Bind, bind, bindafter, Evolve, TimeLift, mix, synchronize, mixture # combinators

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

macro returnnothing(exp)
    quote let ϕ = $(esc(exp)); if ϕ === nothing; return nothing; end; ϕ end end
end
function evolve
end
function dyniterate
end

include("messages.jl")


Sample(x) = Sample(x, Random.GLOBAL_RNG)

Base.getindex(M::Message1) = getfield(M, 1)

iterate(M::Message2) = getfield(M, 1), 1
iterate(M::Message2, Any) = getfield(M, 2), nothing
iterate(M::Message2, ::Nothing) = nothing

iterate(M::Message1) = getfield(M, 1), nothing
iterate(M::Message1, Any) = nothing

export Message, Message1, Message2, Start, Control, Value, Steps, Sample,
    NewKey, Key, NextKey, NextKeys, BindOnce



dub(x) = x === nothing ? nothing : (x, x)
dedub(x) = x === nothing ? nothing : x[1]
dubwith(x, c) = x === nothing ? nothing : (x, c(x))


# keyword functions shouldn't shadow non-keyword functions
# when keywords are absent
iteratefallback(iter, state) = iterate(iter, state)
iteratefallback(iter, ::Nothing) = iterate(iter)
iteratefallback(iter::DynamicIterator, state) = throw(ArgumentError("Trying to use `iteration` fallback for DynamicIterator"))
iteratefallback(iter::DynamicIterator, ::Nothing) = throw(ArgumentError("Trying to use `iteration` fallback for DynamicIterator"))
dyniterate(iter, state) = iteratefallback(iter, state)

iterate(iter::DynamicIterator) = dyniterate(iter, nothing)
iterate(iter::DynamicIterator, state) = dyniterate(iter, state)


IteratorSize(::DynamicIterator) = SizeUnknown()



include("evolution.jl")
include("time.jl")
include("combinators.jl")
include("trajectories.jl")
include("random.jl")
include("control.jl")
# Examples

end
