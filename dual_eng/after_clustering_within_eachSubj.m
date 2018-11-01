cfg = [];
cfg.alpha            = 0.05;
cfg.parameter = 'stat';
% cfg.zlim   = [-4 4];
cfg.layout = 'biosemi64.lay';

for freq = 1:40
    stat = within_trial_cluster{1,1}{freq,3};
    figure;ft_clusterplot(cfg, stat);
    hold on;suptitle(['Frequency ' num2str(freq)]);
end



significance = 0.05;
L=1;S=1;

time1 = [];
channel1 = [];
freq1 = [];
prob1 = [];
type1 = [];
name1 = [];l=1;

for subjects =1:length(within_trial_cluster)
    
    
    within_subj_cluster = within_trial_cluster{subjects,1};
    for i=1:size(within_subj_cluster,1)
        if(iscell(within_subj_cluster{i,1}))
            if(within_subj_cluster{i,1}{1,1}.prob <= significance)
                if not(within_subj_cluster{i,1}{1,1}.time(1) == within_subj_cluster{i,1}{1,1}.time(2))
                    prob1{l,1} =  within_subj_cluster{i,1}{1,1}.prob;
                    time1{l,1} =  num2str((within_subj_cluster{i,1}{1,1}.time));
                    channel1{l,1} =  strjoin(within_subj_cluster{i,1}{1,1}.channel);
                    type1{l,1} = 'positive';
                    freq1{l,1} =  i;
                    name1{l,1} = subjects;
                    l=l+1;
                end
            end
        end
        if(iscell(within_subj_cluster{i,2}))
            if(within_subj_cluster{i,2}{1,1}.prob <= significance)
                if not(within_subj_cluster{i,2}{1,1}.time(1) == within_subj_cluster{i,2}{1,1}.time(2))
                    prob1{l,1} =  within_subj_cluster{i,2}{1,1}.prob;
                    time1{l,1} =  num2str((within_subj_cluster{i,2}{1,1}.time));
                    channel1{l,1} =  strjoin(within_subj_cluster{i,2}{1,1}.channel);
                    type1{l,1} = 'negative';
                    freq1{l,1} =  i;
                    name1{l,1} = subjects;
                    l=l+1;
                end
            end
        end
    end
    
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
    xlswrite(['a_filedtrip_clustering_result.xls'],[NAME TYPE PROB FREQ TIME CHANNEL]);
end












