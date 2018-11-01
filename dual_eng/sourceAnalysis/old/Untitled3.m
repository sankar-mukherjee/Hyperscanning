

load('speech_data.mat')

cfg = [];
cfg.toilim = [-0.26 -0.19];

for i=1:length(data_noCh)
    data_conv{i,1} = ft_redefinetrial(cfg, data_conv{i,1});
    data_noCh{i,1} = ft_redefinetrial(cfg, data_noCh{i,1});
end
%%
dataAll =  ft_appenddata([], data_conv{:}, data_noCh{:});
dataC = ft_appenddata([], data_conv{:});
dataN = ft_appenddata([], data_noCh{:});

clear data_conv data_noCh ;




cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:40;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.t_ftimwin    = ones(size(cfg.foi)).*0.3;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.005:0;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
cfg.keeptrials = 'yes';

conv_tf = ft_freqanalysis(cfg,dataC);
noch_tf = ft_freqanalysis(cfg,dataN);

cfg              = [];
tf_d = ft_freqdescriptives(cfg, conv_tf);
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'powspctrm';
cfg.keepindividual = 'yes';
GA_conv = ft_freqgrandaverage(cfg, tf_d);
cfg              = [];
tf_d = ft_freqdescriptives(cfg, noch_tf);
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.parameter = 'powspctrm';
cfg.keepindividual = 'yes';
GA_noch = ft_freqgrandaverage(cfg, tf_d);

clear noch_tf conv_tf

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_conv, GA_noch);

time = [-0.5:0.1:0];location={'F5','F7','FT7','FC5'};

figure;fieldtrip_topoPlot(TFR_diff,[12 14],time,location);








































%% compute sensor level Fourier spectra, to be used for cross-spectral density computation.
cfg            = [];
cfg.method     = 'mtmfft';
cfg.output     = 'fourier';
cfg.keeptrials = 'yes';
cfg.taper ='hanning';
% cfg.tapsmofrq  = 1;
cfg.foi        = [12 14];
freq           = ft_freqanalysis(cfg, dataAll);
conv_tf = ft_freqanalysis(cfg,dataC);
noch_tf = ft_freqanalysis(cfg,dataN);

load('headmodel_biosemi64_grid');

% compute the beamformer filters based on the entire data
cfg                   = [];
cfg.frequency         = freq.freq;
cfg.method            = 'pcc';
cfg.grid              = grid;
cfg.headmodel         = vol;
cfg.keeptrials        = 'yes';
cfg.pcc.lambda        = '10%';
cfg.pcc.projectnoise  = 'yes';
cfg.pcc.keepfilter    = 'yes';
cfg.pcc.fixedori      = 'yes';
source = ft_sourceanalysis(cfg, freq);

% use the precomputed filters 
cfg                   = [];
cfg.frequency         = freq.freq;
cfg.method            = 'pcc';
cfg.grid              = grid;
cfg.grid.filter       = source.avg.filter;
cfg.headmodel         = vol;
cfg.keeptrials        = 'yes';
cfg.pcc.lambda        = '10%';
cfg.pcc.projectnoise  = 'yes';
source_conv  = ft_sourcedescriptives([], ft_sourceanalysis(cfg, conv_tf));
source_noch = ft_sourcedescriptives([], ft_sourceanalysis(cfg, noch_tf));

cfg           = [];
cfg.operation = '(log10(x1)-log10(x2))./log10(x2)';
cfg.parameter = 'pow';
source_ratio  = ft_math(cfg, source_noch, source_conv);


% create a fancy mask
% source_ratio.mask = (1+tanh(2.*(source_ratio.pow./max(source_ratio.pow(:))-0.5)))./2; 

cfg = [];
cfg.method        = 'surface';
cfg.funparameter  = 'pow';
cfg.maskparameter = 'mask';
% cfg.funcolorlim   = [-.3 .3];
cfg.funcolormap   = 'jet';
cfg.colorbar      = 'no';
ft_sourceplot(cfg, source_ratio);
view([-90 30]);
light('style','infinite','position',[0 -200 200]);

