
struct TimeLift{T} <: DynamicIterator
    iter::T
end

function dyniterate(TL::TimeLift, (i, state)::Pair)
    ϕ = dyniterate(TL.iter, state)
    ϕ === nothing && return nothing
    x, state = ϕ
    i + 1 => x, (i => state)
end

function dyniterate(TL::TimeLift, (i, state)::Pair, (j,)::NextKey)
    i == j && return (i, state)
    ϕ = dyniterate(TL.iter, state, (steps=j-i,))
    ϕ === nothing && return nothing
    x, state = ϕ
    j => x, (j => state)
end
function dyniterate(TL::TimeLift, ::Nothing, (i,)::NewKey)
    ϕ = dyniterate(TL.iter)
    ϕ === nothing && return nothing
    x, state = ϕ
    i => x, (i => state)
end
function dyniterate(TL::TimeLift, ::Nothing, (i,)::Key)
    i += 1
    ϕ = dyniterate(TL.iter)
    ϕ === nothing && return nothing
    x, state = ϕ
    i => x, (i => state)
end
function dyniterate(iter, state, (n,)::Steps)
    @assert n ≥ 1
    local x
    for k in 1:n
        ϕ = dyniterate(iter, state)
        ϕ === nothing && return nothing
        x, state = ϕ
    end
    x, state
end
function dyniterate(iter, ::Nothing, (n,)::Steps)
    ϕ = dyniterate(iter)
    ϕ === nothing && return nothing
    n == 1 && return ϕ
    dyniterate(iter, ϕ[2], (steps = n-1,))
end
