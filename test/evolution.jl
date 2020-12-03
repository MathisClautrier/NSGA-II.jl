using Test
using NSGAII
using Statistics
import Base.copy

include("./cornercases.jl")

fitness(x::FloatIndividual)=[mean(x.genes),std(x.genes),median(x.genes)]

function copy(ind::FloatIndividual)
    genes=deepcopy(ind.genes)
    fitness=zeros(length(ind.fitness))
    FloatIndividual(genes,fitness)
end


@testset "Populate" begin
    cfg=Cambrian.get_config("./test.yaml";n_population= 7,d_fitness=3)
    e=NSGA2Evolution{FloatIndividual}(cfg,fitness)
    oldPop=copy(e.population)
    NSGA2Populate(e)
    for x in oldPop
        @test x in e.population
    end
    @test length(e.population)==2*length(oldPop)
end

@testset "Generation" begin
    cfg=Cambrian.get_config("./test.yaml";n_population= 7,d_fitness=3)
    e=NSGA2Evolution{FloatIndividual}(cfg,fitness)
    evaluate(e)
    max=maxPop(e.population)
    NSGA2Generation(e)
    for x in max
        @test x in e.population
    end
end

@testset "Step" begin
    cfg=Cambrian.get_config("./test.yaml";n_population= 7,d_fitness=3)
    e=NSGA2Evolution{FloatIndividual}(cfg,fitness)
    step!(e)
    @test length(e.population)==e.config.n_population
    step!(e)
    @test length(e.population)==e.config.n_population
end
