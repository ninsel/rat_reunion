function [be_start_end, be_identcode, be_who, be_ident, sess_se] = processBORIS(filename, posnegbehave)
%Edited by PDH 12/20
%
%[start_end identcode who] = processBORIS(filename, posnegbehave)
%
% takes the BORIS file and processes it into... 
%OUTPUTS:
% be_start_end: start-end times of each behavior
% be_identcode: the number associated with that particular behavior (-1 to 4?)
% be_who: which degu is responsible for the event
% be_ident: the actual name of the behavior
% sess_se: the start and end times of the session
%
% INPUTS:
% filename: the name of the BORIS events file (should include the directory) 
% posnegbehave: a containers object. It should have one event name ("START") mapped
% to the value 98 (the session start) and one (e.g., "STOP") mapped to value 99 (the
% session end)
%
% nei 12/18
%

num_headerlines = 1;
%BORIS files seem to have 16 lines of header
%  ...This is actually unnecessary because we cut out everything that's
%  outside of the "start" and end" timestamps

col_ts = 1; %timestamp column 
col_sub = 2; %subject column
col_behav = 3; %behavior column
col_startend = 4; %start-end column

%find the name of the start and end session codes
values = posnegbehave.values;
keys = posnegbehave.keys;
v = [values{:}];
indkey_start = find(v == 98);
indkey_end = find(v == 99);
startkey = keys{indkey_start};
endkey = keys{indkey_end};
%the following code showed [~,~,ppdata]=readxls(filename);
%changed due to the output of readxls with R2020 matlab compatibility not
%necesitating the third output of readxls
[ppdata] = readcell(filename);
    ppdata = ppdata((num_headerlines+1):end,[1 5 6 9]); % we only need these 4 columns of data
    
    b_start_ind = find(strcmpi(startkey, ppdata(:,col_behav))); %may be different for different experiments!
    b_end_ind = find(strcmpi(endkey, ppdata(:,col_behav)));
    
    if isempty(b_start_ind) %if no "start", then find "start" of the first behavior
        b_start_ind = find(strcmpi('START', ppdata(:,col_startend)));
        b_start_ind = b_start_ind(1);
    elseif length(b_start_ind) > 1
        b_start_ind = b_start_ind(1);
    end
    if isempty(b_end_ind)        
        b_end_ind = size(ppdata,1);
    elseif length(b_end_ind) > 1
        b_end_ind = b_end_ind(end);
    end
    
    if ischar(ppdata{b_start_ind,col_ts})
        sess_se = [str2num(ppdata{b_start_ind,col_ts}) str2num(ppdata{b_end_ind, col_ts})];
    else    
        sess_se = [ppdata{b_start_ind,col_ts} ppdata{b_end_ind, col_ts}];
    end
    
    ppdata = ppdata(b_start_ind:b_end_ind,:);
    
    %find all of the behavior start and end times   
	bstarts = find(strcmp('START', ppdata(:,col_startend)));
 	bends = find(strcmp('STOP', ppdata(:,col_startend)));

    allsub = find(cellfun(@isstr,ppdata(:, col_sub)));
    whoops = unique(ppdata(allsub,col_sub));
    whoops = whoops(find(~cellfun(@isempty,whoops)));
    lwho = length(whoops);

    %Sometimes the second degu doesn't behave! (or the first one doesn't)
    %This if statement was added to ensure that we always assume at least 2
    %degus, and that degu "1" and "2" are ordered correctly
    if lwho == 1
        lwho = 2;
        newwhoops = cell(2,1);
        if ~isempty(strfind(whoops{1}, '1'))
            newwhoops{1} = whoops{1};
        elseif ~isempty(strfind(whoops{1}, '2'))
            newwhoops{2} = whoops{1};
        end
        whoops = newwhoops;
    end
    
    be_start_end = nan(900,2);
    be_identcode = nan(900,1);
    be_who = zeros(900,lwho);
    be_ident = cell(900,1);
    

 %Loop through the behavior events, adding them to the start_end matrix and
 %identity cell array
	    
    for j = 1:length(bstarts)
        if ischar(ppdata{bstarts(j), col_ts})            
            be_start_end(j,1) = str2num(ppdata{bstarts(j), col_ts});
        else
            be_start_end(j,1) = ppdata{bstarts(j), col_ts};
        end
            be_ident{j} = ppdata{bstarts(j), col_behav};
            if isKey(posnegbehave, lower(ppdata{bstarts(j), col_behav}))
               be_identcode(j) = posnegbehave(lower(ppdata{bstarts(j),col_behav}));
            else
               be_identcode(j) = nan;
            end
            %formerly the line was ~isnan (when??)
            %changed below on 7/13/2022 because was giving weird result
            imiss = ismissing(ppdata{bstarts(j), col_sub});
            if length(imiss) > 1 | imiss == 0  %WARNING! ISMISSING CHANGED BEHAVIOR IN MATLAB v2022a
                for k = 1:lwho                    
                    if strcmpi(ppdata{bstarts(j), col_sub}, whoops{k})
                        be_who(j,k) = 1;
                    end
                end       
            end
            indsamebehav = find(strcmp(ppdata{bstarts(j), col_behav}, ppdata(bends, col_behav)) & bends > bstarts(j));
            if ~isempty(indsamebehav)
                if ischar(ppdata{bends(indsamebehav(1)), col_ts})
                    be_start_end(j,2) = str2num(ppdata{bends(indsamebehav(1)), col_ts});
                else
                    be_start_end(j,2) = ppdata{bends(indsamebehav(1)), col_ts};
                end
            end
    end

end

