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

function dominates(e::NSGA2Evolution,ind1,ind2) #TODO Find a way to specify ind1,ind2 types,
                                                #may be by using index in e.population?
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


function fastNonDominatedSort!(e::NSGA2Evolution)

    Fi=Array{e.type}(undef,0)

    n=Dict(objectid(x)=>0 for x in e.population)
    S=Dict(objectid(x)=>Array{e.type}(undef,0) for x in e.population)

    for ind1 in e.population
        for ind2 in e.population
            if dominates(e,ind1,ind2)
                push!(S[objectid(ind1)],ind2)
            elseif dominates(e,ind2,ind1)
                n[objectid(ind1)]+=1
            end
        end
        if n[objectid(ind1)]==0
            e.rank[objectid(ind1)]=1
            push!(Fi,ind1)
        end
    end

    i=1

    while isempty(Fi)==false
        Q=Array{e.type}(undef,0)
        for ind1 in Fi
            currentS=S[objectid(ind1)]
            for ind2 in currentS
                n[objectid(ind2)]-=1
                if n[objectid(ind2)]==0
                    e.rank[objectid(ind2)]=i+1
                    push!(Q,ind2)
                end
            end
        end
        i=i+1
        Fi=Q
    end
end


function crowdingDistanceAssignement!(e::NSGA2Evolution,I) #TODO find a way to specify
                                                           #I type
    l=length(I)
    for i in 1:e.config.d_fitness
        sort!(I,by=x->x.fitness[i])
        if I[1].fitness[i]!=I[end].fitness[i]
            e.distance[objectid(I[1])]=Inf
            e.distance[objectid(I[end])]=Inf
            quot=I[end].fitness[i]-I[1].fitness[i]
            for j in 2:l-1
                e.distance[objectid(I[j])]=e.distance[objectid(I[j])]+
                (I[j+1].fitness[i]-I[j-1].fitness[i])/quot
            end
        end
    end
end
