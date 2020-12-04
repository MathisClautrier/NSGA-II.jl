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
    cfg=Cambrian.get_config("./test.yaml";n_population= 7,n_offsprings=5,d_fitness=3)
    e=NSGA2Evolution{FloatIndividual}(cfg,fitness)
    oldPop=copy(e.population)
    NSGA2Populate(e)
    for x in oldPop
        @test x in e.population
    end
    for x in e.population
        if x in oldPop == false
            @test e.offsprings[objectid(x)]==true
        end
    end
    @test length(e.population)==length(oldPop)+5
end

@testset "Evaluate" begin
    cfg=Cambrian.get_config("./test.yaml";n_population= 7,n_offsprings=5,d_fitness=3)
    e=NSGA2Evolution{FloatIndividual}(cfg,fitness)
    L=[]
    for i in 1:3
        e.offsprings[objectid(e.population[i])]=false
        push!(L,copy(e.population[i].fitness))
    end
    for i in 4:7
        push!(L,copy(e.population[i].fitness))
    end
    evaluate(e)
    for i in 1:3
        @test all(e.population[i].fitness.==L[i])
    end
    for i in 4:7
        @test all(e.population[i].fitness.!=L[i])
    end

end

@testset "Generation" begin
    cfg=Cambrian.get_config("./test.yaml";n_population= 7,n_offsprings=5,d_fitness=3)
    e=NSGA2Evolution{FloatIndividual}(cfg,fitness)
    evaluate(e)
    max=maxPop(e.population)
    NSGA2Generation(e)
    for x in max
        @test x in e.population
    end
end

@testset "Step" begin
    cfg=Cambrian.get_config("./test.yaml";n_population= 7,n_offsprings=5,d_fitness=3)
    e=NSGA2Evolution{FloatIndividual}(cfg,fitness)
    step!(e)
    @test length(e.population)==e.config.n_population
    step!(e)
    @test length(e.population)==e.config.n_population
    for x in e.population
        @test e.offsprings[objectid(x)]==false
    end
end
