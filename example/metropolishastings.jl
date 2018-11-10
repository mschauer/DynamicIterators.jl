using DynamicIterators
using Distributions

D = MvNormal([1.0, 0.5], [1.0 0.5; 0.5 1.5] )
struct Move{T}
    x::T
    σ::Float64
    i::Int
end
m1(x) = Move(x, 0.1, 1)
m2(x) = Move(x, 0.1, 2)
Base.rand(M::Move) = M.x + M.σ*randn()*[M.i-1, 2-M.i]
Distributions.logpdf(M::Move, x) = logpdf(Normal(M.x[M.i], M.σ), x[M.i])
MH1 = MetropolisHastings(D, m1, logpdf)
MH2 = MetropolisHastings(D, m2, logpdf)

I = Evolve(i->rand(1:2))

MH = mixture(I, (MH1, MH2))

X = values(trace(MH, 1=>(1, [0.0, 0.0]), endtime(2000)))
