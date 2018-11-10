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


function dyniterate(M::Control, (value,)::Value)
    ϕ = dyniterate(M.C, (value=value[1],))
    ϕ === nothing && return nothing
    tᵒ, c = ϕ

    ϕ = dyniterate(M.P, (value=value, nextkey = tᵒ,))
    ϕ === nothing && return nothing
    u, p = ϕ

    u, (c, p)
end

function iterate(M::Control)
    ϕ = dyniterate(M.C)
    ϕ === nothing && return nothing
    tᵒ, c = ϕ

    ϕ = dyniterate(M.P, (nextkey = tᵒ,))
    ϕ === nothing && return nothing
    u, p = ϕ

    u, (c, p)
end

function iterate(M::Control, (c, p)::Tuple)
    ϕ = dyniterate(M.C, c)
    ϕ === nothing && return nothing
    tᵒ, c = ϕ

    ψ = dyniterate(M.P, p, (nextkey = tᵒ,))
    ψ === nothing && return nothing
    u, p = ψ

    u, (c, p)
end
