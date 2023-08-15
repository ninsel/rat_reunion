function [condmat, scorercell] = RR_OrgData(rdb, bigmat, pairs, sessions)
%condmat = RR_OrgData(bigmat, pairs, sessions)
%
%creates a condition matrix from a "big" matrix (dyads x data) based on a list of 
% dyad pair numbers and sessions. If pairs and sessions are empty it
% chooses all pairs. If sessions empty it chooses all sessions
%
% condmat is pairs x interactions(?) x exposurenumber
%
%
% nei 10/19
%


if nargin < 4
    sessions = unique(rdb.exposurenum);
end

if nargin < 3
    pairs = unique(rdb.paircode);
end


condmat = nan(length(pairs), size(bigmat,2), length(sessions));
scorercell = cell(length(pairs), length(sessions));
 for i = 1:length(pairs)
     curind = find(rdb.paircode == pairs(i));
     sessnums = rdb.exposurenum(curind);
     for j = 1:length(sessnums)
         condmat(i,:, sessnums(j)) = bigmat(curind(j),:);    
         scorercell{i,j} = rdb.scorer{curind(j)};
     end
 end
 