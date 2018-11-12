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

#=function evolve(M::Controlled, (t,x))
    tᵒ = evolve(M.C, t)
    tᵒ === nothing && return nothing
    u = evolve(M.P, t=>x, tᵒ)
    u === nothing && return nothing
    u
end=#

function dyniterate(M::Controlled, (value,)::Value)
    #ϕ = dyniterate(M.C, (value=value[1],))
    ϕ = dyniterate(M.C)
    ϕ === nothing && return nothing
    tᵒ, c = ϕ

    ϕ = dyniterate(M.P, (value=value, control = tᵒ,))
    ϕ === nothing && return nothing
    u, p = ϕ

    u, (c, p)
end

function iterate(M::Controlled)
    ϕ = dyniterate(M.C)
    ϕ === nothing && return nothing
    tᵒ, c = ϕ

    ϕ = dyniterate(M.P, (control = tᵒ,))
    ϕ === nothing && return nothing
    u, p = ϕ

    u, (c, p)
end

function iterate(M::Controlled, (c, p)::Tuple)
    ϕ = iterate(M.C, c)
    ϕ === nothing && return nothing
    tᵒ, c = ϕ

    ψ = dyniterate(M.P, p, (control = tᵒ,))
    ψ === nothing && return nothing
    u, p = ψ

    u, (c, p)
end
