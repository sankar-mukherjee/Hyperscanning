function [tf,tf_d,GA_tf] = compute_ERSP(data,time_window,timeStep,logTransform)
%%  ERSP

% % old settings
% % time_window = [-0.7 -0.2];
% % timeStep = 0.005;
% % calculate the grand average for each condition
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'tfr';
% cfg.taper        = 'hanning';
% cfg.foi          = 1.6:1.6:40;                         % analysis 2 to 30 Hz in steps of 2 Hz
% cfg.t_ftimwin    = ones(size(cfg.foi)).*0.6;   % length of time window = 0.5 sec
% cfg.t_ftimwin    =  3./cfg.foi;   % length of time window = 0.5 sec
cfg.toi          = time_window(1):timeStep:time_window(2);                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
cfg.keeptrials = 'yes';
cfg.foilim     = [1 40];

%
% % % check
% % figure
% % plot(cfg.foi, cfg.t_ftimwin)
% % xlabel('frequency (Hz)');
% % ylabel('window length (s)')
%

%% speech optimal settings
% % time_window = [-1 0.5];
% % timeStep = 0.05;
% cfg              = [];
% cfg.output       = 'pow';
% cfg.channel      = 'all';
% cfg.method       = 'mtmconvol';
% cfg.taper        = 'hanning';
% cfg.foi          = 1:40;                         % analysis 2 to 30 Hz in steps of 2 Hz
% cfg.toi          = time_window(1):timeStep:time_window(2);                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
% a = 3./cfg.foi;
% cfg.t_ftimwin  = [0.5 0.5 0.5 0.5 0.5 a(6:end)]; %3 cycles
% cfg.keeptrials = 'yes';

%%
tf = [];
tf_d = [];

for i=1:length(data)
    tf{i} = ft_freqanalysis(cfg, data{i});
end

% % % log transform
if(logTransform)
    cfg           = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = 'log10';
    for i=1:length(data)
        tf{i} = ft_math(cfg, tf{i});
    end
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


end