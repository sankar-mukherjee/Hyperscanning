clear;clc;



%% prespeech all

load('prespeech_tf_all.mat')

cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
% cfg.channelname   = {'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5', 'T7'};
% cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, GA_tf);

title('PreSpeech power avg in all channels');
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power (%)');




%% prelisten all

load('prelisten_tf_all.mat')

cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
% cfg.channelname   = {'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5', 'T7'};
% cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, GA_tf);

title('PreSpeech power avg in all channels');
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power (%)');



%% 
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.showlabels       = 'yes';
cfg.xlim = [-0.2 -0.1]; % Specify the time range to plot
cfg.ylim = [21 23]; % Specify the time range to plot
% cfg.comment = 'no';
% ft_multiplotTFR(cfg, TFR_diff);
% cfg.ylim = [9 17];
%
cfg.zlim = [-1 1];
% ft_topoplotER(cfg, TFR_diff);
a = [-0.1:0.1:0];k=1;
X = TFR_diff;
for i=1:15
    X.powspctrm = TFR_diff.powspctrm(i,:,:,:);    
    figure;
    for j=1:1
        cfg.xlim=[a(j) a(j+1)];
        subplot(1,1,j)
        ft_topoplotER(cfg, X);k=k+1;
    end
end


%% topo plot timeline fix 

X = TFR_diff;
% X.powspctrm(:,21,[5:9],[11:13 19:21]) = 0;
X.powspctrm(:,[3 14 17],[11:12],[11:13]) = 0;

cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.showlabels       = 'yes';
cfg.xlim = [-0.1 0]; % Specify the time range to plot
cfg.ylim = [21 23];
cfg.zlim = [-0.25 0.25];
figure;ft_topoplotER(cfg, X);








%%


cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.showlabels       = 'yes';
cfg.xlim = [0 0.5]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot
% ft_multiplotTFR(cfg, TFR_diff);
% cfg.ylim = [9 17];
% 
% cfg.zlim = [-0.25 0.25];
% ft_topoplotER(cfg, TFR_diff);
X = TFR_diff;
for i=1:15    
    X.powspctrm = TFR_diff.powspctrm(i,:,:,:);
    figure; ft_multiplotTFR(cfg, X);
end

a = TFR_diff.powspctrm;
a = squeeze(a(:,21,[5:9],[11:13]));
a = squeeze(mean(a,2));

CONV_tf_1 = CONV_tf;
NOCH_tf_1 = NOCH_tf;

CONV_tf_1{7}.powspctrm = CONV_tf{7}.powspctrm([2:end],:,:,:);


cfg              = [];
for i=1:16
    CONV_tf_1{i} = ft_freqdescriptives(cfg, CONV_tf_1{i});
    NOCH_tf_1{i} = ft_freqdescriptives(cfg, NOCH_tf_1{i});
end

cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'powspctrm';
GA_tf_c = ft_freqgrandaverage(cfg, CONV_tf_1{:});
GA_tf_n = ft_freqgrandaverage(cfg, NOCH_tf_1{:});


cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_tf_c, GA_tf_n);
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5'};
% cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
















%%





left_channels = GA_tf.label(1:27);
right_channels = GA_tf.label([34:36 39:46 49:64]);

cfg           = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'log10';
GA_tf_log     = ft_math(cfg, GA_tf);



cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
% cfg.channelname   = {'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5', 'T7'};
% cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot

figure; ft_multiplotTFR(cfg, GA_tf);
figure; ft_singleplotTFR(cfg, GA_tf);
figure; ft_topoplotTFR(cfg, GA_tf);

figure; ft_multiplotTFR(cfg, GA_tf_log);
figure; ft_singleplotTFR(cfg, GA_tf_log);

title('PreSpeech power avg in all channels');
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power (%)');

cfg = [];
% cfg.baseline     = [-0.5 -0.1];
cfg.channel      = right_channels;

% cfg.baselinetype = 'relchange';  
% cfg.maskstyle    = 'saturation';	
% cfg.zlim         = [-3e-27 3e-27];	
cfg.layout  = 'biosemi64.lay';
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot
figure;ft_singleplotTFR(cfg, GA_tf);



cfg=[];
cfg.latency     = [-0.5 0];
cfg.channel = left_channels;
left = ft_selectdata(cfg,GA_tf);
cfg.channel = right_channels;
right = ft_selectdata(cfg,GA_tf);



TFR_diff = left;
TFR_diff.powspctrm = (left.powspctrm - right.powspctrm)./right.powspctrm;


cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, right);
figure; ft_singleplotTFR(cfg, TFR_diff);


























