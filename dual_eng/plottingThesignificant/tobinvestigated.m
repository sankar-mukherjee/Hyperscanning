%% speech plot
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\prespeech\importent_nobaseline_1sec_nolog_sepcond_oldsettings_5ms_-500-0\speech_tfr.mat',...
'CONV_tf','NOCH_tf','GA_CONV','GA_NOCH');

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_CONV, GA_NOCH);


cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F5','F7','FT7','FC5'};
cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange','mean(FT7,FC5,F5,F7)'});
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power Difference (%)');



% power
time_w = [1:101];
freq = [12:14];
th=0.005;
[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
title({'FT7,FC5,F5,F7 (12-14 Hz)'});
ylabel('Power (\muV^{2})');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
ylabel(colorbar,'Power Change (%)');
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([-0.26172  -0.19531],[1.01 1.01],1);
set(h1,'Facecolor',[0.5 0.5 0.5]);alpha(h1,0.5);
set(gca,'xlim',[-0.5 0]);
set(gca,'ylim',[1 3]);

%% listen plot
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\postlisten\importent_nobaseline_5ms_-500-0_0-500_oldsettings_listen_5sec_sepcond\listen_0-500.mat',...
'CONV_tf','NOCH_tf','GA_CONV','GA_NOCH');
cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_CONV, GA_NOCH);

%% cluster 27-28 hz
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F5','F7','FC5'};
cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [0 0.5]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot

figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange', ['mean(' cell2mat(cfg.channelname) ')' ]});
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power Change (%)');



time_w = [1:101];
freq = [27:28];
th=0.005;
[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
title([cell2mat(channel) ' - ' num2str(freq) ' Hz Power']);
ylabel('Power (\muV^{2})');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([0.10     0.14453],[0.66 0.66],0.65);
set(h1,'Facecolor',[0.5 0.5 0.5]);alpha(h1,0.5);
set(gca,'xlim',[0 0.5]);
set(gca,'ylim',[0.65 1.2]);
title({'FC5,F5,F7 (27-28 Hz)'});

%% prelisten
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\-1to1EEG_config\1secRT\listen_-500-0.mat',...
'CONV_tf','NOCH_tf','GA_CONV','GA_NOCH');

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_CONV, GA_NOCH);

%% 21 -24 cluster

cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'C4','C6','CP6','CP4'};
cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange', ['mean(' cell2mat(cfg.channelname) ')' ]});
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power Change (%)');



% power
channel = cfg.channelname;
time_w = [1:101];
freq = [21:24];
th=0.005;
[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
title(['C4,C6,CP6,CP4 (21 -24) Hz']);
ylabel('Power (\muV^{2})');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([-0.26563     -0.21094],[0.51 0.51],0.5);
set(h1,'Facecolor',[0.5 0.5 0.5]);alpha(h1,0.5);
set(gca,'xlim',[-0.5 0]);
set(gca,'ylim',[0.5 1]);



%% cluster 28-30 hz
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'POz','P2','P4','PO4'};
cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange', ['mean(' cell2mat(cfg.channelname) ')' ]});
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power Change (%)');

% power
channel = cfg.channelname; 
time_w = [1:101];
freq = [28:30];

th=0.005;
[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
title(['POz,P2,P4,PO4 (28-30) Hz']);
ylabel('Power (\muV^{2})');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([-0.32     -0.28],[0.325 0.325],0.32);
set(h1,'Facecolor',[0.5 0.5 0.5]);alpha(h1,0.5);
set(gca,'xlim',[-0.5 0]);
set(gca,'ylim',[0.32 0.52]);











































