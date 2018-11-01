%% reaction time confound with the fieldtrip result 

load('D:\projects\vault\dual_eeg_eng\data\dual_eng\mat\convergence\convergence_32_10_mwv_mfc.mat')
load('D:\projects\vault\dual_eeg_eng\data\dual_eng\mat\processed_data_word_level.mat', 'D')

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
cfg=[];
cfg.latency = [-0.5 0];
for f=1:16
    CONV_tf{f} = ft_selectdata(cfg,CONV_tf{f});
    NOCH_tf{f} = ft_selectdata(cfg,NOCH_tf{f});
    
end



channel   = {'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5', 'T7'};
time_w = [-0.4  -0.2];
freq = [5 9];
prespeech = compute_reactiome_realtion(D,CONV_tf,NOCH_tf,conv_idx,noCh_idx,channel,freq,time_w);
figure;
scatter(prespeech.C_RT,prespeech.C_mean,'.b');hold on;
scatter(prespeech.N_RT,prespeech.N_mean,'.r');
title('PreSpeech');
ylabel('Power (\muV^{2})');
xlabel('ReactionTime (s)');

[p,h] = corr(prespeech.C_RT,prespeech.C_mean)

%% postlisten plot

cfg=[];
cfg.latency = [0 0.5];
for f=1:15
    CONV_tf{f} = ft_selectdata(cfg,CONV_tf{f});
    NOCH_tf{f} = ft_selectdata(cfg,NOCH_tf{f});
    
end

channel   = {'F5' 'F7' 'FC5'};
time_w = [0.05     0.10];
freq = [13 15];
postlisten = compute_reactiome_realtion(D,CONV_tf,NOCH_tf,conv_idx,noCh_idx,channel,freq,time_w);
figure;
scatter(postlisten.C_RT,postlisten.C_mean,'.b');hold on;
scatter(postlisten.N_RT,postlisten.N_mean,'.r');
title('postlisten');
ylabel('Power');
xlabel('ReactionTime');


%% prelisten
% 21 -24 cluster


% cluster 28-30 hz

channel   = {'C4','C6','CP6','CP4'};
time_w = [-0.29     -0.19];
freq = [11 12];
prelisten1 = compute_reactiome_realtion(D,CONV_tf,NOCH_tf,conv_idx,noCh_idx,channel,freq,time_w);
figure;
scatter(prelisten1.C_RT,log(prelisten1.C_mean),'.b');hold on;
scatter(prelisten1.N_RT,log(prelisten1.N_mean),'.r');
title('prelisten1');
ylabel('Power');
xlabel('ReactionTime');






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

