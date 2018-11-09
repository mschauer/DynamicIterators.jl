
struct Sample{T,S} <: DynamicIterator
    P::T
    rng::S
    Sample(P::T, rng=Random.GLOBAL_RNG) where {T} = new{T,typeof(rng)}(P, rng)
end
eltype(::Type{Sample{T}}) where {T} = eltype(T)

function evolve(X::Sample, (t,x)::Pair, args...)
    u = evolve(X.P, (t=>x), args...)
    u === nothing && return nothing
    t, D = u
    x = rand(X.rng, D)
    t => x
end

struct Randn{T}
    x::T
end
eltype(::Type{Randn{T}}) where {T} = T
Randn(D::Randn{T}) where {T}  = D
#Randn(x::T) where {T} = Randn{T}(x)
rand(D::Randn) = randn(typeof(D.x))
rand(D::Randn{Array}) = randn(T, size(D.x))
rand(rng::AbstractRNG, D::Randn{T}) where {T} = randn(rng, typeof(D.x))
rand(rng::AbstractRNG, D::Randn{Array{T}}) where {T} = randn(rng, T, size(D.x))



struct WhiteNoise <: DynamicIterator
end
evolve(::WhiteNoise, (t,x)::Pair{Int}, args...) = (t+1) => Randn(x)
evolve(::WhiteNoise, x, args...) = Randn(x)

eltype(::Type{From{WhiteNoise,T}}) where {T} = T
