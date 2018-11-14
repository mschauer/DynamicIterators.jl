using DynamicIterators
using DynamicIterators: dub, _lastiterate, dyniterate, Sample2
using Test
using Trajectories

c = collect
cf = collectfrom

# Arnolds cat map, repeats after n iterations
# https://en.wikipedia.org/wiki/Arnold%27s_cat_map

@testset "Evolve" begin

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

      (i, A), _ = dyniterate(P, Control(0=>A0), 12)
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


end
@test collect(from(1:14, 10)) == [11, 12, 13, 14]

@testset "time" begin
      @test dyniterate(1:10, Steps(5, 3)) == (8, 8)
      @test dyniterate(TimeLift(1:2:10), NewKey(1=>nothing, 5)) == (5=>1, 5=>1)
end

@testset "Mix" begin
      M = mix((x,y) -> (x+y, y), 0:20000, 0:100)
      F = from(M, (0,0))
      @show x, s = iterate(F)
      @show x, s = iterate(F, s)
      @show x, s = iterate(F, s)
      @test _lastiterate(M, (0,0)) == (100*101÷2 + 100, 100)

      m = collectfrom(M, (0,0))
      @test m[end]  == (100*101÷2 + 100, 100)
      @test eltype(m) == Tuple{Int,Int}


end

@testset "random" begin
      @test all([Randn(0.0)] .== collectfrom(WhiteNoise(), Randn(0.0), 9))

      @test collectfrom(Sample2(WhiteNoise()), (0 => 0.1), 10) isa Array{Pair{Int64,Float64},1}

      @test eltype(from(Sample2(WhiteNoise()), (0 => 0.1))) == Pair{Int64,Float64}


      @test eltype(Randn(10)) == Int
      @test eltype(Randn{Int}) == Int

      @test collectfrom(InhomogeneousPoisson(x -> sin(x) + 1, 2.0), (0.0=>0), 10) isa  Array{Pair{Float64,Int64},1}
end

collatz(n) = n % 2 == 0 ? n÷2 : 3n + 1

function bare_collatz(k, n)
      for i in 1:n-1
            k = collatz(k)
      end
      k
end


@testset "control" begin
      F = from(control(1:2:20, Evolve(collatz)), 1=>14)
      ϕ = iterate(F)
      @test (1 => 14, (1, 1 => 14)) == ϕ
      ϕ = iterate(F, ϕ[2])
      @test (3 => 22, (3, 3 => 22)) == ϕ
      @test collectfrom(F, 1=>14) isa Array{Pair{Int64,Int64},1}

      F = from(control(3:2:20, Evolve(collatz)), 1=>14)
      ϕ = iterate(F)
      @test (3 => 22, (3, 3 => 22)) == ϕ
      @test collectfrom(F, 1=>14) isa Array{Pair{Int64,Int64},1}

end



@testset "Synchronize" begin
      P = InhomogeneousPoisson(x -> sin(x) + 1, 2.0)

      PP = synchronize(P, P)
      u = DynamicIterators.state(0.0 => (0,0), PP)
      @show u
      @show collectfrom(PP, u, 10)

end

@inferred _lastiterate(Evolve(collatz), 1=>6171, endtime(10000) )
@inferred lastiterate(Evolve(collatz), 1=>6171, endtime(10000) )
#using BenchmarkTools

let E = Evolve(collatz), st = endtime(10000)

      @test _lastiterate(E, 1=>6171, st )[2] == lastiterate(E, 1=>6171, st )[2] == bare_collatz(6171, 10000)
      @test @allocated(_lastiterate(E, 1=>6171, st ) ) == 0
      @test @allocated(lastiterate(E, 1=>6171, st ) ) == 0

      @time lastiterate(E, 1=>6171, st)
      @time _lastiterate(E, 1=>6171, st)
      @time bare_collatz(6171, 10000)
end
