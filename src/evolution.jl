export NSGA2Evolution

import Cambrian.populate, Cambrian.evaluate,  Cambrian.selection, Cambrian.generation

mutable struct NSGA2Evolution{T} <: Cambrian.AbstractEvolution
    config::NamedTuple
    logger::CambrianLogger
    population::Array{T}
    fitness::Function
    type::DataType
    rank::Dict{UInt64,Int64}
    distance::Dict{Uint64,Float64}
    gen::Int
end

function NSGA2Evolution(cfg::NamedTuple, fitness::Function;
                      logfile=string("logs/", cfg.id, ".csv"))
    logger = CambrianLogger(logfile)
    type=eval(Meta.parse(cfg.ind_type))
    population = Cambrian.initialize(type, cfg)
    rank=Dict{UInt64,Int64}()
    distance=Dict{UInt64,Float64}()
    NSGA2Evolution(cfg, logger, population, fitness,type,rank,distance, 0)
end

function NSGA2Population(e::NSGA2Evolution)
    Qt=Array{e.type}(undef,0)
    for ind in e.population
        push!(Qt,ind)
    end
    for i in 1:e.config.n_population
        if e.config.p_crossover > 0 && rand() < e.config.p_crossover
            parents = vcat(p1, [selection(e.population) for i in 2:e.config.n_parents])
            child = crossover(parents...)
        else
            p1=selection(e.population)
            child= copy(p1)
        end
        if e.config.p_mutation > 0 && rand() < e.config.p_mutation
            child = mutate(child)
        end

        push!(Qt,child)
    end
    @assert length(Qt)==2*e.config.n_population
    e.rank=Dict(objectid(x)=>0 for x in Qt)
    e.distance=Dict(objectid(x)=>0. for x in Qt)
    e.population=Qt
end

function dominates(e::NSGA2Evolution,ind1::e.type,ind2::e.type)
    dom=false
    for i in 1:e.config.d_fitness
        if ind1.fitness[i]<ind2.fitness[i]
            return false
        elseif ind1.fitness[i]>ind2.fitness[i]
            dom=true
        end
    end
    return dom
end
