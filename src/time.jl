
struct TimeLift{T} <: DynamicIterator
    iter::T
end

function dyniterate(TL::TimeLift, (i, state)::Pair)
    x, state = @returnnothing dyniterate(TL.iter, state)
    i + 1 => x, (i => state)
end

function dyniterate(TL::TimeLift, (i, state)::Pair, (j,)::NextKey)
    i == j && return (i, state)
    x, state = @returnnothing dyniterate(TL.iter, state, (steps=j-i,))
    j => x, (j => state)
end
function dyniterate(TL::TimeLift, ::Nothing, (i,)::NewKey)
    x, state = @returnnothing dyniterate(TL.iter)
    i => x, (i => state)
end
function dyniterate(TL::TimeLift, ::Nothing, (i,)::Key)
    i += 1
    x, state = @returnnothing dyniterate(TL.iter)
    i => x, (i => state)
end

"""
    dyniterate(iter, state, (steps,)::Steps)

Advance the iterator `steps` times, and for negative
numbers, if implemented, rewind the iterator `-steps`
times.
"""
function dyniterate(iter, (state,n)::Steps)
    @assert n ≥ 1
    local x
    for k in 1:n
        x, state = @returnnothing dyniterate(iter, state)
    end
    x, state
end
function dyniterate(iter, (state,n)::Steps{Nothing})
    ϕ = @returnnothing dyniterate(iter)
    n == 1 && return ϕ
    dyniterate(iter, Steps(ϕ[2], n-1))
end
