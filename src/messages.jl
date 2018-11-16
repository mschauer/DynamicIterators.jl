abstract type Message1 <: Message # to elements
end
abstract type Message2 <: Message # to elements
end


"""
    Start(value) <: Message

Transient message to start to iterate from the state corresponding to `value`.
"""
struct Start{T} <: Message1
    value::T
end
struct Control{T} <: Message1
    state::T
end


"""
    BindOnce(state, control)

"""
struct BindOnce{S,T} <: Message1
    message::S
    control::T
end
function dyniterate(iter, (message, control)::BindOnce)
    value, message = @returnnothing dyniterate(iter, message, control)
    value, message[]
end

"""
    State(state) <: Message

Persistent message to iterate from the `state`.
"""
struct State{T} <: Message1
    state::T
end
"""
    Value(value, state) <: Message

Transient message to continue to iterate from `state`
reacting to a forced change in the iterate `value`.
"""
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
struct NextKeys{S} <: Message1
    state::S
end
NextKeys() = NextKeys(nothing)
