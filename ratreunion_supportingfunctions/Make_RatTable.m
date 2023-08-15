function [degutable, scorercell] = Make_RatTable(rdb_rr, inds, sumbehavID2)

%degutable = Make_RatTable(rdb_rr, inds)
%
% degutable = ...
% 1-5 [degu_num paircodecag paircodestr paircodenstr age...
% 6-10  cag1 cag2 cag3 cag4 cag5...
% 11-15     str1 str2 str3 str4 str5 ... 
% 16-21         nstr1 nstr2 ncag1 ncag2 ncag3 ncag4 ...
% 22-24             ISO SEP CTL              
%         ]
%
%
% nei 3/22 (based on mk_degutable)

if nargin < 3
    betypes = [-1 1 2 3 5]; % agonistic, grooming, rear sniffing, face-to-face, body sniffing
    sumbehav = reun_mksumbehav(rdb_rr, betypes);
    betypesID = [-1 1 2 5];
    sumbehavID = reun_mksumbehav(rdb_rr, betypesID, 2);
    sumbehavID2 = [sumbehavID sumbehav(:,4)];
end

if isempty(inds)
    inds = 1:length(rdb_rr.paircode);
end


 iso_ind = find(strcmp(rdb_rr.condition, 'ISO'));
 sep_ind = find(strcmp(rdb_rr.condition, 'SEP'));
 min_ind = find(strcmp(rdb_rr.condition, 'CTL'));
 cofind{1} = iso_ind;
 cofind{2} = sep_ind;
 cofind{3} = min_ind;
 cofind{4} = find(strcmp(rdb_rr.condition, 'RR'));

 oldstrangerind = find(rdb_rr.stranger == 1 | rdb_rr.stranger == 2 | rdb_rr.stranger == 3);
 newstrangerind = find(rdb_rr.stranger == 4);
 cagemateind = intersect(find(rdb_rr.stranger == 0), cofind{4}); 

alldegus = unique([rdb_rr.deguA(inds) ; rdb_rr.deguB(inds)]);
dABind{1} = [1:4 9]; % inds onto the sumbehavID2--currently hard-coded for he specific
dABind{2} = [5:8 9]; %  behaviors used, but should be made flexible

csnABinds = {cagemateind, oldstrangerind, newstrangerind};

for i = 1:9
    exposurenum_ind{i} = intersect(find(rdb_rr.exposurenum == i), cofind{4});
end

degutable = nan(length(alldegus), 25,5); % the "5" should also change according to the number of behaviors
scorercell = cell(length(alldegus), 25);


for i = 1:length(alldegus)
    curind_AB{1} = find(rdb_rr.deguA == alldegus(i));
    curind_AB{2} = find(rdb_rr.deguB == alldegus(i)); 
    degutable(i,1) = alldegus(i);
    
    for j = 1:2
        for k = 1:3
            csnAB = intersect(curind_AB{j}, csnABinds{k});
                for m = 1:5
                    curind = intersect(intersect(csnAB, exposurenum_ind{m}), inds);                    
                    if ~isempty(curind)
                        curind = curind(1); %REMOVVE LATER 
                        degutable(i,1+k) = rdb_rr.paircode(curind);
                        tableind = 5+ (k-1)*5 + m;
                        degutable(i, tableind, :) = sumbehavID2(curind, dABind{j});
                        scorercell{i,tableind} = rdb_rr.scorer{curind};
                    end
                end  
                if k == 2
                    for n = 6:9
                        curind = intersect(intersect(csnAB, exposurenum_ind{n}), inds);
                        if ~isempty(curind)
                             curind = curind(1); %REMOVVE LATER 
                            tableind = 5+3*5+n-5;
                            degutable(i, tableind, :) = sumbehavID2(curind, dABind{j}); 
                            scorercell{i,tableind} = rdb_rr.scorer{curind};
                        end
                        
                    end
                end
        end
        for k = 1:3
            curind = intersect(curind_AB{j}, cofind{k});
            if ~isempty(curind)
                curind = curind(1); %REMOVVE LATER 
                tableind = 21+k;
                degutable(i, tableind, :) = sumbehavID2(curind, dABind{j});
                scorercell{i,tableind} = rdb_rr.scorer{curind};
            end
        end
    end
end