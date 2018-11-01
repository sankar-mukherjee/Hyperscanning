load('speech_data.mat')

cfg = [];
cfg.toilim = [-0.26 -0.19];

for i=1:length(data_noCh)
    data_conv{i,1} = ft_redefinetrial(cfg, data_conv{i,1});
    data_noCh{i,1} = ft_redefinetrial(cfg, data_noCh{i,1});
end

%%
dataC = ft_appenddata([], data_conv{:});
dataN = ft_appenddata([], data_noCh{:});



% Freqanalysis for beamformer
cfg = [];
cfg.method       = 'mtmfft';
cfg.output       = 'powandcsd';
cfg.taper ='hanning';
cfg.foi          = [12 14];
% cfg.tapsmofrq    = 2;
% cfg.pad        = 1;
% cfg.padtype     = 'zero';

conv_tf = ft_freqanalysis(cfg,dataC);
noch_tf = ft_freqanalysis(cfg,dataN);

%% source analysis
load('headmodel_biosemi64_grid');
cfg              = []; 
cfg.method       = 'dics';
cfg.frequency    = 13;  
cfg.grid         = grid; 
cfg.headmodel          = vol;
cfg.senstype     = 'EEG'; % Remember this must be specified as either EEG, or MEG
cfg.dics.keepfilter   = 'yes';
cfg.dics.realfilter   = 'yes';
cfg.dics.lambda       = '100%';

source_conv= ft_sourceanalysis(cfg, conv_tf);
source_noch= ft_sourceanalysis(cfg, noch_tf);


% diffrenece
source_diff = source_conv;
source_diff.pow  = (source_conv.avg.pow - source_noch.avg.pow)./source_noch.avg.pow;

load('standard_mri.mat')

cfg            = [];
cfg.parameter = 'pow';
source_diff_rescale  = ft_sourceinterpolate(cfg, source_diff, mri);
%% plot
cfg = [];
cfg.method         = 'surface';
cfg.funparameter   = 'pow';
cfg.maskparameter  = cfg.funparameter;
% cfg.funcolorlim    = [0 0.5];
cfg.funcolormap    = 'jet';
cfg.opacitylim     = [0.0 1.2]; 
cfg.opacitymap     = 'rampup';  
cfg.projmethod     = 'nearest'; 
cfg.surffile       = 'surface_white_both.mat';
cfg.surfdownsample = 10; 
ft_sourceplot(cfg, source_diff_rescale);












