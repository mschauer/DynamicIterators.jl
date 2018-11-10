# DynamicIterators.jl
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


## Evolution-type iterators
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

## Traces

## Control



## Examples

To illustrates the range of this I have picked some examples of very diverse nature.
