"""
    Controlled(C, P)

"Controlled" iterator `P` with the state `t` of `C`
calling
```
(t => x) = evolve(P, t=>x, tᵒ)
```

# Example
```
# Apply collatz twice each step using the default for Evolve

collatz(n) = n % 2 == 0 ? n÷2 : 3n + 1
collectfrom(Controlled(1:2:20, Evolve(collatz)), (1,14))
```
"""
struct Controlled{T,S} <: DynamicIterator
        C::S
        P::T
end

function dyniterate(M::Controlled, start::Union{Start,Nothing})
    tᵒ, c = @returnnothing dyniterate(M.C, nothing)
    u, p = @returnnothing dyniterate(M.P, Control(start),  tᵒ)
    u, (c, p)
end
function dyniterate(M::Controlled, (c, p)::Tuple)
    tᵒ, c = @returnnothing iterate(M.C, c)
    u, p = @returnnothing dyniterate(M.P, p, tᵒ)
    u, (c, p)
end


struct Attach{F,T} <: DynamicIterator
        f::F
        P::T
end
attach(f, P) = Attach(f, P)

function dyniterate(M::Attach, start::Union{Start,Nothing}, args...)
    dyniterate(M.P, M.f(start),  args...)
end
function dyniterate(M::Attach, state, args...)
    dyniterate(M.P, state, args...)
end
