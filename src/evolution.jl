export NSGA2Evolution,fastNonDominatedSort!,dominates,crowdingDistanceAssignement!,NSGA2Generation,NSGA2Populate,NSGA2Evaluate

import Cambrian.populate, Cambrian.evaluate,  Cambrian.selection, Cambrian.generation
import Cambrian.isless

mutable struct NSGA2Evolution{T<:Individual} <: Cambrian.AbstractEvolution
    config::NamedTuple
    logger::CambrianLogger
    population::Array{T}
    fitness::Function
    type::DataType
    rank::Dict{UInt64,Int64}
    distance::Dict{UInt64,Float64}
    gen::Int
    offsprings::Dict{UInt64,Bool}
end

function isless(i2::Individual, i1::Individual)
    k = length(i1.fitness)
    dom = false
    for i in 1:k
        if i1.fitness[i] > i2.fitness[i]
            return true
        end
    end
    return false
end

function tournament(pop::Array{T},t_size::Int) where {T <: Individual}
    inds = shuffle!(collect(1:length(pop)))
    sort(pop[inds[1:t_size]])[end]
end


populate(e::NSGA2Evolution) = NSGA2Populate(e)
evaluate(e::NSGA2Evolution) = NSGA2Evaluate(e)
generation(e::NSGA2Evolution) = NSGA2Generation(e)


function NSGA2Evolution{T}(cfg::NamedTuple, fitness::Function;
                      logfile=string("logs/", cfg.id, ".csv")) where {T <: Individual}
    logger = CambrianLogger(logfile)
    population = Cambrian.initialize(T, cfg)
    rank=Dict{UInt64,Int64}()
    distance=Dict{UInt64,Float64}()
    offsprings=Dict{UInt64,Bool}()
    for x in population
        offsprings[objectid(x)]=true
    end
    NSGA2Evolution(cfg, logger, population, fitness,T,rank,distance, 0, offsprings)
end

function NSGA2Evolution{T}(cfg::NamedTuple, fitness::Function, population::Array{T};
                      logfile=string("logs/", cfg.id, ".csv")) where {T <: Individual}
    logger = CambrianLogger(logfile)
    rank=Dict{UInt64,Int64}()
    distance=Dict{UInt64,Float64}()
    offsprings=Dict{UInt64,Bool}()
    for x in population
        offsprings[objectid(x)]=true
    end
    NSGA2Evolution(cfg, logger, population, fitness,T,rank,distance, 0, offsprings)
end

function NSGA2Evaluate(e::NSGA2Evolution)
    for i in eachindex(e.population)
        if e.offsprings[objectid(e.population[i])]
            e.population[i].fitness[:] = e.fitness(e.population[i])[:]
            e.offsprings[objectid(e.population[i])]=false
        end
    end
end

function NSGA2Populate(e::NSGA2Evolution)
    T=typeof(e.population[1])
    Qt=Array{T}(undef,0)
    for ind in e.population
        push!(Qt,ind)
    end
    i=0
    while i < e.config.n_offsprings
        parents =  [selection(e.population) for i in 1:2]
        if  rand() < e.config.p_crossover
            child1,child2 = crossover(parents...)
        else
            child1,child2= copy(parents[1]),copy(parents[2])
        end
        if rand() < e.config.p_mutation
            child1 = mutate(child1)
            child2 = mutate(child2)
        end
        push!(Qt,child1)
        e.offsprings[objectid(child1)]=true
        i+=1
        if i < e.config.n_offsprings
            push!(Qt,child2)
            e.offsprings[objectid(child2)]=true
            i+=1
        end
    end
    e.rank=Dict(objectid(x)=>0 for x in Qt)
    e.distance=Dict(objectid(x)=>0. for x in Qt)
    e.population=Qt
end

function dominates(e::NSGA2Evolution,ind1::T,ind2::T) where {T <: Individual}
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
    T=typeof(e.population[1])
    Fi=Array{T}(undef,0)

    n=Dict(objectid(x)=>0 for x in e.population)
    S=Dict(objectid(x)=>Array{T}(undef,0) for x in e.population)

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
        Q=Array{T}(undef,0)
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

function crowdingDistanceAssignement!(e::NSGA2Evolution,I::Array{T}) where {T <: Individual}
    for x in I
        e.distance[objectid(x)]=0
    end
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

function NSGA2Generation(e::NSGA2Evolution)
    if e.gen>1
        T=typeof(e.population[1])
        fastNonDominatedSort!(e)
        Pt1=Array{T}(undef,0)
        i=1
        sort!(e.population,by= x -> e.rank[objectid(x)])
        rank=1
        indIni=1
        indNext=findlast(x -> e.rank[objectid(x)] == rank , e.population)
        while indNext < e.config.n_population
            Pt1=[Pt1...,e.population[indIni:indNext]...]
            rank+=1
            indIni=indNext+1
            indNext=findlast(x -> e.rank[objectid(x)] == rank, e.population)
        end
        if isempty(Pt1)
            I=e.population[1:indNext]
            crowdingDistanceAssignement!(e,I)
            sort!(I, by= x->e.distance[objectid(x)],rev=true)
            Pt1=I[1:e.config.n_population]
        else
            I=e.population[indIni:indNext]
            crowdingDistanceAssignement!(e,I)
            sort!(I, by= x->e.distance[objectid(x)],rev=true)
            Pt1=[Pt1...,I[1:e.config.n_population-length(Pt1)]...]
        end
        e.population=Pt1
        e.offsprings=Dict(objectid(x)=>false for x in e.population)
    end
end
