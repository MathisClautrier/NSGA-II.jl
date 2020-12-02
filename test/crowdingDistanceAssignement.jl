using Test
using NSGAII
using Cambrian

include("./cornercases.jl")



@testset "crowdingDistanceAssignement" begin
    fitness1D=subPop1D()
    cfg=Cambrian.get_config("./test.yaml";n_population= 3,d_fitness=1)
    fitness(x::FloatIndividual)=0
    dim1=NSGA2Evolution(cfg,fitness)
    oldPop1D=copy(dim1.population)
    for i in 1:3
        copyto!(dim1.population[i].fitness,fitness1D[i])
    end
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
    for i in 1:5
        copyto!(dim3.population[i].fitness,fitness3D[i])
    end
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
    for i in 1:8
        copyto!(equal.population[i].fitness,fitnessEQ[i])
    end
    crowdingDistanceAssignement!(equal,equal.population)
    for x in equal.population
        @test equal.distance[objectid(x)]==0
    end
end
