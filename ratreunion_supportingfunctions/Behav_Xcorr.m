function [be_xcorr, xaxis, codes] = Behav_Xcorr(be_start_end, be_identcode, betypes, sessstartend, lags, maxlag, normvals)
% be_xcorr = Behav_Xcorr_selfother(be_start_end, be_identcode, betypes, normvals)
%
% Computes a time-lag cross correlogram between behaviors. Y axis is the
% proportion of behavior B instances relative to behavior A instances
%
% For this analysis, positive time lags will be from the end of a behavior,
% negative will be before the beginning of the behavior. The time the
% behavior takes therefore does not get included 
%
%
%Inputs: 
% 
%       - be_start_end -- an n x 2 matrix of start and end times (if 3D,
%                   then function will loop over the layers)
%        - be_identcode -- the identity codes of each behavior
% betypes -- which identity codes to use (default is all)
% lags -- time lags each bin (default is 0.5 s)
% maxlag -- the edge of the xcorr (default is 10 s)
% normvals -- whether to normalize the values by the percent behavior
%
% outputs:
% be_xcor --- a cross correlogram of each pairwise relationship between
% behaviors
% xaxis --- the time lags
% codes --- an m x 2 matrix of which behavior codes correspond to the
% be_xcor rows
%
% nei 1/20
%
% 3/21 added compatibility with different agonistic/play (decimal betypes)
%

if nargin < 7
    normvals = 1;
end

if nargin < 6
    maxlag = 10;
end
if nargin < 5
    lags = 0.5;
end

if nargin < 3
    betypes = unique(be_identcode(:,1));
end
if isempty(lags)
    lags = .5;
end

timelags = [-1*maxlag:lags:0 0:lags:maxlag];


%Here we combine all "agonistic" (or play) together, unless they are
%separately specified (as decimals between -1 to -2)
if sum(betypes == fix(betypes)) == length(betypes)
    be_identcode = fix(be_identcode);
end


s = size(be_start_end);
if length(s) < 3
    s = [s 1];
end

be_xcorr = nan(size(nchoosek(betypes,2),1)+length(betypes), length(timelags), s(3));
codes = nan(size(nchoosek(betypes,2), 1), 2, s(3));
xaxis = timelags;

for sess = 1:s(3)
    s_e_mat = be_start_end(:,:,sess);
    beinds = find(ismember(be_identcode(:,sess), betypes));
    
    s_e_mat = s_e_mat(beinds,:);
    i_mat = be_identcode(beinds,sess);
    
    %pull the indices
    for i = 1:length(betypes)
        typeinds{i} = find(i_mat == betypes(i));
    end
    
    %loop across each pair of behaviors, including the autocorrs
    
    be_ind = 1;
        
    for i = 1:length(betypes)
        for j = 1:length(betypes)
            curind_ref = typeinds{i};
            curind_comp = typeinds{j};
        
            s_e_ref = s_e_mat(curind_ref, :);
            s_e_comp = s_e_mat(curind_comp,:);
            
 %           totcomptime = nansum(s_e_comp(:,2)-s_e_comp(:,1))/(max(be_start_end(:,2, sess))-min(be_start_end(:,1, sess)))  ;
            totcomptime = nansum(s_e_comp(:,2)-s_e_comp(:,1))/(sessstartend(sess,2)-sessstartend(sess,1))  ;


            M = zeros(size(s_e_ref,1), length(timelags));
            mind = 1;
            for k = 1:length(curind_ref)
                tse1 = s_e_comp - s_e_ref(k,1);
                
                %find the comp behaviors that start before the reference,
                %then fill in the the start and end bins with one
                
                % we will create separate vectors for the start time and
                % end time of the comp behavior (relative to the ref). Then
                % we will find where those are, and fill ones for
                % everything in between
                V1a = histc(tse1(:,1), timelags(1:length(timelags)/2));
                V1b = histc(tse1(:,2), timelags(1:length(timelags)/2));
                                
                iV1a = find(V1a);
                iV1b = find(V1b);
                if length(iV1a) > length(iV1b)
                    iV1b = [iV1b ; repmat(length(timelags)/2, length(iV1a)-length(iV1b), 1)];
                elseif length(iV1a) < length(iV1b)
                    iV1a = [1 ; iV1a];
                end
                V1 = V1a;
                
                % here we fill the ones...
                for m = 1:length(iV1a)
                    V1(iV1a(m):iV1b(m)) = 1;
                end
                
                tse2 = s_e_comp - s_e_ref(k,2);
                
                %Now do the same for the second half
                
                V2a = histc(tse2(:,1), timelags((length(timelags)/2+1):end));
                V2b = histc(tse2(:,2), timelags((length(timelags)/2+1):end));
                iV2a = find(V2a);
                iV2b = find(V2b);
                if length(iV2a) > length(iV2b)
                    iV2b = [iV2b ; repmat(length(timelags)/2, length(iV2a)-length(iV2b), 1)];
                elseif length(iV2a) < length(iV2b)
                    iV2a = [1 ; iV2a];
                end
                V2 = V2a;
                for m = 1:length(iV2a)
                    V2(iV2a(m):iV2b(m)) = 1;
                end               
                
                if size(V1,1) == 1
                    V1 = V1';
                    V2 = V2';
                end
                
                
                M(mind,:) = [V1' V2'];
                mind = mind + 1;
            end
            be_xcorr(be_ind,:,sess) = mean(M); %by taking the mean, we normalize by the number of start/end cases of the reference behavior
               	%however, it is probably valuable to also normalize
                %by the number of cases we have of the comparison behavior
                %(thus, a value of 1 means behaviors are at "average
                %levels"
                if normvals == 1
                    be_xcorr(be_ind, :, sess) = be_xcorr(be_ind,:,sess)/totcomptime;
                end
            codes(be_ind,:,sess) = [i j];            
            be_ind = be_ind + 1;
        end
    end
end