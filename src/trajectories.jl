
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
