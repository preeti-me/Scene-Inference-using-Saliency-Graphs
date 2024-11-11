clc; clear;
load('GT_sg.mat');  load('candidategraph1_k17.mat'); %load('candidategraph22.mat')

for j=1:10000 

querygraph=candidategraph1_k17{j}; %querygraph=candidategraph22{j};

query_nodeslabels=table2cell(querygraph.Nodes); query_edges=querygraph.Edges;

cansubnode= querygraph.Nodes; subadj=zeros(size(cansubnode,1));

dcansubnode=str2double(cansubnode.Name);

%%%find non-edges in query graph%%%%%%
num_qnodes = size(cansubnode, 1); % Get the number of nodes in the query graph
all_possible_edges = [];

for ii = 1:num_qnodes
    for jj = (ii+1):num_qnodes
     
        edge = [dcansubnode(ii), dcansubnode(jj)];
        all_possible_edges = [all_possible_edges; edge];
    end
end

 query_edgesCell = query_edges.EndNodes; query_endNodesNum = cellfun(@str2double, query_edgesCell);

 non_edges_query_table = setdiff(all_possible_edges, query_endNodesNum, 'rows'); %non-edges in the query graph

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%start_matching_query_to_cgn%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cgn=1:3:4

gtgraph= GT{cgn};

gtnode = table2cell(gtgraph.Nodes); gtedges= gtgraph.Edges; 

subG = subgraph(gtgraph,dcansubnode);
edges = subG.Edges;

%%%find non-edges in GT graph%%%%%%
% num_gtnodes = size(dcansubnode, 1); % Get the number of nodes in the GT
% gtall_possible_edges = [];
% 
% for i = 1:num_gtnodes
%     for j = (i+1):num_gtnodes
%      
%         edge = [dcansubnode(i), dcansubnode(j)];
%         gtall_possible_edges = [gtall_possible_edges; edge];
%     end
% end

gt_edgesCell =edges.EndNodes; gt_endNodesNum = cellfun(@str2double, gt_edgesCell);
non_edges_gt_table = setdiff(all_possible_edges, gt_endNodesNum, 'rows'); %non-edges in the query graph

%%% Calculate weights for each non-edge
non_edges_weights = zeros(size(non_edges_gt_table, 1), 1); 

for i = 1:size(non_edges_gt_table, 1)
    e1 = non_edges_gt_table(i, 1);
    e2 = non_edges_gt_table(i, 2);
    
    s1=gtnode{e1,2}; s2=gtnode{e2,2};

    % Calculate weight based on some criteria
    weight = s1*s2; 
    non_edges_weights(i) = weight;
end

non_Edges.Endnodes=non_edges_gt_table; non_Edges.Weight= non_edges_weights;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numNodes = size(cansubnode,1);

matchedweights=zeros(size(edges,1)); 

ind=[];
if size(query_edges, 1)~=0 && size(edges, 1)~=0

for i = 1:size(query_edges, 1) 

   indices = []; 
   endNodesCell = edges.EndNodes; endNodesNum = cellfun(@str2double, endNodesCell); %gtsubgraph edges

   qendNodesCell = query_edges(i,:).EndNodes;  query_edgesendNodesNum = cellfun(@str2double, qendNodesCell);

  indices = find(ismember(query_edgesendNodesNum, endNodesNum, 'rows'));
  %indices = find(ismember(query_edges(i,:).EndNodes, edges(:,:).EndNodes, 'rows'));
  %ind= indices;

if ~isempty(indices)
    ind(i) = indices;


%%%----%%-------------------------%%%-----%%-------------------------------%%
   if ~isempty(indices)    
     matchedweights(i,indices)=edges.Weight(indices);
   else        
        %matchedweights(i,:)=0;  
        disp('triplet not exist in gt');
    end
%%%----%%-------------------------%%%-----%%-------------------------------%%
else
    %ind(i) = [];
    break;
end

end
%%%%%%%-----------------

if ~isempty(ind)
selectedEdges = endNodesNum(ind, :); %matched %edges %between %query %and %gtsubgraph%
remainingEdges = setdiff(endNodesNum, selectedEdges, 'rows'); % Get the remaining edges

else
    selectedEdges = []; % No matched edges found, set to empty array
    %disp('No matched edges found for query.');
    remainingEdges = endNodesNum;
end


if ~isempty(remainingEdges)
    extracedgesgt= find(ismember(remainingEdges, endNodesNum, 'rows'));
    unmatchedweights= edges.Weight(extracedgesgt);
else
    unmatchedweights=0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
sc_match= sum(sum(matchedweights)); sc_unmatch= sum(sum(unmatchedweights)); %matching weight for similar-edges

%---------------------------------------%
nindi = find(ismember(non_edges_query_table, non_edges_gt_table, 'rows'));

if length(nindi) <= size(non_edges_gt_table,1)
    for nn=1:length(nindi)
       if nindi(nn) <= size(non_edges_gt_table,1)
   ne_matchi(nn)= non_edges_weights(nindi(nn)); ne_match=sum(ne_matchi); %matching weight for similar non-edges
       end
    end
else
 ne_match=0;   
end

sc_match=sc_match + ne_match;
%---------------------------------------%

% if  sc_match>=sc_unmatch
%     matching{cgn,j} = 'matched';
% 
%     score(cgn,j)=sc_match;
% else
%     matching{cgn,j} = 'not matched';
%     score(cgn,j)=0;
% end

score(cgn,j)=sc_match;

%%%%%%%%%%%%%%%%%

elseif size(query_edges, 1)==0 && size(edges, 1)==0
    matching{cgn,j} = 'matched';
    score(cgn,j)=sum(non_edges_weights);
else
    matching{cgn,j} = 'unmatched';
    score(cgn,j)=0;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%end_matching_query_to_cgn%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%select_best_match_graph%%%%%%%%%%%%%%%%%

if score(1, j)==score(3,j)

scene{1,j}='equal';
scene{2,j}=score(1,j);

elseif  score(1, j)>score(3,j)
scene{1,j}='G1';
scene{2,j}=score(1,j);

elseif  score(3, j)>score(1, j)
scene{1,j}='G2';
scene{2,j}=score(3,j);

else
scene{1,j}='unmatched';
scene{2,j}=0;    
end

%%%%%%%%%end_best_match_graph_selection%%%%%%%%%%%%%%%%%

end


 save('nescene_g13_k17.mat', 'scene');


 % all= scene{2,:}; val=mean(all);


corre = find(strcmp(scene, 'G1')); 
wrng= find(strcmp(scene, 'G2')); tf=length(wrng)
correq = find(strcmp(scene, 'equal'));
tp=length(corre); acc= tp/10000
% 
 %%
% 
% subplot(2,1,1); plot(querygraph);
% subplot(2,1,2); plot(gtgraph);  plot(GT{1});
