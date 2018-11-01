
load('speech_data.mat')

cfg = [];
cfg.toilim = [-0.26 -0.19];

for i=1:length(data_noCh)
    data_conv{i,1} = ft_redefinetrial(cfg, data_conv{i,1});
    data_noCh{i,1} = ft_redefinetrial(cfg, data_noCh{i,1});
end
%%
dataAll = [];
for i=1:length(data_noCh)    
    dataAll{i,1} = ft_appenddata([], data_conv{i,1}, data_noCh{i,1});
end

% Freqanalysis for beamformer
cfg = [];
cfg.method       = 'mtmfft';
cfg.output       = 'powandcsd';
cfg.taper ='hanning';
cfg.foi          = [12 14];
% cfg.tapsmofrq    = 2;
% cfg.pad        = 1;
% cfg.padtype     = 'zero';

conv_tf = ft_freqanalysis(cfg,data_conv{1});



conv_tf = [];noch_tf = [];freqAll=[];
for i=1:length(data_noCh)    
    conv_tf{i} = ft_freqanalysis(cfg, data_conv{i});
    noch_tf{i} = ft_freqanalysis(cfg, data_noCh{i});
    freqAll{i} = ft_freqanalysis(cfg, dataAll{i});
end

save('speech_freq.mat','conv_tf','noch_tf','freqAll');

clear all
%% source analysis
load('headmodel_biosemi64_grid');
load('speech_freq');

cfg              = []; 
cfg.method       = 'dics';
cfg.frequency    = 13;  
cfg.grid         = grid; 
cfg.headmodel          = vol;
cfg.senstype     = 'EEG'; % Remember this must be specified as either EEG, or MEG
cfg.dics.keepfilter   = 'yes';
cfg.dics.realfilter   = 'yes';
cfg.dics.lambda       = '15%';

sourceAll=[];
for i=1:length(freqAll)
    sourceAll{i,1} = ft_sourceanalysis(cfg, freqAll{i});
end


source_conv= [];source_noch=[];
for i=1:length(conv_tf)
    cfg.grid.filter = sourceAll{i}.avg.filter;
    source_conv{i,1} = ft_sourceanalysis(cfg, conv_tf{i});
    source_noch{i,1} = ft_sourceanalysis(cfg, noch_tf{i});    
end

save('speech_source.mat','source_conv','source_noch');
clear all
%% source interpolate with each individual subject with standard mri

load('speech_source.mat');
load('standard_mri.mat')

cfg            = [];
cfg.parameter = 'pow';
source_conv_rescale = [];source_noch_rescale=[];
for i=1:length(source_noch)
    source_conv_rescale{i,1}  = ft_sourceinterpolate(cfg, source_conv{i,1}, mri);
    source_noch_rescale{i,1}  = ft_sourceinterpolate(cfg, source_noch{i,1}, mri);
end

clear source_conv source_noch ;


% diffrenece
source_diff = [];
for i=1:length(source_conv_rescale)
    source_diff{i}  = source_conv_rescale{i};
    source_diff{i}.pow  = (source_conv_rescale{i}.pow - source_noch_rescale{i}.pow);
end

save('speech_source_rescale.mat','source_diff','source_conv_rescale','source_noch_rescale');
clear all

%% grand average first then diff
load('speech_source.mat');
load('standard_mri.mat')


source_conv_d  = ft_sourcedescriptives([], source_conv{:});
source_noch_d = ft_sourcedescriptives([], source_noch{:});

cfg = [];
cfg.parameter          = 'avg.pow';
GA_source_conv = ft_sourcegrandaverage(cfg, source_conv{:});
GA_source_noch = ft_sourcegrandaverage(cfg, source_noch{:});


cfg = [];
cfg.parameter = 'pow';
cfg.operation = '(x1-x2)./x2';
source_diff      = ft_math(cfg, GA_source_conv, GA_source_noch);

cfg            = [];
cfg.parameter = 'pow';
source_diff_rescale  = ft_sourceinterpolate(cfg, source_diff, mri);



%% grand averages
load('speech_source_rescale.mat','source_diff');

cfg = [];
cfg.nonlinear     = 'no';
sourceDiffIntNorm = [];
for i=1:length(source_diff)    
    sourceDiffIntNorm{i} = ft_volumenormalise(cfg, source_diff{i});
end


cfg = [];
cfg.parameter          = 'pow';
GA_source_diffNorm = ft_sourcegrandaverage(cfg, sourceDiffIntNorm{:});
GA_source = ft_sourcegrandaverage(cfg, source_diff{:});

GA_source_conv = ft_sourcegrandaverage(cfg, source_conv_rescale{:});
GA_source_noch = ft_sourcegrandaverage(cfg, source_noch_rescale{:});

%% log transform
cfg           = [];
cfg.parameter = 'pow';
cfg.operation = 'log10';
GA_source_conv    = ft_math(cfg, GA_source_conv);
GA_source_noch    = ft_math(cfg, GA_source_noch);

cfg = [];
cfg.parameter = 'pow';
cfg.operation = 'subtract';
power_diff      = ft_math(cfg, GA_source_conv, GA_source_noch);

%% plot
cfg = [];
cfg.method        = 'surface';
cfg.funparameter  = 'pow';
% cfg.funcolorlim   = 'maxabs'; 
ft_sourceplot(cfg, GA_source);

cfg = [];
cfg.method         = 'surface';
cfg.funparameter   = 'pow';
cfg.maskparameter  = cfg.funparameter;
cfg.funcolorlim    = [0 0.5];
cfg.funcolormap    = 'jet';
cfg.opacitylim     = [0.0 1.2]; 
cfg.opacitymap     = 'rampup';  
cfg.projmethod     = 'nearest'; 
cfg.surffile       = 'surface_white_both.mat';
cfg.surfdownsample = 10; 
ft_sourceplot(cfg, source_diff_rescale);
ft_sourceplot(cfg, GA_source_noch);

ft_sourceplot(cfg, source_diff);



cfg = [];
cfg.method        = 'ortho';
cfg.interactive   = 'yes';
cfg.funparameter  = 'pow';
cfg.maskparameter = cfg.funparameter;
% cfg.funcolorlim   = [0.0 1.2];
cfg.opacitylim    = [0.0 1.2]; 
cfg.opacitymap    = 'rampup';  
ft_sourceplot(cfg, GA_source);
ft_sourceplot(cfg, GA_source_diffNorm);

%%  new one








































