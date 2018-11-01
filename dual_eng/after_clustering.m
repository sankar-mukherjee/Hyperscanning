%% summarizre the fieldtrip clustering result in excel file


condition = {'convVSnoch','convVSnoch_listen'};

significance = 0.05;
L=1;S=1;

time = [];
channel = [];
freq = [];
prob = [];
type = [];
name = [];k=1;
time1 = [];
channel1 = [];
freq1 = [];
prob1 = [];
type1 = [];
name1 = [];l=1;

time3 = [];
channel3 = [];
freq3 = [];
prob3 = [];
type3 = [];
name3 = [];L=1;

path = 'C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\plottingThesignificant/';
files = dir([path 'fieldtrip__32_10_mwv_mfc_convVSnoch_*.mat']);
    xx=1;xxx=2;

fileIndex = find(~[files.isdir]);
for n = 1:length(fileIndex)
    fileName = files(fileIndex(n)).name;
    load([path fileName]);
    
    if( ~isempty(strfind(fileName,'listen')))
        for i=1:size(within_subj_cluster,1)
            if(iscell(within_subj_cluster{i,xx}))
                if(within_subj_cluster{i,xx}{1,1}.prob <= significance)
                    prob{k,1} =  within_subj_cluster{i,xx}{1,1}.prob;
                    time{k,1} =  num2str((within_subj_cluster{i,xx}{1,1}.time));
                    channel{k,1} =  strjoin(within_subj_cluster{i,xx}{1,1}.channel);
                    type{k,1} = 'positive';
                    freq{k,1} =  i;
                    name{k,1} = fileName;
                    k=k+1;
                end
            end
            if(iscell(within_subj_cluster{i,xxx}))
                if(within_subj_cluster{i,xxx}{1,1}.prob <= significance)
                    prob{k,1} =  within_subj_cluster{i,xxx}{1,1}.prob;
                    time{k,1} =  num2str((within_subj_cluster{i,xxx}{1,1}.time));
                    channel{k,1} =  strjoin(within_subj_cluster{i,xxx}{1,1}.channel);
                    type{k,1} = 'negative';
                    freq{k,1} =  i;
                    name{k,1} = fileName;
                    k=k+1;
                end
            end
            %prelisten
            if(iscell(within_subj_cluster{i,4}))
                if(within_subj_cluster{i,4}{1,1}.prob <= significance)
                    prob3{L,1} =  within_subj_cluster{i,4}{1,1}.prob;
                    time3{L,1} =  num2str((within_subj_cluster{i,4}{1,1}.time));
                    channel3{L,1} =  strjoin(within_subj_cluster{i,4}{1,1}.channel);
                    type3{L,1} = 'positive';
                    freq3{L,1} =  i;
                    name3{L,1} = fileName;
                    L=L+1;
                end
            end
            if(iscell(within_subj_cluster{i,5}))
                if(within_subj_cluster{i,5}{1,1}.prob <= significance)
                    prob3{L,1} =  within_subj_cluster{i,5}{1,1}.prob;
                    time3{L,1} =  num2str((within_subj_cluster{i,5}{1,1}.time));
                    channel3{L,1} =  strjoin(within_subj_cluster{i,5}{1,1}.channel);
                    type3{L,1} = 'negative';
                    freq3{L,1} =  i;
                    name3{L,1} = fileName;
                    L=L+1;
                end
            end
        end
        %         if(~isempty(name))
        %             xlswrite([path condition{2} '_filedtrip_clustering_result.xls'],[name type prob freq time channel],L);
        %             L=L+1;
        %         end
    else
        for i=1:size(within_subj_cluster,1)
            if(iscell(within_subj_cluster{i,1}))
                if(within_subj_cluster{i,1}{1,1}.prob <= significance)
                    prob1{l,1} =  within_subj_cluster{i,1}{1,1}.prob;
                    time1{l,1} =  num2str((within_subj_cluster{i,1}{1,1}.time));
                    channel1{l,1} =  strjoin(within_subj_cluster{i,1}{1,1}.channel);
                    type1{l,1} = 'positive';
                    freq1{l,1} =  i;
                    name1{l,1} = fileName;
                    l=l+1;
                end
            end
            if(iscell(within_subj_cluster{i,2}))
                if(within_subj_cluster{i,2}{1,1}.prob <= significance)
                    prob1{l,1} =  within_subj_cluster{i,2}{1,1}.prob;
                    time1{l,1} =  num2str((within_subj_cluster{i,2}{1,1}.time));
                    channel1{l,1} =  strjoin(within_subj_cluster{i,2}{1,1}.channel);
                    type1{l,1} = 'negative';
                    freq1{l,1} =  i;
                    name1{l,1} = fileName;
                    l=l+1;
                end
            end
        end
        %         if(~isempty(name))
        %             xlswrite([path condition{1} '_filedtrip_clustering_result.xls'],[name type prob freq time channel],S);
        %             S=S+1;
        %         end
    end
    
    
end

[a,b] = sort(cell2mat(freq),'ascend');
NAME = name(b);
TYPE = type(b);
PROB = prob(b);
FREQ = freq(b);
TIME = time(b);
CHANNEL = channel(b);

if not(isempty(freq))
% dlmwrite([path condition{2} '_filedtrip_clustering_result.csv'],[NAME TYPE PROB FREQ TIME CHANNEL],'delimiter',',');
xlswrite([path condition{2} 'PostListen_filedtrip_clustering_result.xls'],[NAME TYPE PROB FREQ TIME CHANNEL]);
end

[a,b] = sort(cell2mat(freq1),'ascend');
NAME = name1(b);
TYPE = type1(b);
PROB = prob1(b);
FREQ = freq1(b);
TIME = time1(b);
CHANNEL = channel1(b);

if not(isempty(freq1))
% dlmwrite([path condition{1} '_filedtrip_clustering_result.csv'],[NAME TYPE PROB FREQ TIME CHANNEL],'delimiter',',');
xlswrite([path condition{1} '_filedtrip_clustering_result.xls'],[NAME TYPE PROB FREQ TIME CHANNEL]);
end

[a,b] = sort(cell2mat(freq3),'ascend');
NAME = name3(b);
TYPE = type3(b);
PROB = prob3(b);
FREQ = freq3(b);
TIME = time3(b);
CHANNEL = channel3(b);

if not(isempty(freq3))
% dlmwrite([path condition{1} '_filedtrip_clustering_result.csv'],[NAME TYPE PROB FREQ TIME CHANNEL],'delimiter',',');
xlswrite([path condition{1} 'PreListen_filedtrip_clustering_result.xls'],[NAME TYPE PROB FREQ TIME CHANNEL]);
end

