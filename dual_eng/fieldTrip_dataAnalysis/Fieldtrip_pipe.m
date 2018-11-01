load([project.paths.processedData '/processed_data_word_level.mat'],'D');

time_window = [-0.5 0.5];   %[-0.2 0.6]
timeStep = 25;
cond = {'speech','listen'};
subcond = {'PreSpeech','PostListen','PresListen'};

%% preprocess and clean
eeg_data = [];
for sub = 16:length(project.subjects.list)
    
    partner = project.subjects.partner(sub);
    
    eeg_data{sub,1} = FieldTrip_preprocess(project.subjects.data(sub).name,sub,partner,project,time_window,cond{1},D);
    eeg_data{sub,2} = FieldTrip_preprocess(project.subjects.data(sub).name,sub,partner,project,time_window,cond{2},D);

end
save([project.paths.processedData '/neweegdata/eeg_raw.mat'],'eeg_data');

%%
% remove long delays 5 95 percentile
RT=[];
for sub = 5:length(project.subjects.list)
    RT = [RT;eeg_data{sub,1}.trialinfo(:,2)];
end
RT_limit = prctile(RT,[5 95]); %5th and 95th percentile
RT=[];
for sub = 5:length(project.subjects.list)
    RT = [RT;eeg_data{sub,2}.trialinfo(:,2)];
end
RT_limit = [RT_limit;prctile(RT,[5 95])]; %5th and 95th percentile

EEG = [];
for sub = 5:length(project.subjects.list)
    for c=1:2       
        i = find(eeg_data{sub,c}.trialinfo(:,2) >= RT_limit(c,1) & eeg_data{sub,c}.trialinfo(:,2) <= RT_limit(c,2));        
        cfg = [];
        cfg.trials = i;
        EEG{sub,c} = ft_selectdata(cfg,eeg_data{sub,c});
    end
end
save([project.paths.processedData '/neweegdata/EEG.mat'],'EEG');


%% rereference
cfg = [];
cfg.reref       = 'yes';
cfg.channel = {'all'};
target_data        = ft_preprocessing(cfg,target_data);


%%
a = eeg_data(~cellfun('isempty',eeg_data));

a=eeg_data(5:end,:);

[tf,tf_d,GA_tf] = compute_ERSP(a(:,1),time_window,timeStep/1e3,0);
[tf1,tf_d1,GA_tf1] = compute_ERSP(a(:,2),time_window,timeStep/1e3,0);

sub = 1;
cfg = [];
% cfg.baseline     = [-0.2 0];
% cfg.baselinetype = 'absolute';
% cfg.zlim         = [-3e-27 3e-27];
cfg.showlabels   = 'yes';
cfg.layout       = 'biosemi64.lay';
figure;ft_multiplotTFR(cfg, GA_tf);
figure;ft_multiplotTFR(cfg, GA_tf1);

cfg = [];
cfg.xlim         = [time_window(1):0.1:time_window(2)];
% cfg.ylim         = [15 20];
cfg.marker       = 'on';
cfg.layout       = 'biosemi64.lay';
figure;ft_topoplotTFR(cfg, GA_tf);
figure;ft_topoplotTFR(cfg, GA_tf1);

[avg_erp,GA_avg_erp,scd_avg_erp] = compute_ERP(a(:,2),time_window);
%  whole brain plot
cfg = [];
cfg.showlabels  = 'yes';
cfg.layout    	= 'biosemi64.lay';
figure; ft_multiplotER(cfg,GA_avg_erp);
% idnividual investigate
cfg = [];
cfg.xlim = time_window;
cfg.channel = 'C5';
figure;ft_singleplotER(cfg,GA_avg_erp);
