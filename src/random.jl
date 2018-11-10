
struct Sample{T,S} <: Evolution
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



struct WhiteNoise <: Evolution
end
evolve(::WhiteNoise, (t,x)::Pair{Int}, args...) = (t+1) => Randn(x)
evolve(::WhiteNoise, x, args...) = Randn(x)

eltype(::Type{From{WhiteNoise,T}}) where {T} = T

#abstract type MarkovIterator
#end

struct InhomogeneousPoisson{T,S,R} <: Evolution
    λ::S
    λmax::T
    rng::R
end
InhomogeneousPoisson(λ, λmax) = InhomogeneousPoisson(λ, λmax, Random.GLOBAL_RNG)

function evolve(P::InhomogeneousPoisson, (t, i)::Pair)
    while true
        t = t - log(rand(P.rng))/P.λmax
        if rand(P.rng) ≤ P.λ(t)/P.λmax
            return t => i + 1
        end
    end
end


struct MetropolisHastings{T,F,G,RNG} <: Evolution
    P::T
    proposal::F
    logpdf::G
    rng::RNG
end
MetropolisHastings(P, proposal, logpdf=logpdf) = MetropolisHastings(P, proposal, logpdf, Random.GLOBAL_RNG)

function evolve(MH::MetropolisHastings, x)
    P = MH.P
    Q = MH.proposal(x)
    xᵒ = rand(Q)
    Qᵒ = MH.proposal(xᵒ)
    if log(rand(MH.rng)) < MH.logpdf(P, xᵒ) - MH.logpdf(P, x) + MH.logpdf(Qᵒ, x) - MH.logpdf(Q, xᵒ)
        x = xᵒ
    end
    x
end
