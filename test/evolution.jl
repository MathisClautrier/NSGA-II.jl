using Test
using NSGAII
include("./cornercases.jl")

@testset "Populate" begin
    pop=evolutionPop()
    oldPop=copy(pop.population)
    NSGA2Populate(pop)
    for x in oldPop
        @test x in pop.population
    end
    @test length(pop.population)==2*length(oldPop)
end

@testset "Generation" begin
    pop=evolutionPop()
    max=maxPop(pop.population)
    n=length(pop)
    NSGA2Generation(pop)
    for x in max
        @test x in pop.population
    end
    @test n == 2*length(pop.population)
    pop=evolutionPop2() #the number of individus where rank=1 is greater than n.population, npopulation >2*d_fitness
    max=maxPop(pop.population)
    NSGA2Generation(pop)
    for x in max
        @test x in pop.population
    end
end
