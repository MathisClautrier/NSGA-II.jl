export NSGA2Evolution

import Cambrian.populate, Cambrian.evaluate,  Cambrian.selection, Cambrian.generation

mutable struct NSGA2Evolution{T} <: Cambrian.AbstractEvolution
    config::NamedTuple
    logger::CambrianLogger
    population::Array{T}
    fitness::Function
    rank::Dict{UInt64,Int64}
    distance::Dict{Uint64,Float64}
    gen::Int
end

function NSGA2Evolution(cfg::NamedTuple, fitness::Function;
                      logfile=string("logs/", cfg.id, ".csv"))
    logger = CambrianLogger(logfile)
    population = Cambrian.initialize(eval(Meta.parse(cfg.ind_type)), cfg)
    rank=Dict{UInt64,Int64}()
    distance=Dict{UInt64,Float64}()
    NSGA2Evolution(cfg, logger, population, fitness,rank,distance, 0)
end
