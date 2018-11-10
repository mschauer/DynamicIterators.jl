
endtime(T) = (t, _)::Pair -> t >= T

"""
    trace(P, u::Pair, stop; register = x->true)

Trace the trajectoy of a keyed Dynamic iterator
as `Trajectory`.
"""
function trace(P, u::Pair, stop; register = x->true)
    X = trajectory((u,))
    while !stop(u)
        u = evolve(P, u)
        register(u) && push!(X, u)
    end
    X
end

function lastiterate(P::DynamicIterator, u, stop=u->false)
    while !stop(u)
        u = evolve(P, u)
        u === nothing && return u
    end
    u
end
lastiterate(P, u, stop=u->false) = _lastiterate(P, u, stop)

function _lastiterate(P, u, stop=u->false)
    if !stop(u)
        ϕ = _iterate(P, value=u)
        ϕ === nothing && return u
        u, state = ϕ
        while !stop(u)
            ϕ = _iterate(P, state, value=u)
            ϕ === nothing && return u
            u, state = ϕ
        end
    end
    u
end
