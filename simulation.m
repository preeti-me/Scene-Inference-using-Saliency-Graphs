clc; clear; close all;

fid = fopen('sg1.txt'); 
data = textscan(fid, '%s %s');
fclose(fid);

% Extract edges from the data
edges = [str2double(data{1}), str2double(data{2})];
G = graph(edges(:,1), edges(:,2));



%figure; plot(G, 'NodeColor', 'red', 'MarkerSize',9, 'NodeFontSize',22,'LineWidth',2,'EdgeColor','black'); title('Original graph');

% Assign importance scores to nodes
%salient_scores = [0.1479, 0.051632, 0.053632, 0.052632, 0.3158, 0.10626, 0.1679, 0.10426];
salient_scores =[0.003474,	0.030226,	0.005039, 0.0106, 0.0898, 0.07584, 0.03461,	0.1037,	0.0037597,	0.047888,	0.04164,	0.0835,	0.08679,	0.020397,	0.053457,	0.0486,	0.070544,	0.07742,	0.08237,	0.030128];
%salient_scores=[0.0216, 0.04, 0.012, 0.0412, 0.17, 0.206, 0.005, 0.015, 0.022, 0.07, 0.105, 0.10, 0.111, 0.003, 0.013, 0.03, 0.006, 0.0115, 0.002, 0.0157];

%ci=1;
%for ni=3%3:2:17
ni=7;
for ci=1:10000

% Sample nodes from the graph
%sampled_nodes = node_importance_sampling(salient_scores, 3);
sampled_nodes = node_sampling(G, salient_scores, ni);

disp('Sampled nodes:'); disp(sampled_nodes);

subadj=zeros(length(sampled_nodes),length(sampled_nodes));

% Create a subgraph from the sampled nodes
%subgraph_edges = subgraph(G, sampled_nodes);
subgraph_edges = edges(ismember(edges(:,1), sampled_nodes) & ismember(edges(:,2), sampled_nodes), :);
%subadj(subgraph_edges(:,1), subgraph_edges(:,2))=1; subadj(subgraph_edges(:,2), subgraph_edges(:,1))=1;


for i = 1:size(subgraph_edges, 1)
    row = find(sampled_nodes == subgraph_edges(i, 1));
    col = find(sampled_nodes == subgraph_edges(i, 2));
    subadj(row, col) = 1; subadj(col, row) = 1; 
end


subnodes= cellfun(@num2str, num2cell(sampled_nodes), 'UniformOutput', false);

subgraph = graph(subadj,subnodes);

candidategraph1_k7{ci}=subgraph;
%ci=ci+1;

%figure; plot(subgraph, 'NodeColor', 'red', 'MarkerSize', 9, 'NodeFontSize', 22, 'LineWidth', 2, 'EdgeColor', 'black'); title('Sampled subgraph');

end
%%

% % Sample nodes based on their importance scores
% function sampled_nodes = node_importance_sampling(node_saliency, num_nodes)
%     % Calculate cumulative probabilities for sampling nodes based on their saliency scores
%     cum_probabilities = cumsum(node_saliency);
%     total_saliency = cum_probabilities(end);
%     
%     % Sample nodes based on their cumulative probabilities
%     sampled_nodes = [];
%     while length(sampled_nodes) < num_nodes
%         rand_val = rand * total_saliency;
%         for i = 1:length(cum_probabilities)
%             if rand_val <= cum_probabilities(i)
%                 sampled_nodes = [sampled_nodes, i];
%                 break;
%             end
%         end
%         sampled_nodes = unique(sampled_nodes);  % Ensure uniqueness
%     end
% end