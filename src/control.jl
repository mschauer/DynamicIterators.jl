"""
    control(C, P)
    timed(C, P)

"Controlled" iterator `P` with the state `t` of `C`
calling
```
(t => x) = evolve(P, t=>x, tᵒ)
```

# Example
```
# Apply collatz twice each step using the default for Evolve

collatz(n) = n % 2 == 0 ? n÷2 : 3n + 1
collectfrom(control(1:2:20, Evolve(collatz)), (1,14))
```
"""
struct Controlled{T,S} <: DynamicIterator
        C::S
        P::T
end
control(C, P) = Controlled(C, P)
timed(C, P) = Controlled(C, P)

function dyniterate(M::Controlled, ::Nothing, (value,)::Value)
    tᵒ, c = @returnnothing dyniterate(M.C)
    u, p = @returnnothing dyniterate(M.P, nothing, (value=value, control = tᵒ,))
    u, (c, p)
end

function iterate(M::Controlled)
    tᵒ, c = @returnnothing dyniterate(M.C)
    u, p = @returnnothing dyniterate(M.P, nothing, (control = tᵒ,))
    u, (c, p)
end

function iterate(M::Controlled, (c, p)::Tuple)
    tᵒ, c = @returnnothing iterate(M.C, c)
    u, p = @returnnothing dyniterate(M.P, p, (control = tᵒ,))
    u, (c, p)
end
