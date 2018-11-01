%% reaction time confound with the fieldtrip result 

load([project.paths.processedData '/processed_data_word_level.mat'],'D');
load([project.paths.processedData '/convergence/convergence_32_10_mwv_mfc.mat']);

os = system_dependent('getos');
if  strncmp(os,'Linux',2)
    prespeech_path = [project.paths.processedData '/RT_Fieldtrip/'];
    postlisten_path = [project.paths.processedData '/RT_Fieldtrip/'];
    prelisten_path = [project.paths.processedData '/RT_Fieldtrip/'];
else
    prespeech_path = 'C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\prespeech\importent_nobaseline_1sec_nolog_sepcond_oldsettings_5ms_-500-0\';
    postlisten_path = 'C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\postlisten\importent_nobaseline_5ms_-500-0_0-500_oldsettings_listen_5sec_sepcond\';
    prelisten_path = 'C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\-1to1EEG_config\1secRT\';
end

conv_idx = get_condition_index(D,convergence_data,'convergence');
conv_idx = check_reactionTime(conv_idx,D,5);
noCh_idx = get_condition_index(D,convergence_data,'noch');
noCh_idx = check_reactionTime(noCh_idx,D,5);
C_RT = D(conv_idx,14);
N_RT = D(noCh_idx,14);


a=[C_RT ; N_RT];
b = prctile(a,[5 95]); %5th and 95th percentile
outlierIndex = C_RT < b(1) | C_RT > b(2);
%remove outlier values
conv_idx(outlierIndex) = [];C_RT(outlierIndex) = [];
outlierIndex = N_RT < b(1) | N_RT > b(2);
%remove outlier values
noCh_idx(outlierIndex) = [];N_RT(outlierIndex) = [];


A = [mean(C_RT) mean(N_RT)];
B = [std(C_RT) std(N_RT)];
B = [std(C_RT)/length(C_RT) std(N_RT)/length(N_RT)];

figure;
bar(1:length(A),A);hold on
errorbar(1:length(A),A,B,'.')

[p,h,stats] = ranksum(C_RT,N_RT)

%% speech plot

load([prespeech_path 'speech_tfr.mat'],...
'CONV_tf','NOCH_tf');

channel   = {'F5','F7','FT7','FC5'};
time_w = [-0.27  -0.19];
freq = [12 14];
prespeech = compute_reactiome_realtion(D,CONV_tf,NOCH_tf,conv_idx,noCh_idx,channel,freq,time_w);
figure;
scatter(prespeech.C_RT,prespeech.C_mean,'.b');hold on;
scatter(prespeech.N_RT,prespeech.N_mean,'.r');
title('PreSpeech');
ylabel('Power (\muV^{2})');
xlabel('ReactionTime (s)');

[p,h] = corr(prespeech.C_RT,prespeech.C_mean)

%% postlisten plot

load([postlisten_path 'listen_0-500.mat'],...
'CONV_tf','NOCH_tf');

channel   = {'F3','F5','F7','FC5','FC3','C3','C5'};
time_w = [0.05     0.10];
freq = [24 29];
postlisten = compute_reactiome_realtion(D,CONV_tf,NOCH_tf,conv_idx,noCh_idx,channel,freq,time_w);
figure;
scatter(postlisten.C_RT,postlisten.C_mean,'.b');hold on;
scatter(postlisten.N_RT,postlisten.N_mean,'.r');
title('postlisten');
ylabel('Power');
xlabel('ReactionTime');


channel   = {'AF8','F6','F8','FT8','FC6'};
time_w = [0.07     0.125];
freq = [32 34];
postlisten = compute_reactiome_realtion(D,CONV_tf,NOCH_tf,conv_idx,noCh_idx,channel,freq,time_w);
figure;
scatter(postlisten.C_RT,postlisten.C_mean,'.b');hold on;
scatter(postlisten.N_RT,postlisten.N_mean,'.r');
title('postlisten');
ylabel('Power');
xlabel('ReactionTime');
%% prelisten
% 21 -24 cluster
load([prelisten_path 'listen_-500-0.mat'],...
'CONV_tf','NOCH_tf');

% cluster 28-30 hz

channel   = {'C4','C6','CP6','CP4'};
time_w = [-0.26     -0.19];
freq = [22 24];
prelisten1 = compute_reactiome_realtion(D,CONV_tf,NOCH_tf,conv_idx,noCh_idx,channel,freq,time_w);
figure;
scatter(prelisten1.C_RT,log(prelisten1.C_mean),'.b');hold on;
scatter(prelisten1.N_RT,log(prelisten1.N_mean),'.r');
title('prelisten1');
ylabel('Power');
xlabel('ReactionTime');


save('RT_fieldtrip','prespeech','postlisten','prelisten','prelisten1')






% cfg = [];
% cfg.parameter  = 'powspctrm';
% a = ft_appendfreq(cfg, NOCH_tf{:});
% 
% stat =[];
% R = [];
% for i=1:length(CONV_tf)
%     design = [];
%     n1 = size(CONV_tf{i}.trialinfo,1);    % n1 is the number of trials
%     design(1,1:n1)       = D(CONV_tf{i}.trialinfo(:,2),14); %here we insert our independent variable (behavioral data) in the cfg.design matrix, in this case accuracy per trial of 1 subject.
%     
%     cfg.design           = design;
%     cfg.ivar             = 1;
%     
%     stat{i,1} = ft_freqstatistics(cfg, CONV_tf{i});
%     R = [R;stat{i,1}.rho stat{i,1}.prob];
% end

