# DynamicIterators.jl

## `DynamicIterator`
Iterators combine to a tree of iterators, but dynamic iterators combine to a network of interacting entities.

Dynamic iterators subtype `<:DynamicIterator`. They extend the iteration protocol and define
```
    dyniterate(iter, message(state))
```
where message wraps a state or other relevant information.
For example the definition
```
struct Start{T} <: Message
    value::T
end
dyniterate(iter, Start(value))
```
communicates that `iter` should start at `value` (if this is implemented).
This is similar to `iterate(iter)` communicating that `iter` should start at a predefined
value. In fact a fallback
```
dyniterate(iter, ::Nothing)
```
Some messages make the iterator accept a third argument.

A preliminary list of supported messages:

Message (and third argument) | Meaning
----------------------------|--------------------
`Start(noting)`             | Start the iterator at its default
`Start(x)`                  | start the iterate from the state corresponding to value `x`
`Value(x)`                  | continue to iterate from the state corresponding to iterate `x`
`NextKey(state), nextkey`   | advance an iterator over pairs of `key=>values` to `nextkey`
`Steps(n)`                  | advance the iterator `n` steps or possibly rewind if `n` negative
`Control(), control`        | control term as in the Kalman filter


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

The following example shows that the `Mixture` iterator combinator can be used to combine two Metropolis-Hastings chains into a component wise MetropolisHastings sampler:

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

I = Evolve(i->rand(1:2))

MH = mixture(I, (MH1, MH2))

X = values(trace(MH, 1=>(1, [0.0, 0.0]), endtime(2000)))
```

![img](https://raw.githubusercontent.com/mschauer/DynamicIterators.jl/master/asset/mh.png)

## Lifting time

Letting
```
evolve(E, (i, x)::Pair) = i + 1 => evolve(E, x)
```
constitutes a "lifting" of discrete time. This corresponds to enumerating the iterates of an evolution `x = f(x)` as `(1 => x1, 2 => x2, ...)`.

`DynamicIterators` control keywords treat `Pair`s as pair of key and value in concordance with the package `Trajectories` and somewhat in line with Julia's general convention.


## Traces

## Controlled Dynamic Iterators


## Examples

To illustrates the range of this I have picked some examples of very diverse nature.
