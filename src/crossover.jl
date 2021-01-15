

function output_graph_crossover(ind1::CGPInd, ind2::CGPInd)
    p1_nodes = Array{Int64}(undef, 0)
    p2_nodes = Array{Int64}(undef, 0)
    output_genes = Array{Float64}(undef, 0)
    for output in 1:ind1.n_out
        if rand() < 0.5
            append!(p1_nodes, get_output_trace(ind1, output))
            append!(output_genes, [ind1.chromosome[end-ind1.n_out+output]])
        else
            append!(p2_nodes, get_output_trace(ind2, output))
            append!(output_genes, [ind2.chromosome[end-ind2.n_out+output]])
        end
    end
    p1_nodes = sort!(unique(p1_nodes))
    p2_nodes = sort!(unique(p2_nodes))
    p1_nodes = p1_nodes[p1_nodes.>ind1.n_in]
    p2_nodes = p2_nodes[p2_nodes.>ind1.n_in]
    genes = [get_genes(ind1, p1_nodes)..., get_genes(ind2, p2_nodes)...,output_genes...]
    genes
end

function subgraph_crossover(ind1::CGPInd, ind2::CGPInd)
    # Take subgraphs from both parents equally, adding all nodes of the chosen
    # subgraphs to the child.
    fc1 = forward_connections(ind1)
    fc2 = forward_connections(ind2)
    c1_nodes = []; c2_nodes = []
    for i in (ind1.n_in+1):min(length(ind1.nodes), length(ind2.nodes))
        if rand(Bool)
            append!(c1_nodes, fc1[i])
        else
            append!(c2_nodes, fc2[i])
        end
    end
    if length(ind1.nodes) < length(ind2.nodes)
        for i in length(ind1.nodes):length(ind2.nodes)
            if rand(Bool)
                append!(ind2.nodes, fc2[i])
            end
        end
    elseif length(ind2.nodes) < length(ind1.nodes)
        for i in length(ind2.nodes):length(ind1.nodes)
            if rand(Bool)
                append!(c1_nodes, fc1[i])
            end
        end
    end
    c1_nodes = Array{Int64}(unique(intersect(collect((ind1.n_in+1):length(ind1.nodes)), c1_nodes)))
    c2_nodes = Array{Int64}(unique(intersect(collect((ind2.n_in+1):length(ind2.nodes)), c2_nodes)))
    genes = zeros(ind1.n_out)
    for i in 1:ind1.n_out
        if rand(Bool)
            genes[i] = ind1.chromosome[end-ind1.n_out+i]
        else
            genes[i] = ind2.chromosome[end-ind2.n_out+i]
        end
    end
    if length(c1_nodes) > 0
        genes = [get_genes(ind1, c1_nodes);genes]
    end
    if length(c2_nodes) > 0
        genes = [get_genes(ind2, c2_nodes);genes]
    end
    genes
end


function get_genes(ind::CGPInd, node_id::Int64)
    #Select corresponding genes to a given node
    ind.chromosome[(node_id-ind.n_in-1)*3+1:(node_id-ind.n_in-1)*3+3]
end


function get_genes(ind::CGPInd, nodes::Array{Int64})
    #Select corresponding genes to given nodes
    if length(nodes) > 0
        return reduce(vcat, map(x->get_genes(ind, x), nodes))
    else
        return Array{Int64}(undef, 0)
    end
end


function get_output_trace(ind::CGPInd, output_ind::Int64)
    # Find all nodes linked to an output
    recur_output_trace(ind, ind.outputs[output_ind], Array{Int64}(undef, 0))
end

function recur_output_trace(ind::CGPInd, iter::Int16, visited::Array{Int64})
    if ~(iter in visited)
        append!(visited, [iter])
        if iter > ind.n_in
            for i in [ind.nodes[iter].x,ind.nodes[iter].y]
                recur_output_trace(ind, i, visited)
            end
        end
    end
    visited
end

function forward_connections(ind::CGPInd)
    connections = [[i] for i in 1:length(ind.nodes)]
    for ci in eachindex(ind.nodes)
        connect=[ind.nodes[ci].x,ind.nodes[ci].y]
        for i in 1:2
            conn = connect[i]
            if conn > 0
                if ~(conn in connections[ci])
                    append!(connections[ci], [conn])
                end
                for j in eachindex(connections[conn])
                    if ~(j in connections[ci])
                        append!(connections[ci], [j])
                    end
                end
            end
        end
    end
    connections
end
