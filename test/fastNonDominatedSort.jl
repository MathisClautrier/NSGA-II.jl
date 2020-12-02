using Test
using NSGAII

include("./cornercases.jl")

@testset "Domination" begin
    L=[[2,1,1],[1,2,2],[1,0,0]]
    fitness(x::FloatIndividual)=0
    cfg=Cambrian.get_config("./test.yaml";n_population= 3,d_fitness=3)
    e=NSGA2Evolution(cfg,fitness)
    for i in 1:3
        copyto!(e.population[i].fitness,L[i])
    end
    @test dominates(e,e.population[1],e.population[2])==false
    @test dominates(e,e.population[2],e.population[1])==false
    @test dominates(e,e.population[1],e.population[3])==true
    @test dominates(e,e.population[3],e.population[1])==false
end

@testset "fastNonDominatedSort" begin
    fitness1,ranks1=pop1D()
    fitness2,ranks2=pop3D()
    fitness(x::FloatIndividual)=0
    cfg=Cambrian.get_config("./test.yaml";n_population= 20,d_fitness=1)
    e=NSGA2Evolution(cfg,fitness)
    for i in 1:20
        copyto!(e.population[i].fitness,fitness1[i])
    end
    oldPop1D=copy(e.population)
    fastNonDominatedSort!(e)
    @test length(e.population)==length(oldPop1D)
    for x in oldPop1D
        @test x in e.population
    end
    for i in 1:e.config.n_population
        @test ranks1[i]==e.rank[objectid(e.population[i])]
    end

    cfg=Cambrian.get_config("./test.yaml";n_population= 16,d_fitness=3)
    e=NSGA2Evolution(cfg,fitness)
    for i in 1:16
        copyto!(e.population[i].fitness,fitness2[i])
    end
    oldPop3D=copy(e.population)
    fastNonDominatedSort!(e)
    @test length(e.population)==length(oldPop3D)
    for x in oldPop3D
        @test x in e.population
    end
    for i in 1:e.config.n_population
        @test ranks2[i]==e.rank[objectid(e.population[i])]
    end
end
