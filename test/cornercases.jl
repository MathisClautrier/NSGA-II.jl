struct fakeIndividual
    fitness::Array{Int64}
    rank::Int64
    distance::Float64
end

function pop3D()
    liste=[]
    n=1
    for i in 1:4
        push!(liste,[n,n,n])
        push!(liste,[n+1,n,n])
        push!(liste,[n,n+1,n])
        push!(liste,[n,n,n+1])
        n+=1
    end
    r=[1,1,1,2,3,3,3,4,5,5,5,6,7,7,7,8]
    pop=[fakeIndividual(x,0,0.) for x in liste]
    pop,r
end

function pop1D()
    liste=[[i] for i in 1:20]
    ranks=[i for i in 1:20]
    pop=[fakeIndividual(x,0,0.) for x in liste]
    pop,ranks
end

function subPop1D()
    liste=[[1],[1],[1]]
    pop=[fakeIndividual(x,0,0.) for x in liste]
    pop
end

function subPop3D()
    liste=[[5,3,4],[3,5,4],[2,4,5],[4,4,4],[4,4,4]]
    pop=[fakeIndividual(x,0,0.) for x in liste]
    pop
end

function subPopEqual3D()
    liste=[[5,5,5] for i in range(8)]
    pop=[fakeIndividual(x,0,0.) for x in liste]
    pop
end

function maxPop(pop)
    n=length(pop[1].fitness)
    max=[]
    for i in 1:n
        sort!(pop,by=x->x.fitness[i])
        max.append(pop[end])
    end
    return max
end

function minPop(pop)
    n=length(pop[1].fitness)
    min=[]
    for i in 1:n
        sort!(pop,by=x->x.fitness[i])
        max.append(pop[1])
    end
    return min
end
