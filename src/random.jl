
struct Sampled{T,S} <: Evolution
    P::T
    rng::S
    Sampled(P::T, rng=Random.GLOBAL_RNG) where {T} = new{T,typeof(rng)}(P, rng)
end
eltype(::Type{Sampled{T}}) where {T} = eltype(T)

function evolve(X::Sampled, (t,x)::Pair, args...)
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
Randn(D::Randn) = D
#Randn(x::T) where {T} = Randn{T}(x)
rand(D::Randn) = randn(typeof(D.x))
rand(D::Randn{Array}) = randn(T, size(D.x))
rand(rng::AbstractRNG, D::Randn{T}) where {T} = randn(rng, typeof(D.x))
rand(rng::AbstractRNG, D::Randn{Array{T}}) where {T} = randn(rng, T, size(D.x))


struct WhiteNoise <: Evolution
end
evolve(::WhiteNoise, (t,x)::Pair{Int}) = (t+1) => Randn(x)
evolve(::WhiteNoise, x::Union{Randn, AbstractArray, Number}) where {T} = Randn(x)


#evolve(E::Evolution, (x,rng)::Sample{<:Start}) = evolve(E, Sample(x.value, rng))
#evolve(E::Evolution, (x,rng)::Sample) = rand(rng, evolve(E, x))
#evolve(E::Evolution, ((t, x), rng)::Sample{<:Pair{Int}}) = (t+1) => rand(rng, evolve(E, x))
dyniterate(E::Evolution, (x,rng)::Sample{<:Start}) = dyniterate(E, Sample(x.value, rng))
dyniterate(E::Evolution, u::Sample) = rand(u.rng, evolve(E, u.x)), u
function dyniterate(E::Evolution, ((t, x), rng)::Sample{<:Pair{Int}})
    y = rand(rng, evolve(E, x))
    (t+1) => y, Sample(t + 1 => y, rng)
end

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


#=
struct Link{S, T} <: DynamicIterator
    X::S
    Y::T
end
function dyniterate(P::Link, (p, q))
    u, p = @returnnothing dyniterate(P.X, p)
    v, q = @returnnothing dyniterate(P.Y, q, (control = u),)
    v, (p, q)
end

function dyniterate(S::Sampled{Link}, (p, q))
    u, p = @returnnothing dyniterate(Sampled(S.P.X, S.rng), p)
    v, q = @returnnothing dyniterate(Sampled(S.P.Y, S.rng), q, (control = u,))
    v, (p, q)
end
=#
