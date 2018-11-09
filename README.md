# DynamicIterators.jl
You can build a tree from Iterators, but you can form a graph from dynamic iterators.

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

`DynamicIterators.jl` embeds a constraint iterator protocol
```
evolve(iterator, x) -> y
dub(x) = (x,x)
iterate(iterator::DynamicIterator, x) = dub(evolve(iterator, x))
```

which guarantees `value == state` and introduces a powerful set of combinators
for such iterators.

## Combinators

## Traces

## Control



## Examples

To illustrates the range of this I have picked some examples of very diverse nature.
