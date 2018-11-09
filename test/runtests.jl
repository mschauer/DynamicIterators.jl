using DynamicIterators
using Test
using Trajectories

c = collect
cf = collectfrom

# Arnolds cat map, repeats after n iterations
# https://en.wikipedia.org/wiki/Arnold%27s_cat_map

A = [ 0 0 0 0 0 0
      0 1 1 1 1 0
      0 1 0 0 1 0
      0 1 1 1 1 0
      0 1 0 0 1 0
      0 0 0 0 0 0
]
arnold_imap(x, (m,n) = size(x)) = CartesianIndex(1 + (2x[1]+ x[2] - 3)%m, 1 + (x[1] + x[2] - 2) % n)
arnold(A) = [A[arnold_imap(x, size(A))] for x in CartesianIndices(A)]
A0 = copy(A)
P = Evolve(arnold)
let A = A0
      for i in 1:12
            A = evolve(P, A)
      end
      @test A == A0
end

i, A = evolve(P, (0=>A0), 12)
@test A == A0
@test i == 12

X = trace(P, (0=>A0), endtime(12))
@test X isa Trajectory{Array{Int64,1},Array{Array{Int64,2},1}}
@test keys(X) == 0:12
@test last(values(X)) == A0

As = collectfrom(P, A0, 13)
@test As[1] == As[13]

@test evolve(1:10, 5) == 6
@test evolve(1:10, 10) == nothing

# broken?
@test evolve(1:10, 11) == nothing



m = collectfrom(mix((x,y) -> (x+y, y), 0:20000, 0:100), (0,0))
@test m[end]  == (100*101÷2 + 100, 100)
@test_broken eltype(m) == Tuple{Int,Int}
