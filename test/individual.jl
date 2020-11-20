using Test
include("../src/NSGA-II.jl")
using .NSGA-II

include("./cornercases.jl")

#TODO: Create a test.yaml and add using TYPE used for the test.

@testset "Individual" begin
    cfg = get_config("test/test.yaml")
    ind = NSGA2Ind(cfg)
    @test typeof(ind.n)==Int64
    @test typeof(ind.r)==Int64
    @test typeof(ind.d)==Float64
    @test typeof(ind.S)==Array{NSGA2Ind}
    @test ind.n==0
    @test ind.r==0
    @test ind.d==0.
    @test length(ind.S)==0
    @test typeof(ind.indiv)==cfg.indType
end
