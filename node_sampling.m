function sampled_nodes = node_sampling(G, salient_scores, num_nodes)

    % Assign scores to nodes (e.g., using degree centrality)
    %salient_scores = centrality(G, 'degree');
    
    % Normalize scores to probabilities
    probabilities = salient_scores / sum(salient_scores);
    %%
%     % Sample nodes based on their probabilities
%     sampled_indices = randsample(numnodes(G), num_nodes, true, probabilities);
%     
%     % Ensure uniqueness of sampled indices
%     while numel(unique(sampled_indices)) ~= numel(sampled_indices)
%         % Resample nodes if duplicates are found
%         sampled_indices = randsample(numnodes(G), num_nodes, true, probabilities);
%     end
    %%
    % Sample nodes based on their probabilities
    sampled_nodes = [];
    while numel(sampled_nodes) < num_nodes
        % Sample a single node
        sampled_index = randsample(numnodes(G), 1, true, probabilities);
        % Check if the sampled node is already in the list
        if ~ismember(sampled_index, sampled_nodes)
            % Add the sampled node if it's unique
            sampled_nodes = [sampled_nodes, sampled_index];
        end
    end
 

    %%
    % Convert indices to node IDs
    %%sampled_nodes = G.Nodes.Name(sampled_indices);
   %% sampled_nodes = sampled_indices;
end

