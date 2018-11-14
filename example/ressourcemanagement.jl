
abstract type Message
end


struct DZip{S,T}
  X::S
  Y::T
end

struct Start
end
struct Close{T}
    state::T
end
struct Postprocess{T,S} <: Message
    state::T
    signal::S
end
Base.iterate(M::Message) = getfield(M, 1), 1
Base.iterate(M::Message, Any) = getfield(M, 2), nothing
Base.iterate(M::Message, ::Nothing) = nothing

struct DRange{T}
    start::T
    stop::T
end
dyniterate(r::DRange, ::Start) = (r.start, r.start)
dyniterate(r::DRange, s) = (s == r.stop) ? nothing : (s+1, s+1)
dyniterate(r::DRange, E::Close) = nothing

Base.iterate(Z::DZip) = dyniterate(Z, Start())
Base.iterate(Z::DZip, state) = dyniterate(Z, state)


dyniterate(Z::DZip, ::Start) = dyniterate(Z::DZip, (Start(), Start()))
dyniterate(Z::DZip, (start, signal)::Postprocess{Start}) = dyniterate(Z::DZip, Postprocess((Start(), Start()), signal))

function dyniterate(Z::DZip, (p, q))
    ϕ = dyniterate(Z.X, p)
    ϕ === nothing && return nothing
    x, p = ϕ

    ϕ = dyniterate(Z.Y, q)
    ϕ === nothing && return nothing
    y, q = ϕ

    (x, y), (p, q)
end


function dyniterate(Z::DZip, ((p,q), signal)::Postprocess)
    ϕ = dyniterate(Z.X, p)
    ϕ === nothing && return dyniterate(Z.Y, signal(q))
    x, p = ϕ

    ϕ = dyniterate(Z.Y, q)
    ϕ === nothing && return dyniterate(Z.X, signal(p))
    y, q = ϕ

    (x, y), Postprocess((p, q), signal)
end


using BenchmarkTools

function f(n)
    Z = zip(1:n, 1:n)
    i = 0
    for (x, y) in Z
        i += x + 2y % 100
    end
    i
end

function g(n)
    Z = DZip(DRange(1,n), DRange(1,n))
    i = 0

    for (x, y) in Z
        i += x + 2y % 100
    end
    i
end

function h(n)
    Z = DZip(DRange(1,n), DRange(1,n))
    i = 0
    ϕ = dyniterate(Z, Postprocess(Start(), x->Close(x)))
    while !(ϕ === nothing)
        (x, y), state = ϕ
        i += x + 2y % 100
        ϕ = dyniterate(Z, state)
        ϕ === nothing && return i
    end
    i
end

@btime f(10000)
@btime g(10000)
@btime h(10000)
