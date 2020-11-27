using Test
using NSGAII
using Cambrian

include("./cornercases.jl")



@testset "crowdingDistanceAssignement" begin
    fitness1D=subPop1D()
    cfg=Cambrian.get_config("./test.yaml";n_population= 3,d_fitness=1)
    D=Dict{UInt64,Array{Any}}()
    fitness(x::FloatIndividual)=D[objectid(x)]
    dim1=NSGA2Evolution(cfg,fitness)
    oldPop1D=copy(dim1.population)
    D=Dict(objectid(dim1.population[i])=>fitness1D[i] for i in 1:dim1.config.n_population)
    step!(dim1)
    crowdingDistanceAssignement!(dim1,dim1.population)
    @test length(oldPop1D)==length(dim1.population)
    for x in oldPop1D
        @test x in dim1.population
    end
    for x in dim1.population
        @test dim1.distance[objectid(x)]==0
    end
    fitness3D=subPop3D()
    cfg=Cambrian.get_config("./test.yaml";n_population= 5,d_fitness=3)
    dim3=NSGA2Evolution(cfg,fitness)
    oldPop3D=copy(dim3.population)
    D=Dict(objectid(dim3.population[i])=>fitness3D[i] for i in 1:dim3.config.n_population)
    step!(dim3)
    crowdingDistanceAssignement!(dim3,dim3.population)
    @test length(oldPop3D)==length(dim3.population)
    for x in oldPop3D
        @test x in dim3.population
    end
    max3D=maxPop(dim3.population)
    min3D=minPop(dim3.population)
    for x in max3D
        @test dim3.distance[objectid(x)]==Inf
    end
    for x in min3D
        @test dim3.distance[objectid(x)]==Inf
    end
    fitnessEQ=subPopEqual3D()
    cfg=Cambrian.get_config("./test.yaml";n_population= 8,d_fitness=3)
    equal=NSGA2Evolution(cfg,fitness)
    D=Dict(objectid(equal.population[i])=>fitnessEQ[i] for i in 1:equal.config.n_population)
    step!(equal)
    crowdingDistanceAssignement!(equal,equal.population)
    for x in equal.population
        @test equal.distance[objectid(x)]==0
    end
end
