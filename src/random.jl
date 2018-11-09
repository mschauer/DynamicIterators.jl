
struct Sample{T,S} <: DynamicIterator
        P::T
        rng::S
        Sample(P::T, rng=Random.GLOBAL_RNG) where{T} = new{T,typeof(rng)}(P, rng)

end

function evolve(X::Sample, (t,x)::Pair, args...)
    u = evolve(X.P, (t=>x), args...)
    u === nothing && return nothing
    t, D = u
    x = rand(P.rng, D)
    t => x
end

struct Randn{T}
    x::T
end
Randn(D::Randn) = D
Randn(x::T) where {T} = Randn{T}(x)
randn(D) = randn(typeof(D.x))
randn(D::Randn{Array{T}}) where {T} = randn(T, size(D.x))



struct WhiteNoise <: DynamicIterator
end
evolve(::WhiteNoise, (t,x)::Pair{Int}, args...) = (t+1) => Randn(x)
evolve(::WhiteNoise, x, args...) = Randn(x)
