
struct NSGA2Ind
    indiv::Individual
    distance::Float64
    rank::Int64
    n::Int64
    S::Array{NSGA2Ind}
end

function NSGA2Ind(ind::Individual)::NSGA2Ind
    NSGA2Ind(ind,0.,0,0,[])
end

function NSGA2Ind(cfg::NamedTuple)::NSGA2Ind
    ind=cfg.indType(cfg)
    NSGA2Ind(ind)
end


function copy(ind::NSGA2Ind)::NSGA2Ind
    NSGA2Ind(copy(ind.indiv))
end
