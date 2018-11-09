"""
    control(C, P)
    timed(C, P)

"Control" iterator `P` with the state `t` of `C`
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
struct Control{T,S} <: DynamicIterator
        C::S
        P::T
end
control(C, P) = Control(C, P)
timed(C, P) = Control(C, P)

function evolve(M::Control, (t,x))
    tᵒ = evolve(M.C, t)
    tᵒ === nothing && return nothing
    u = evolve(M.P, t=>x, tᵒ)
    u === nothing && return nothing
    u
end
