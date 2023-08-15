function cumsumbehav = Rdb_CumSum2(rdb_rr, bevec, combinedegus, num_sec)
% cumsum = Rdb_CumSum(rdb_rr, bevec, combinedegus)
%
% creates the cumulative sum matrices for each session
% Inputs: 
%   rdb_rr is main database struct created with ReunionDatabase
%   bevec is the set of behaviors to look for
%   combinedegus is 1 if summing across both degus (cumsum), 0 if not (cumsumID)
%
%  v2 is designed to consider different types of agonistic (e.g.,
%  -1.7, -1.5)
%
%
% nei 10/21
%    - 1/23 added support for longer sessions
%

if nargin < 4
    num_sec = 1200;
end

if nargin < 3
    combinedegus = 0;
end

if isempty(combinedegus)
    combinedegus = 0;
end

if nargin < 2
    bevec = [-1 1 2 3 5];
end

if combinedegus == 1
    numbehaves = length(bevec);
    numanimals = 1;
else
    numbehaves = length(bevec)*2;
    numanimals = 2; %THIS MEANS WE CAN"T APPLY IT TO 3-ANIMAL DATASETS
end    

    
%IMPORTANT: rounding all agonistic/play behaviors together, unless specific
%agonistic/play behaviors are specified
if sum(bevec == ceil(bevec)) == length(bevec)
    roundon = 1;
else
    roundon = 0;
end

    
cumsumbehav = zeros(length(rdb_rr.paircode), floor(num_sec/2)+1, numbehaves);
%cumsumbehav_ht = nan(length(rdb_rr.paircode),1);



for k = 1:length(rdb_rr.paircode)
    curind = k;
    a_ind = find(abs(rdb_rr.be_identcode(:,curind)) > 0 &  ismember(rdb_rr.be_identcode(:,curind), bevec));
    if ~isempty(a_ind) % are we sure we don't want to start with zeros? Probably good to leave-out the no-interaction sessions
                be_time = rdb_rr.be_start_end(:,2,curind)-rdb_rr.be_start_end(:,1,curind);
                be_zeros = zeros(size(be_time));
                timeandzeros = [be_zeros be_time];
                if roundon
                    beident = ceil(rdb_rr.be_identcode(:,curind));
                else
                    beident = rdb_rr.be_identcode(:,curind);
                end
        for i = 1:length(bevec)   
            for j = 1:numanimals
                if numanimals == 1                    
                    aa_ind = find(beident == bevec(i)) ;
                else %no longer combining face-to-face                  	 
                    aa_ind = find(ceil(rdb_rr.be_who(:,j,curind)) == 1 & beident == bevec(i)) ;                    
                end
                if ~isempty(aa_ind)
                    data_a = reshape(timeandzeros(aa_ind,:)', 1, length(aa_ind)*2);
                    time_a = reshape(rdb_rr.be_start_end(aa_ind, :,curind)'-rdb_rr.sessionstart_end(curind,1), 1, length(aa_ind)*2);
            
                    data_a = [0 cumsum(data_a) max(cumsum(data_a))];
                    time_a = [0 time_a 2000];
                    indnan = find(~isnan(time_a));
                	data_a = data_a(indnan);
                 	time_a = time_a(indnan);
                        
                 	t = timeseries(data_a, time_a);
                 	rt = resample(t, [0:2:num_sec]);
                  	vrt = squeeze(rt.Data)';
        
                    cumsumbehav(k,:,i+(j-1)*length(bevec)) = vrt;
                    
                end
            end
        end       
    end
end

