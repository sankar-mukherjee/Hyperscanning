






cfg              = [];tf_d=[];
cfg.parameter = 'powspctrm';
for i=1:length(tf_speech)
    tf_d{i} = ft_freqdescriptives(cfg, tf_speech{i});
end
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'powspctrm';
GA= ft_freqgrandaverage(cfg, tf_d{:});


cfg              = [];tf_d=[];
cfg.parameter = 'powspctrm';
for i=1:length(tf_listen)
    tf_d{i} = ft_freqdescriptives(cfg, tf_listen{i});
end
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'powspctrm';
GA_l= ft_freqgrandaverage(cfg, tf_d{:});


cfg              = [];tf_d=[];
cfg.parameter = 'powspctrm';
for i=1:length(tf_Prelisten)
    tf_d{i} = ft_freqdescriptives(cfg, tf_Prelisten{i});
end
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'powspctrm';
GA_pl= ft_freqgrandaverage(cfg, tf_d{:});

%% log transform
cfg           = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'log10';
GA    = ft_math(cfg, GA);

cfg = [];
% cfg.channel            = {'CP3','CP5','P3','P5','CP4','CP6','P4','P6','C3','C4','C5'};
cfg.layout  = 'biosemi64.lay';
cfg.ylim = [8 25];
cfg.xlim = [-0.5:0.1:0];
% cfg.zlim    = [-0.5 0.5];
figure; ft_topoplotTFR(cfg, GA);
figure; ft_topoplotTFR(cfg, GA_pl);

cfg.xlim = [0:0.1:0.5];
figure; ft_topoplotTFR(cfg, GA_l);












time_window = [-0.5 0];
timeStep = 0.005;

%% cheking for cosistence subject
a = find(cellfun('isempty',data_conv));
b = find(cellfun('isempty',data_noCh));
a = [a; b];
a = unique(a);
data_conv2 = data_conv;
data_noCh2 = data_noCh;
data_conv2(a) = [];
data_noCh2(a) = [];

data_noCh2 = data_noCh2(1:length(data_conv2));
Nsub = length(data_conv2);

% trial no in both cond
a=[];b=[];
for i=1:Nsub
    a = [a size(data_conv2{i,1}.trial,2)];
    b = [b size(data_noCh2{i,1}.trial,2)];
end
sum(a)
sum(b)

cfg.method    = 'distance';
neighbours       = ft_prepare_neighbours(cfg, data_conv2{1});

%% rereference
cfg = [];
cfg.reref       = 'yes';
cfg.channel = {'all'};
cfg.refchannel = {'all'};
for i = 1: length(data_conv2)
    data_conv2{i}        = ft_preprocessing(cfg,data_conv2{i});
    data_noCh2{i}        = ft_preprocessing(cfg,data_noCh2{i});
end

[CONV_tf,~,GA_CONV] = compute_ERSP(data_conv2,time_window,timeStep,0);
[NOCH_tf,~,GA_NOCH] = compute_ERSP(data_noCh2,time_window,timeStep,0);
GA_CONV = GA_tf_CONV;
GA_NOCH = GA_tf_NOCH;

%% log transform
cfg           = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'log10';
GA_CONV_log    = ft_math(cfg, GA_CONV);
GA_NOCH_log    = ft_math(cfg, GA_NOCH);



cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'subtract';
TFR_diff      = ft_math(cfg, GA_CONV, GA_NOCH);

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'subtract';
TFR_diff_log     = ft_math(cfg, GA_CONV_log, GA_NOCH_log);


%
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F5','F7','FT7','FC5','F3','C3','C5'};
cfg.zlim = [-0.30 0.30]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);

mean_pwr = squeeze(mean(TFR_diff.powspctrm,1));
datsmooth = zeros(4,40,length(TFR_diff.time));
for i=6:9
    a = squeeze(mean_pwr(i,:,:));
%     datsmooth(i-5,:,:) = ft_preproc_smooth(a, [0.33 0.67 1 0.67 0.33]);
    datsmooth(i-5,:,:) = a;

end

mean_pwr = squeeze(mean(datsmooth,1));
figure;
imagesc(TFR_diff.time,TFR_diff.freq,flipud(mean_pwr));
caxis([-0.2 0.2]);
set(gca,'YtickLabel',[40:-5:5]);


a= smooth2a(mean_pwr,5,5);
figure;
imagesc(TFR_diff.time,TFR_diff.freq,flipud(a));
caxis([-0.12 0.12]);
set(gca,'YtickLabel',[35:-5:0]);


B = imgaussfilt(A)






figure; ft_multiplotTFR(cfg, TFR_diff);

% cfg.zlim = [-2 2]; % Specify the time range to plot
cfg.ylim = [8 30]; % Specify the time range to plot
figure; ft_multiplotTFR(cfg, GA_CONV);
figure; ft_multiplotTFR(cfg, GA_NOCH);




%%





cfg              = [];
cfg.parameter = 'powspctrm';
for i=1:length(CONV_tf)
    tf_d{i} = ft_freqdescriptives(cfg, CONV_tf{i});
end
clear CONV_tf;
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'powspctrm';
GA_CONV= ft_freqgrandaverage(cfg, tf_d{:});




cfg              = [];
cfg.parameter = 'powspctrm';
for i=1:length(NOCH_tf)
    tf_d{i} = ft_freqdescriptives(cfg, NOCH_tf{i});
end
clear NOCH_tf;
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'powspctrm';
GA_NOCH= ft_freqgrandaverage(cfg, tf_d{:});


















% cfg.zlim = [-2 2]; % Specify the time range to plot
cfg.ylim = [8 30]; % Specify the time range to plot
figure; ft_multiplotTFR(cfg, GA_CONV);
figure; ft_multiplotTFR(cfg, GA_NOCH);

time_w = [1:101];
freq = [12:14];
C = GA_CONV.powspctrm(:,6:9,freq,time_w);
C_mean = squeeze(nanmean(squeeze(mean(mean(C,2),3)),1));
C_std = squeeze(nanstd(squeeze(mean(mean(C,2),3)),1));

N = GA_NOCH.powspctrm(:,6:9,freq,time_w);
N_mean = squeeze(nanmean(squeeze(mean(mean(N,2),3)),1));
N_std = squeeze(nanstd(squeeze(mean(mean(N,2),3)),1));

figure;plot(GA_CONV.time(time_w),C_mean);hold on;plot(GA_CONV.time(time_w),N_mean,'r');
shadedErrorBar(GA_CONV.time(time_w),C_mean,C_std,'b');hold on;
shadedErrorBar(GA_NOCH.time(time_w),N_mean,N_std,'r');

a = (C_mean - N_mean)./N_mean;
plot(GA_CONV.time(time_w),a);


a=squeeze(within_subj_cluster{14,3}.cirange);

imagesc(within_subj_cluster{13,3}.time,within_subj_cluster{13,3}.label,a)


%% std erp

%rereference
cfg = [];
cfg.reref       = 'yes';
cfg.channel = {'all'};
cfg.refchannel = {'all'};
for i = 1: length(data_conv)
    data_conv2{i}        = ft_preprocessing(cfg,data_conv{i});
    data_noCh2{i}        = ft_preprocessing(cfg,data_noCh{i});
end
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'avg';
cfg.keeptrials  = 'yes';

for i=1:length(data_conv2)
    avg_erp{i} = ft_timelockanalysis(cfg, data_conv2{i});
end
GA_conv_erp         = ft_timelockgrandaverage(cfg,avg_erp{:});
for i=1:length(data_conv2)
    avg_erp{i} = ft_timelockanalysis(cfg, data_noCh2{i});
end
GA_noch_erp         = ft_timelockgrandaverage(cfg,avg_erp{:});


cfg        = [];
cfg.layout = 'biosemi64.lay';
figure; ft_multiplotER(cfg, GA_conv_erp, GA_noch_erp);























%% spec

time_window = [-0.7 -0.2];
timeStep = 0.05;
cfg              = [];
cfg.output       = 'fourier';
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foilim          = [1 40];                       
cfg.keeptrials = 'yes';
cfg.toi          = time_window(1):timeStep:time_window(2);                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)

%%
data = data_conv;

tf = [];
tf_d = [];
for i=1:length(data)
    tf{i} = ft_freqanalysis(cfg, data{i});
end
% % % log transform
cfg           = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'log10';
for i=1:length(data)
    tf{i} = ft_math(cfg, tf{i});
end
cfg              = [];
cfg.parameter = 'fourierspctrm';
for i=1:length(data)
    tf_d{i} = ft_freqdescriptives(cfg, tf{i});
end

cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'fourierspctrm';
GA_tf = ft_freqgrandaverage(cfg, tf_d{:});
%% fft power spec  ================================================================

cfg.channel = {'F5','F7','FT7','FC5'};
cfg.time          =  [-0.7 -0.2];              % 'all';

figure; ft_singleplotER(cfg,tf_d{1});
figure; ft_singleplotER(cfg,GA_tf);

figure;ft_singleplotER(cfg,tf_d{1},tf_d{2},tf_d{3},tf_d{4},tf_d{5},tf_d{6},tf_d{7},tf_d{8},tf_d{9},tf_d{10},tf_d{11},tf_d{12},tf_d{13},tf_d{14},tf_d{15},tf_d{16});











%% old





%% speech plot
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\prespeech\importent_nobaseline_1sec_nolog_sepcond_oldsettings_5ms_-500-0\speech_tfr.mat',...
    'TFR_diff','TFR_diff_log','CONV_tf','NOCH_tf','GA_CONV_log','GA_NOCH_log');
% 
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F5','F7','FT7','FC5'};
% cfg.zlim = [-0.16 0.16]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange','mean(FT7,FC5,F5,F7)'});
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Log Power Difference');
caxis([-0.25 0.25])


% power
time_w = [1:101];
freq = [12:14];

C = GA_CONV_log.powspctrm(:,6:9,freq,time_w);
C_mean = squeeze(nanmean(squeeze(mean(mean(C,1),2)),1));
C_std = squeeze(nanstd(squeeze(mean(mean(C,1),2)),1));
N = GA_NOCH_log.powspctrm(:,6:9,freq,time_w);
N_mean = squeeze(nanmean(squeeze(mean(mean(N,1),2)),1));
N_std = squeeze(nanstd(squeeze(mean(mean(N,1),2)),1));

% figure;plot(GA_CONV.time(time_w),C_mean);hold on;plot(GA_CONV.time(time_w),N_mean,'r');
trNo =[];
for i = 1:length(CONV_tf)
    trNo = [trNo ;size(CONV_tf{i}.trialinfo,1) size(NOCH_tf{i}.trialinfo,1)];
end
trNo = sum(trNo);

th=0.005;

[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
% % 



[C_mean,CI] = confidence_interval(GA_CONV_log,freq,time_w,cfg.channelname,th,0);
figure;
shadedErrorBar(GA_NOCH_log.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(GA_NOCH_log,freq,time_w,cfg.channelname,th,0);
shadedErrorBar(GA_NOCH_log.time(time_w),C_mean,CI,'r',0.25);

% th=0.95;
% 
% [conv_mean,noch_mean,CI] = confidence_interval2(CONV_tf,NOCH_tf,freq,time_w,cfg.channelname,th,1);
% figure;
% shadedErrorBar(CONV_tf{1}.time(time_w),conv_mean,CI,'-b',0.5);hold on;
% shadedErrorBar(CONV_tf{1}.time(time_w),noch_mean,CI,'r',0.25);






% 
% figure;
% plot(get(gca,'xlim'), [0 0],'w');hold on;
% shadedErrorBar(GA_CONV.time(time_w),C_mean,C_std,'--b',0.5);
% shadedErrorBar(GA_NOCH.time(time_w),N_mean,N_std,'r',0.25);
% title('FT7,FC5,F5,F7 12-14 Hz Power');
% ylabel('Power (log_{10}(\muV^{2}))');
% xlabel('Time (s)');
% h1 = area(NaN,NaN,'Facecolor','b');
% h2 = area(NaN,NaN,'Facecolor','r');
% alpha(h1,0.5);
% alpha(h2,0.25);
% legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
% h1 = area([-0.26172  -0.19531],[-0.04 -0.04],-0.05);
% set(h1,'Facecolor','k')
% set(gca,'xlim',[-0.5 0]);





%% listen plot
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\importent_nobaseline_5ms_-500-0_0-500_oldsettings_listen_5sec_sepcond\listen_0-500.mat','TFR_diff_log','CONV_tf','NOCH_tf');
%% cluster 1-2 hz
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F1','FC1','Fz','FCz'};
% cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [0 0.5]; % Specify the time range to plot
% cfg.ylim = [5 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange', cell2mat(cfg.channelname) });
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Log Power Difference');

% power
channel = {'F1','FC1','Fz','FCz'};
time_w = [1:101];
freq = [1:2];

ch_idx = find(ismember(TFR_diff.label,channel)); 

C = GA_CONV.powspctrm(:,ch_idx,freq,time_w);
C_mean = squeeze(nanmean(squeeze(mean(mean(C,1),2)),1));
C_std = squeeze(nanstd(squeeze(mean(mean(C,1),2)),1));
N = GA_NOCH.powspctrm(:,ch_idx,freq,time_w);
N_mean = squeeze(nanmean(squeeze(mean(mean(N,1),2)),1));
N_std = squeeze(nanstd(squeeze(mean(mean(N,1),2)),1));

figure;plot(GA_CONV.time(time_w),C_mean);hold on;plot(GA_CONV.time(time_w),N_mean,'r');

figure;
plot(get(gca,'xlim'), [0 0],'w');hold on;
shadedErrorBar(GA_CONV.time(time_w),C_mean,C_std,'--b',0.5);
shadedErrorBar(GA_NOCH.time(time_w),N_mean,N_std,'r',0.25);
title([cell2mat(channel) ' - ' num2str(freq) ' Hz Power']);
ylabel('Power (log_{10}(\muV^{2}))');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([0.12891     0.17188],[0.71 0.71],0.7);
set(h1,'Facecolor','k')
set(gca,'xlim',[0 0.5]);
set(gca,'ylim',[0.7 1.5]);


%% cluster 27-28 hz
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F5','F7','FC5'};
cfg.zlim = [-0.16 0.16]; % Specify the time range to plot
cfg.xlim = [0 0.5]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff_log);
title({'Convergence vs NoChange', cell2mat(cfg.channelname) });
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Log Power Difference');

% power
time_w = [1:101];
freq = [27:28];

% ch_idx = find(ismember(TFR_diff.label,channel)); 

% C = GA_CONV.powspctrm(:,ch_idx,freq,time_w);
% C_mean = squeeze(nanmean(squeeze(mean(mean(C,1),2)),1));
% C_std = squeeze(nanstd(squeeze(mean(mean(C,1),2)),1));
% N = GA_NOCH.powspctrm(:,ch_idx,freq,time_w);
% N_mean = squeeze(nanmean(squeeze(mean(mean(N,1),2)),1));
% N_std = squeeze(nanstd(squeeze(mean(mean(N,1),2)),1));

% figure;plot(GA_CONV.time(time_w),C_mean);hold on;plot(GA_CONV.time(time_w),N_mean,'r');
th=0.005;

[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
% figure;
% plot(get(gca,'xlim'), [0 0],'w');hold on;
% shadedErrorBar(GA_CONV.time(time_w),C_mean,C_std,'--b',0.5);
% shadedErrorBar(GA_NOCH.time(time_w),N_mean,N_std,'r',0.25);
% title([cell2mat(channel) ' - ' num2str(freq) ' Hz Power']);
% ylabel('Power (log_{10}(\muV^{2}))');
% xlabel('Time (s)');
% h1 = area(NaN,NaN,'Facecolor','b');
% h2 = area(NaN,NaN,'Facecolor','r');
% alpha(h1,0.5);
% alpha(h2,0.25);
% legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
% h1 = area([0.10938     0.14453],[-0.24 -0.24],-0.25);
% set(h1,'Facecolor','k')
% set(gca,'xlim',[-0.1 0.5]);
% set(gca,'ylim',[-0.25 0]);


%% cluster 34 hz
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'AF8','F6','F8'};
cfg.zlim = [-0.2 0.2]; % Specify the time range to plot
cfg.xlim = [0 0.5]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff_log);
title({'Convergence vs NoChange', cell2mat(cfg.channelname) });
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Log Power Difference');

% power
channel = cfg.channelname; 
time_w = [1:101];
freq = [33:35];

ch_idx = find(ismember(TFR_diff.label,channel)); 

C = GA_CONV.powspctrm(:,ch_idx,freq,time_w);
C_mean = squeeze(nanmean(squeeze(mean(mean(C,1),2)),1));
C_std = squeeze(nanstd(squeeze(mean(mean(C,1),2)),1));
N = GA_NOCH.powspctrm(:,ch_idx,freq,time_w);
N_mean = squeeze(nanmean(squeeze(mean(mean(N,1),2)),1));
N_std = squeeze(nanstd(squeeze(mean(mean(N,1),2)),1));

% figure;plot(GA_CONV.time(time_w),C_mean);hold on;plot(GA_CONV.time(time_w),N_mean,'r');

figure;
plot(get(gca,'xlim'), [0 0],'w');hold on;
shadedErrorBar(GA_CONV.time(time_w),C_mean,C_std,'--b',0.5);
shadedErrorBar(GA_NOCH.time(time_w),N_mean,N_std,'r',0.25);
title([cell2mat(channel) ' - ' num2str(freq) ' Hz Power']);
ylabel('Power (log_{10}(\muV^{2}))');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([0.070313     0.12109],[-0.39 -0.39],-0.4);
set(h1,'Facecolor','k')
set(gca,'xlim',[0 0.5]);
set(gca,'ylim',[-0.4 0]);



%% -0.7 to 0.7 eeglab epoch eeg data

% load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\-1to1EEG_config\1secRT\tfr_listen.mat');
% load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\-0.7to0.7EEG_config\1RT\tfr_listen.mat');
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\-1to1EEG_config\1secRT\listen_-500-0.mat','TFR_diff_log','CONV_tf','NOCH_tf','GA_CONV','GA_NOCH');


%% cluster 21-23 hz
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'C4','C6','CP6','CP4'};
cfg.zlim = [-0.16 0.16]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff_log);
title({'Convergence vs NoChange', cell2mat(cfg.channelname) });
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Log Power Difference');
caxis([-0.16 0.16])
% power
channel = cfg.channelname; 
time_w = [1:101];
freq = [21:23];

ch_idx = find(ismember(TFR_diff_log.label,channel)); 

C = GA_CONV_log.powspctrm(:,ch_idx,freq,time_w);
C_mean = squeeze(nanmean(squeeze(mean(mean(C,1),2)),1));
C_std = squeeze(nanstd(squeeze(mean(mean(C,1),2)),1));
N = GA_NOCH_log.powspctrm(:,ch_idx,freq,time_w);
N_mean = squeeze(nanmean(squeeze(mean(mean(N,1),2)),1));
N_std = squeeze(nanstd(squeeze(mean(mean(N,1),2)),1));

figure;plot(GA_CONV_log.time(time_w),C_mean);hold on;plot(GA_CONV_log.time(time_w),N_mean,'r');
th=0.005;

[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
%
[C_mean,CI] = confidence_interval(GA_CONV_log,freq,time_w,cfg.channelname,th,0);
figure;
shadedErrorBar(GA_CONV_log.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(GA_NOCH_log,freq,time_w,cfg.channelname,th,0);
shadedErrorBar(GA_CONV_log.time(time_w),C_mean,CI,'r',0.25);


figure;
plot(get(gca,'xlim'), [0 0],'w');hold on;
shadedErrorBar(GA_CONV.time(time_w),C_mean,C_std,'--b',0.5);
shadedErrorBar(GA_NOCH.time(time_w),N_mean,N_std,'r',0.25);
title([cell2mat(channel) ' - ' num2str(freq) ' Hz Power']);
ylabel('Power (log_{10}(\muV^{2}))');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([-0.26563     -0.21094],[-0.39 -0.39],-0.4);
set(h1,'Facecolor','k')
set(gca,'xlim',[-0.5 0]);
set(gca,'ylim',[-0.4 -0.1]);


%% cluster 29-30 hz
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'POz','P2','P4','PO4'};
cfg.zlim = [-0.16 0.16]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange', cell2mat(cfg.channelname) });
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Log Power Difference');

% power
channel = cfg.channelname; 
time_w = [1:201];
freq = [29:30];

ch_idx = find(ismember(TFR_diff.label,channel)); 

C = GA_CONV.powspctrm(:,ch_idx,freq,time_w);
C_mean = squeeze(nanmean(squeeze(mean(mean(C,1),2)),1));
C_std = squeeze(nanstd(squeeze(mean(mean(C,1),2)),1));
N = GA_NOCH.powspctrm(:,ch_idx,freq,time_w);
N_mean = squeeze(nanmean(squeeze(mean(mean(N,1),2)),1));
N_std = squeeze(nanstd(squeeze(mean(mean(N,1),2)),1));

figure;plot(GA_CONV.time(time_w),C_mean);hold on;plot(GA_CONV.time(time_w),N_mean,'r');

figure;
plot(get(gca,'xlim'), [0 0],'w');hold on;
shadedErrorBar(GA_CONV.time(time_w),C_mean,C_std,'--b',0.5);
shadedErrorBar(GA_NOCH.time(time_w),N_mean,N_std,'r',0.25);
title([cell2mat(channel) ' - ' num2str(freq) ' Hz Power']);
ylabel('Power (log_{10}(\muV^{2}))');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([-0.32     -0.28],[-0.39 -0.39],-0.4);
set(h1,'Facecolor','k')
set(gca,'xlim',[-0.5 0]);
set(gca,'ylim',[-0.4 -0.1]);







