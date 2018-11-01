

load([project.paths.processedData '/convergence/convergence_' num2str(project.gmmUBM.gmmcomp) '_10_mwv_mfc.mat']);
load([project.paths.processedData '/neweegdata/EEG.mat'],'EEG');
load([project.paths.processedData '/processed_data_word_level.mat'],'D');

%%
conv_idx = get_condition_index(D,convergence_data,'convergence');
noCh_idx = get_condition_index(D,convergence_data,'noch');

data_conv = [];data_noCh=[];
for sub = 5:length(project.subjects.list)
    for c=1:2
        i = find(ismember(EEG{sub,c}.trialinfo(:,5),conv_idx));
        if not(isempty(i))
            cfg = [];
            cfg.trials = i;
            data_conv{sub,c} = ft_selectdata(cfg,EEG{sub,c});
        end
        if not(isempty(i))
            i = find(ismember(EEG{sub,c}.trialinfo(:,5),noCh_idx));
            cfg = [];
            cfg.trials = i;
            data_noCh{sub,c} = ft_selectdata(cfg,EEG{sub,c});
        end
    end
end

%%
c= 2;
config.condition = {'PreSpeech','PostListen','PreListen'};
config.trial_time_window = [-0.5 0.5];
config.analysis_time_window = {[-0.5 0],[0 0.5],[-0.5 0]};
            
analysis_time_window = config.analysis_time_window{c};

a = find(cellfun('isempty',data_conv(:,c)));
b = find(cellfun('isempty',data_noCh(:,c)));
a = [a; b];
a = unique(a);
data_conv2 = data_conv(:,c);
data_noCh2 = data_noCh(:,c);
data_conv2(a) = [];
data_noCh2(a) = [];
Nsub = length(data_conv2);
cfg=[];
cfg.method    = 'distance';
neighbours       = ft_prepare_neighbours(cfg, data_conv2{1});

%% rereference
cfg = [];
cfg.reref       = 'yes';
cfg.channel = {'all'};
cfg.refchannel = {'all'};
for sub = 1: length(data_conv2)
    data_conv2{sub}        = ft_preprocessing(cfg,data_conv2{sub});
    data_noCh2{sub}        = ft_preprocessing(cfg,data_noCh2{sub});
end

%%  ERSP 
[CONV_tf,~,GA_tf_CONV] = compute_ERSP(data_conv2,config.trial_time_window,25/1e3,0);
[NOCH_tf,~,GA_tf_NOCH] = compute_ERSP(data_noCh2,config.trial_time_window,25/1e3,0);

%% fieldtrip cluster
% ersp:
within_subj_cluster = [];
for freq = 1:size(GA_tf_CONV.freq,2)
    within_subj_stat = within_subj_tf_cluster(GA_tf_CONV,GA_tf_NOCH,neighbours,freq,Nsub, analysis_time_window);
    [within_subj_cluster{freq,1},within_subj_cluster{freq,2}] = significant_cluster_time_freq_channel(within_subj_stat);
    within_subj_cluster{freq,3} = within_subj_stat;    
end

save([save_cluster_data 'fieldtrip_' AAAA '_' fileName],'within_subj_cluster');

























