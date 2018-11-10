# DynamicIterators.jl

## `DynamicIterator`
You can build a tree from Iterators, but you can form a graph from dynamic iterators.

Dynamic iterators subtype `<:DynamicIterator`. They extend the iteration protocol and define
```
    dyniterate(iter, state, (keyword1=setting1, keyword2=setting2,...))
```
with the last argument a named tuple.

A preliminary list of supported keywords:

Keyword      | Meaning
-------------|--------------------
`value=x`    | continue to iterate from the state correspnding to iterate `x`
`nextkey=x`  | advance an iterator over pairs of `key=>values` to `nextkey=>nextvalue`
`until=x`    | advance the iterator until the itertate `x`
`steps=n`    | advance the iterator `n` steps or possibly rewind if `n` negative


## `Evolution`: Evolution-type dynamic iterators
Typically, the state of an iterator is opaque. But for some iterators
the iterates *are* the states:

```julia
julia> value, state = iterate('A':'Z')
('A', 'A')

julia> value, state = iterate('A':'Z', 'X')
('Y', 'Y')
```

This means that the states/iterates of an iterator can be modified in a
transparent way. This allows iterators not only to depend on each other, but to
*interact*.

`DynamicIterators.jl` embeds a constrained iterator protocol for
iterators subtyping `<:Evolution`, which define
```
evolve(iterator, x) -> y
dub(x) = x === nothing ? nothing : (x,x)
iterate(iterator::Evolution, x) = dub(evolve(iterator, x))
```

which guarantees `value == state` and introduces a powerful set of combinators
for such iterators.

## Combinators

As a simple example take a Metropolis-Hastings chain

It can be described as a simple Evolution.
```
function evolve(MH::MetropolisHastings, (t,x)::Pair)
    P = MH.P
    Q = MH.proposal(x)
    xᵒ = rand(Q)
    Qᵒ = MH.proposal(xᵒ)
    if log(rand(MH.rng)) < MH.logpdf(P, xᵒ) - MH.logpdf(P, x) + MH.logpdf(Qᵒ, x) - MH.logpdf(Q, xᵒ)
        x = xᵒ
    end
    (t+1 => x)
end
```

The following example shows that the `Mix` iterator combinator can be used to combine two Metropolis-Hastings chains into a component wise MetropolisHastings sampler:

```
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

mixture(x, y) = rand(Bool) ? (x, x) : (y, y)
MH = mix(mixture, MH1, MH2)

X = first.(values(trace(MH, 1=>([0.0, 0.0], [0.0, 0.0]), endtime(2000))))
```




## Traces

## Control


## Examples

To illustrates the range of this I have picked some examples of very diverse nature.
