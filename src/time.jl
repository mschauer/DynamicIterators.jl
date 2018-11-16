
struct TimeLift{T} <: DynamicIterator
    iter::T
end

function dyniterate(TL::TimeLift, (i, state)::Pair)
    x, state = @returnnothing dyniterate(TL.iter, state)
    i + 1 => x, (i + 1 => state)
end


function dyniterate(TL::TimeLift, (state, j)::NextKey)
    x, state = @returnnothing dyniterate(TL.iter, state)
    j => x, (j => state)
end
function dyniterate(TL::TimeLift, ((i, state), j)::NextKey{<:Pair})
    x, state = @returnnothing dyniterate(TL.iter, Steps(state, j-i))
    j => x, (j => state)
end
function dyniterate(TL::TimeLift, (state,)::NextKeys, key)
    u, state = @returnnothing dyniterate(TL, NextKey(state, key))
    u, NextKeys(state)
end
function dyniterate(TL::TimeLift, (nk,)::Start{<:NextKeys}, key)
    ϕ = dyniterate(TL, NextKey(nk[], key))
    u, state = @returnnothing ϕ
    u, NextKeys(state)
end

function dyniterate(TL::TimeLift, ((i,state), j)::NewKey{<:Pair})
    x, state = @returnnothing dyniterate(TL.iter, state)
    j => x, (j => state)
end


"""
    dyniterate(iter, state, (steps,)::Steps)

Advance the iterator `steps` times, and for negative
numbers, if implemented, rewind the iterator `-steps`
times.
"""
function dyniterate(iter, (state, n)::Steps)
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
function dyniterate(iter::GEvolution, (x,n)::Steps)
    @assert n ≥ 0
    for k in 1:n
        x = @returnnothing evolve(iter, x)
    end
    dub(x)
end
