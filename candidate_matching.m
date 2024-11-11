clc; clear;
load('UGT_sg.mat');  load('candidategraph1_k15.mat'); %load('candidategraph22.mat')

for j=1:10000 %cgn=1:2

querygraph=candidategraph1_k15{j}; %querygraph=candidategraph22{j};

query_nodeslabels=table2cell(querygraph.Nodes); query_edges=querygraph.Edges;

cansubnode= querygraph.Nodes; subadj=zeros(size(cansubnode,1));

dcansubnode=str2double(cansubnode.Name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%start_matching_query_to_cgn%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cgn=1:3:4

gtgraph= UGT{cgn};

gtnode = table2cell(gtgraph.Nodes); gtedges= gtgraph.Edges; 

subG = subgraph(gtgraph,dcansubnode);
edges = subG.Edges;

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


sc_match= sum(sum(matchedweights)); sc_unmatch= sum(sum(unmatchedweights));

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
    score(cgn,j)=0;
else
    matching{cgn,j} = 'unmatched';
    score(cgn,j)=0;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%end_matching_query_to_cgn%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%select_best_match_graph%%%%%%%%%%%%%%%%%

if score(1, j)==score(4,j)

scene{1,j}='equal';
scene{2,j}=score(1,j);

elseif  score(1, j)>score(4,j)
scene{1,j}='G1';
scene{2,j}=score(1,j);

elseif  score(4,j)>score(1, j)
scene{1,j}='G2';
scene{2,j}=score(4,j);

else
scene{1,j}='unmatched';
scene{2,j}=0;    
end

%%%%%%%%%end_best_match_graph_selection%%%%%%%%%%%%%%%%%

end


 %save('scene_g1_k3.mat', 'scene');


 % all= scene{2,:}; val=mean(all);


corre = find(strcmp(scene, 'G1')); 
wrng= find(strcmp(scene, 'G2')); tf=length(wrng)
correq = find(strcmp(scene, 'equal'));
tp=length(corre); acc= tp/10000;

