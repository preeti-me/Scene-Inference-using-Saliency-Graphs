clc;clear;close all;
addpath('/home/vision/Desktop/new/graph/node2vec-master/emb/')
addpath('/home/vision/Desktop/new/graph/node2vec-master/node2vec_csv/csv/gt/')
addpath('/home/vision/Desktop/new/graph/node2vec-master/node2vec_csv/csv/query/')

load('building_data.mat');


buildingNumber=10; rib=2; view=2; %%GT=B10S2

 fieldName = sprintf('building%d', buildingNumber);

querydata=eval(['buildingdata.' fieldName '.rooms(rib).salientobjects{1,view}']);

for i=1:length(querydata)
labels{i}=querydata(i).labels;
end

unique_labels = {};
for i = 1:numel(labels)
    if sum(strcmp(unique_labels, labels{i})) == 0
        % If the label is not already in the list of unique labels, add it
        unique_labels{end+1} = labels{i};
    else
        % If the label is already in the list of unique labels, add a unique identifier
        j = 1;
        new_label = sprintf('%s_%d', labels{i}, j);
        while sum(strcmp(unique_labels, new_label)) > 0
            j = j + 1;
            new_label = sprintf('%s_%d', labels{i}, j);
        end
        unique_labels{end+1} = new_label;
    end
end

querynodes = unique_labels;


queryadj=eval(['buildingdata.' fieldName '.rooms(rib).newadjacencyMatrix{view}']);
querygraph = graph(queryadj,querynodes);
queryedgelist=graph(queryadj);


%%
rooms=eval(['buildingdata.' fieldName '.rooms']);



for ri=1:length(rooms)

    all_labels={};

for i=1:length(rooms(ri).salientobjects)

  
 %a=buildingdata.building6.rooms(ri).salientobjects{i};
 a=eval(['buildingdata.' fieldName '.rooms(ri).salientobjects{i}']);

 prop={};

  for j=1:length(a)

  prop{j,1}=a(j).labels;

  end
  all_labels = vertcat(all_labels,prop); 
end



 % Calculate Jaccard similarity
    intersection = numel(intersect(querynodes, all_labels));
    uni = numel(union(querynodes, all_labels));
    
    jaccard_similarity(ri) = intersection / uni;


end

%%
% Number of top graphs to select
topN = length(jaccard_similarity);

jaccard_similaritytopind= find(jaccard_similarity>6*max(jaccard_similarity)/10);

% Find the indices of the top N graphs having maximum similarity in
% descending
[~, sortedIndices] = sort(jaccard_similaritytopind, 'descend');
topGraphsIndices = jaccard_similaritytopind(sortedIndices); %sortedIndices(1:topN);

%%
%%%node-alignment%%%%%%%%

for cgn=1:length(topGraphsIndices)


gtgraph=eval(['buildingdata.' fieldName '.rooms(topGraphsIndices(cgn)).newmvmergraph']);

gtnode = gtgraph.Nodes;
gtnode = table2cell(gtnode);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%node2vec%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%gt_table = readtable('karategt_embeddings.csv');

gttxtname = sprintf('/node2vec-master/node2vec_csv/csv/gt/b%dr%d.edge_list_embeddings.csv', buildingNumber, rib);
gt_table = readtable(gttxtname);

gt_nodes = gt_table.Node;
gt_embeddings = table2array(gt_table(:, 2:end));

%query_table = readtable('karatequery_embeddings.csv');
qutxtname = sprintf('/node2vec-master/node2vec_csv/csv/query/b%dr%dview%d.edge_list_embeddings.csv', buildingNumber, rib,view);

query_table = readtable(qutxtname);
query_nodes = query_table.Node;
query_embeddings = table2array(query_table(:, 2:end));

%%

[~, gt_sorted_idx] = sort(gt_nodes);
gt_table_sorted = gt_table(gt_sorted_idx, :);  
gt_embeddings_sorted = table2array(gt_table_sorted(:, 2:end));

[~, query_sorted_idx] = sort(query_nodes);
query_table_sorted = query_table(query_sorted_idx, :);
query_embeddings_sorted= table2array(query_table_sorted(:, 2:end));

% Calculate cosine similarity
%similarity_matrix = pdist2(query_embeddings_sorted, gt_embeddings_sorted, 'cosine');
%%
similarity = zeros(length(query_nodes), length(gt_nodes)); cosSimilarities = zeros(length(query_nodes), length(gt_nodes)); 


    for gi = 1:length(query_nodes)
        for gj=1:length(gtnode)
         %for gj=1:length(gt_nodes)

          if strcmp(querynodes(gi), gtnode(gj))
            que=query_embeddings_sorted(gi,:);
            gte= gt_embeddings_sorted(gj,:);

        cosSimilarities(gi,gj) = cosineSimilarity(que, gte);
          end

        end
        [~, idx] = max(cosSimilarities(gi,:));

        similarity(gi,idx)=1;

        node_mapping(gi,1)=gi; node_mapping(gi,2)=idx;
    end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%tripletmatching%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



edges = gtgraph.Edges;
numNodes = length(gtnode);

adjacencyMatrix = zeros(numNodes);

% Populate the adjacency matrix based on edges
for i = 1:size(edges, 1)
   
    nodeIndex1 = find(strcmp(gtnode, edges.EndNodes(i,1)));
    nodeIndex2 = find(strcmp(gtnode, edges.EndNodes(i,2)));
    
    % Populate the adjacency matrix with the weight (assuming the graph is weighted)
    adjacencyMatrix(nodeIndex1, nodeIndex2) = edges.Weight(i);
    adjacencyMatrix(nodeIndex2, nodeIndex1) = edges.Weight(i); % Assuming the graph is undirected
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
databaseGraph = adjacencyMatrix; 

nodeAlignment = node_mapping;%[1 7; 2 11; 3 12; 4 13; 5 6; 6 14; 7 8];

%%
%%%%%%%adjacencysimilarity_based_on_adjacencymatrix_of_query_gt%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Identify corresponding nodes in the database graph
alignedNodes = nodeAlignment(:, 2);

%Extract the subgraph
subgraph = databaseGraph(alignedNodes, alignedNodes);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%subgraphtripletmatching%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


alignednodeslabel= gtgraph.Nodes(alignedNodes,1);

% Add unique identifier to labels that have the same name
labels=table2cell(alignednodeslabel);

unique_alilabels = {};
for i = 1:numel(labels)
    if sum(strcmp(unique_alilabels, labels{i})) == 0
        % If the label is not already in the list of unique labels, add it
        unique_alilabels{end+1} = labels{i};
    else
        % If the label is already in the list of unique labels, add a unique identifier
        j = 1;
        new_label = sprintf('%s_%d', labels{i}, j);
        while sum(strcmp(unique_alilabels, new_label)) > 0
            j = j + 1;
            new_label = sprintf('%s_%d', labels{i}, j);
        end
        unique_alilabels{end+1} = new_label;
    end
end

unalignednodeslabel = unique_alilabels;



alignedadj=subgraph;
cansubgraph=graph(alignedadj,unalignednodeslabel);

edges = cansubgraph.Edges;
numNodes = length(unalignednodeslabel);

query_nodeslabels=table2cell(querygraph.Nodes); query_edges=querygraph.Edges;

adjacencyMatrix1 = zeros(numNodes);

% Populate the adjacency matrix based on edges
for i = 1:size(query_edges, 1)
   
   
    indices = find(ismember(query_edges(i,:).EndNodes, edges(:,:).EndNodes, 'rows'));

    if ~isempty(indices)
    
     matchedweights(indices)=edges.Weight(indices);
   
    else
        matchedweights(indices)=0;
        disp('triplet not exist in gt');
    end

end

extracedgesgt= find(matchedweights==0);

unmatchedweights= edges.Weight(extracedgesgt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%databaseGraph = adjacencyMatrix; 

if isempty(unmatchedweights)

     scene{topGraphsIndices(cgn)}='graphs matched';
     score(topGraphsIndices(cgn))= sum(matchedweights);

else max(matchedweights)>=max(unmatchedweights)
    
    score(topGraphsIndices(cgn))= sum(matchedweights);
    
     matchedind=find(score==max(score));

    scene{matchedind}='graphs matched';
%scene=buildingdata.building6.rooms(topGraphsIndices(1)).name;

end


end


[maxscore, predicted_room] = max(score);

predicted_scene= sprintf('B%dS%d', buildingNumber, predicted_room)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function similarity = cosineSimilarity(vec1, vec2)
    % Ensure the input vectors have the same length
    if numel(vec1) ~= numel(vec2)
        error('Input vectors must have the same length');
    end

    % Compute the dot product of the two vectors
    dotProduct = dot(vec1, vec2);

    % Compute the norms of the vectors
    normVec1 = norm(vec1);
    normVec2 = norm(vec2);

    % Compute the cosine similarity
    similarity = dotProduct / (normVec1 * normVec2);
end



