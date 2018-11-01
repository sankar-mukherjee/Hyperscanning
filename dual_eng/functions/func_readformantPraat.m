function [f1,f2,f3,f4,f5,bw1,bw2,bw3,bw4,bw5] = func_readformantPraat(filename,datalen)
% [labels, start, stop] = func_readTextgrid(filename)
% Input:  filename - textgrid file
% Output: labels, start, stop - vectors containing textgrid data
% Notes:  Functions seeks out the "xmin", "xmax", and "text" labels within
% a textgrid file.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

% Modified by Kate Silverstein 2013-07-23


% TODO move this field into settings
%     POINT_BUFFER = 0.025; % 25 ms buffer on either side of the point

if (exist(filename, 'file') == 0)
    fprintf('Error: %s not found\n', filename);
    labels = NaN; start = NaN; stop = NaN;
    return;
end

% labels = [];
% start = [];
% stop = [];

fid = fopen(filename, 'r', 'l', 'UTF-8');
C = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);

C = C{1};
tiers = 0;
proceed_int = 0; % proceed with intervals
proceed_pnt = 0; % proceed with point-sources
xmin = 0;
xmax = 1;

%     printf('\n');
points = [];
times = [];
value =[];
for k=1:length(C)
    % try to read a string in the format: %s = %s
    if (isempty(C{k}))
        continue;
    end
    
    % intervals
    t = regexp(C{k}, '\s*(formants[:]\ssize)\s=\s([\d]+)', 'tokens');
    if (~isempty(t)) % we found the start of a new tier, now allocate memory
        formants_column = str2num(cell2mat(t{1,1}(2)));
    end
    
    t = regexp(C{k}, '\s*(points[:]\ssize)\s=\s([\d]+)', 'tokens');
    if (~isempty(t))
        points = [points;str2num(cell2mat(t{1,1}(2)))];
    end
    
    t = regexp(C{k}, '\s*(time)\s=\s([.\d]+)', 'tokens');
    if (~isempty(t))
        temp = cell2mat(t{1,1}(2));
        times = [times;round(str2num(temp)*1000)/1000];
    end
    
    t = regexp(C{k}, '\s*(value)\s=\s([\d]+[.\d]+)', 'tokens');
    if (~isempty(t))
        temp = cell2mat(t{1,1}(2));
        value = [value;round(str2num(temp)*1000)/1000];
    end
    
end %endfor



f1(:,1) = times(1:points(1));
f1(:,2) = value(1:points(1));    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];

f2(:,1) = times(1:points(1));
f2(:,2) = value(1:points(1));    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];

f3(:,1) = times(1:points(1));
f3(:,2) = value(1:points(1));    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];

f4(:,1) = times(1:points(1));
f4(:,2) = value(1:points(1));    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];

f5(:,1) = times(1:points(1));
f5(:,2) = value(1:points(1));    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];
% bw
bw1(:,1) = times(1:points(1));
bw1(:,2) = value(1:points(1));    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];

bw2(:,1) = times(1:points(1));
bw2(:,2) = value(1:points(1));    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];

bw3(:,1) = times(1:points(1));
bw3(:,2) = value(1:points(1));    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];

bw4(:,1) = times(1:points(1));
bw4(:,2) = value(1:points(1));    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];

%% have to check becasue praat is not working with session 2 word 10 intensity file is not generation correctly
if(isempty(times))
    disp('ccccccccccccc');
    bw5(:,1) = 0;
    bw5(:,2) = 0;    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];
else
    bw5(:,1) = times(1:points(1));
    bw5(:,2) = value(1:points(1));    times(1:points(1)) = [];    value(1:points(1)) = [];    points(1) = [];
end


%%
if(isempty(f5))
    f5 = [0 0];
    bw5 = [0 0];
end
if(isempty(f4))
     f4 = [0 0];
    bw4 = [0 0];
end
if(isempty(f3))
     f3 = [0 0];
    bw3 = [0 0];
end
if(isempty(f2))
     f2 = [0 0];
    bw2 = [0 0];
end
if(isempty(f1))
     f1 = [0 0];
    bw1 = [0 0];
end
%% smoothing and matching it to original length
all  = [{f1} {f2} {f3} {f4} {f5} {bw1} {bw2} {bw3} {bw4} {bw5}];

for i=1:10
temp1 = nan(datalen, 1); 
temp = cell2mat(all(1,i));
t = round(temp(:,1) * 1000);  % time locations from praat pitch track

%KY Since Praat outputs no values in silence/if no f0 value returned, must pad with leading
% undefined values if needed, so we set start time to 0, rather than t(1)
if(length(t)  > 1)
temp1(t) = temp(:,2);
yy = spline(t(1):t(end),temp1(t(1):t(end)),t(1):t(end));
start_pad = 1:t(1);
end_pad = 1:length(temp1)-t(end);
temp1 = [zeros(1,size(start_pad,2)) yy zeros(1,size(end_pad,2))];
else
    temp1 = 0;
end
all{2,i} = temp1;
end


f1 = all{2,1};
f2 = all{2,2};
f3 = all{2,3};
f4 = all{2,4};
f5 = all{2,5};

bw1 = all{2,6};
bw2 = all{2,7};
bw3 = all{2,8};
bw4 = all{2,9};
bw5 = all{2,10};



end %endfunction



