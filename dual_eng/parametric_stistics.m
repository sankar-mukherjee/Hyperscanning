%% parametric staticstics


save_cluster_data = [project.paths.projects_data_root '/dual_eng/mat/fieldtrip_clustering/'];

load([save_cluster_data '/EEG__32_10_mwv_mfc_convVSnoch_5ms.mat'],'data_conv','data_noCh','GA_tf_CONV','GA_tf_NOCH','GA_CONV','GA_NOCH');
load([save_cluster_data '/EEG__32_10_mwv_mfc_convVSnoch_listen_5ms.mat'],'data_conv','data_noCh','GA_tf_CONV','GA_tf_NOCH','GA_CONV','GA_NOCH');


% ERSP speech
%% speech optimal settings
time_window = [-1 0.5];
timeStep = 0.05;

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:40;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.toi          = time_window(1):timeStep:time_window(2);                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
a = 3./cfg.foi;
cfg.t_ftimwin  = [0.5 0.5 0.5 0.5 0.5 a(6:end)]; %3 cycles
cfg.keeptrials = 'yes';

%%
data = data_conv;

tf = [];
tf_d = [];
for i=1:length(data)
    tf{i} = ft_freqanalysis(cfg, data{i});
end

% log transform
cfg           = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'log10';
for i=1:length(data)
    tf{i} = ft_math(cfg, tf{i});
end

cfg              = [];
for i=1:length(data)
    tf_d{i} = ft_freqdescriptives(cfg, tf{i});
end
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'powspctrm';
GA_tf = ft_freqgrandaverage(cfg, tf_d{:});
GA_CONV = GA_tf;

data = data_noCh;

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:40;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.toi          = time_window(1):timeStep:time_window(2);                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
a = 3./cfg.foi;
cfg.t_ftimwin  = [0.5 0.5 0.5 0.5 0.5 a(6:end)]; %3 cycles
cfg.keeptrials = 'yes';

tf = [];
tf_d = [];
for i=1:length(data)
    tf{i} = ft_freqanalysis(cfg, data{i});
end
% log transform
cfg           = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'log10';
for i=1:length(data)
    tf{i} = ft_math(cfg, tf{i});
end
cfg              = [];
for i=1:length(data)
    tf_d{i} = ft_freqdescriptives(cfg, tf{i});
end
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'powspctrm';
GA_tf = ft_freqgrandaverage(cfg, tf_d{:});
GA_NOCH = GA_tf;

%% log transform
cfg           = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'log10';
GA_CONV    = ft_math(cfg, GA_CONV);
GA_NOCH    = ft_math(cfg, GA_NOCH);


cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'subtract';
TFR_diff      = ft_math(cfg, GA_CONV, GA_NOCH);
% 
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.xlim = [-0.7 -0.2]; % Specify the time range to plot
% cfg.ylim = [8 40]; % Specify the time range to plot
cfg.zlim = [-0.5 0.5]; % Specify the time range to plot

figure; ft_multiplotTFR(cfg, TFR_diff);
figure; ft_multiplotTFR(cfg, GA_CONV);
figure; ft_multiplotTFR(cfg, GA_NOCH);

cfg = [];
cfg.method    = 'distance';
neighbours       = ft_prepare_neighbours(cfg, data_conv{1});
        
cfg = [];
cfg.statistic = 'indepsamplesT';
subj = 16;
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;
cfg.design   = design;
% cfg.uvar     = 1;
cfg.ivar     = 2;

cfg.latency          =  [-0.7 -0.2];              % 'all';

cfg.method    = 'analytic';
cfg.correctm  = 'no';
stat1     = ft_freqstatistics(cfg, GA_CONV,GA_NOCH);

cfg.method    = 'analytic';
cfg.correctm  = 'bonferoni';
stat2     = ft_freqstatistics(cfg, GA_CONV,GA_NOCH);


cfg.method    = 'analytic';
cfg.correctm  = 'fdr';
stat3     = ft_freqstatistics(cfg, GA_CONV,GA_NOCH);

cfg.method            = 'montecarlo';
cfg.correctm          = 'cluster';
cfg.numrandomization  = 1000; % 1000 is recommended, but takes longer
cfg.neighbours        = neighbours;
stat4     = ft_freqstatistics(cfg, GA_CONV,GA_NOCH);


cfg               = [];
cfg.marker        = 'on';
cfg.layout        = 'biosemi64.lay';
cfg.parameter     = 'stat';  % plot the t-value 
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'saturation';
cfg.xlim = [-0.7 -0.2]; % Specify the time range to plot

figure; ft_multiplotTFR(cfg, stat1);
figure; ft_multiplotTFR(cfg, stat2);
figure; ft_multiplotTFR(cfg, stat3);
figure; ft_multiplotTFR(cfg, stat4);


% stat1 produces result
figure; ft_multiplotTFR(cfg, stat1);
save(stat1)

%% listen
time_window = [-0.5 1];
timeStep = 0.05;
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:40;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.toi          = time_window(1):timeStep:time_window(2);                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
a = 3./cfg.foi;
cfg.t_ftimwin  = [0.5 0.5 0.5 0.5 0.5 a(6:end)]; %7 cycles
cfg.keeptrials = 'yes';

%%
a = find(cellfun('isempty',data_conv));
b = find(cellfun('isempty',data_noCh));
a = [a; b];
a = unique(a);
data_conv = data_conv;
data_noCh = data_noCh;
data_conv(a) = [];
data_noCh(a) = [];

        
data = data_conv;

tf = [];
tf_d = [];
for i=1:length(data)
    tf{i} = ft_freqanalysis(cfg, data{i});
end
cfg              = [];
for i=1:length(data)
    tf_d{i} = ft_freqdescriptives(cfg, tf{i});
end
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'powspctrm';
GA_tf = ft_freqgrandaverage(cfg, tf_d{:});
GA_CONV = GA_tf;

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:40;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.toi          = time_window(1):timeStep:time_window(2);                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
a = 3./cfg.foi;
cfg.t_ftimwin  = [0.5 0.5 0.5 0.5 0.5 a(6:end)]; %7 cycles
cfg.keeptrials = 'yes';
data = data_noCh;

tf = [];
tf_d = [];
for i=1:length(data)
    tf{i} = ft_freqanalysis(cfg, data{i});
end
cfg              = [];
for i=1:length(data)
    tf_d{i} = ft_freqdescriptives(cfg, tf{i});
end
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'powspctrm';
GA_tf = ft_freqgrandaverage(cfg, tf_d{:});
GA_NOCH = GA_tf;

%% log transform
cfg           = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'log10';
GA_CONV    = ft_math(cfg, GA_CONV);
GA_NOCH    = ft_math(cfg, GA_NOCH);


% cfg = [];
% cfg.parameter = 'powspctrm';
% cfg.operation = '(x1-x2)/(x1+x2)';
% TFR_diff      = ft_math(cfg, GA_CONV, GA_NOCH);
% 
% cfg = [];
% cfg.marker  = 'on';
% cfg.layout  = 'biosemi64.lay';
% cfg.xlim = [-0.2 0.7]; % Specify the time range to plot
% figure; ft_multiplotTFR(cfg, TFR_diff);

cfg = [];
cfg.method    = 'distance';
neighbours       = ft_prepare_neighbours(cfg, data_conv{1});
        
cfg = [];
cfg.statistic = 'indepsamplesT';
subj = 15;
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;
cfg.design   = design;
% cfg.uvar     = 1;
cfg.ivar     = 2;
cfg.latency          =  [-0.2 0.7];              % 'all';


cfg.method    = 'analytic';
cfg.correctm  = 'no';
stat1     = ft_freqstatistics(cfg, GA_CONV,GA_NOCH);

cfg.method    = 'analytic';
cfg.correctm  = 'bonferoni';
stat2     = ft_freqstatistics(cfg, GA_CONV,GA_NOCH);


cfg.method    = 'analytic';
cfg.correctm  = 'fdr';
stat3     = ft_freqstatistics(cfg, GA_CONV,GA_NOCH);

cfg.method            = 'montecarlo';
cfg.correctm          = 'cluster';
cfg.numrandomization  = 1000; % 1000 is recommended, but takes longer
cfg.neighbours        = neighbours;
stat4     = ft_freqstatistics(cfg, GA_CONV,GA_NOCH);


cfg               = [];
cfg.marker        = 'on';
cfg.layout        = 'biosemi64.lay';
cfg.parameter     = 'stat';  % plot the t-value 
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'saturation';
cfg.xlim = [-0.2 0.7]; % Specify the time range to plot

figure; ft_multiplotTFR(cfg, stat1);
figure; ft_multiplotTFR(cfg, stat2);
figure; ft_multiplotTFR(cfg, stat3);
figure; ft_multiplotTFR(cfg, stat4);

% stat1 produces result
figure; ft_multiplotTFR(cfg, stat1);

%% ERP speech
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


cfg = [];
cfg.statistic = 'indepsamplesT';
subj = length(data_conv2);
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;
cfg.design   = design;
% cfg.uvar     = 1;
cfg.ivar     = 2;
% cfg.latency          =  [-0.2 0.7];              % 'all';

cfg.method    = 'analytic';
cfg.correctm  = 'no';
ERF_stat1     = ft_timelockstatistics(cfg, GA_conv_erp,GA_noch_erp);
cfg.method    = 'analytic';
cfg.correctm  = 'bonferoni';
ERF_stat2     = ft_timelockstatistics(cfg, GA_conv_erp,GA_noch_erp);
cfg.method    = 'analytic';
cfg.correctm  = 'fdr';
ERF_stat3     = ft_timelockstatistics(cfg, GA_conv_erp,GA_noch_erp);
cfg.method            = 'montecarlo';
cfg.correctm          = 'cluster';
cfg.numrandomization  = 1000; % 1000 is recommended, but that takes longer
cfg.neighbours        = neighbours;
ERF_stat4     = ft_timelockstatistics(cfg, GA_conv_erp,GA_noch_erp);


cfg = [];
cfg.layout        = 'biosemi64.lay';
cfg.maskparameter = 'mask';
cfg.maskstyle     = 'box';
% cfg.xlim = [-0.2 0.7];   % Specify the time range to plot

GA_conv_erp.mask = ERF_stat1.mask;  % copy the significance mask into the ERF
figure; ft_multiplotER(cfg, GA_conv_erp,GA_noch_erp);
title('no correction');
GA_conv_erp.mask = ERF_stat2.mask;  % copy the significance mask into the ERF
figure; ft_multiplotER(cfg, GA_conv_erp,GA_noch_erp);
title('bonferroni');
GA_conv_erp.mask = ERF_stat3.mask;  % copy the significance mask into the ERF
figure; ft_multiplotER(cfg, GA_conv_erp,GA_noch_erp);
title('fdr');
GA_conv_erp.mask = ERF_stat4.mask;  % copy the significance mask into the ERF
figure; ft_multiplotER(cfg, GA_conv_erp,GA_noch_erp);
title('cluster');

