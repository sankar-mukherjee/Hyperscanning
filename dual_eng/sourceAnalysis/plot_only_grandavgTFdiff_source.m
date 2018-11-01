clear;clc;

exp.cond='prespeech';


if(strcmp(exp.cond,'prespeech'))
    exp.freq = [12 14];
elseif(strcmp(exp.cond,'prelisten'))
    exp.time = [-0.26 -0.19];
    exp.freq = [22 24];
elseif(strcmp(exp.cond,'postlisten_24'))
    exp.time = [0.05 0.1];
    exp.freq = [24 29];
elseif(strcmp(exp.cond,'postlisten_32'))
    exp.time = [0.07 0.125];
    exp.freq = [32 34];
end

conv_tf1 = conv_tf;
noch_tf1 = noch_tf;


%% log
cfg           = [];
cfg.operation = 'log10';a=[];b=[];
for i=1:length(conv_tf1)
    cfg.parameter = 'powspctrm';
    
    conv_tf1{i} = ft_math(cfg, conv_tf{i});
    noch_tf1{i} = ft_math(cfg, noch_tf{i});
    
    cfg.parameter = 'crsspctrm';
    a{i} = ft_math(cfg, conv_tf{i});
    b{i} = ft_math(cfg, noch_tf{i});
    
    conv_tf1{i}.crsspctrm = a{i}.crsspctrm;
    noch_tf1{i}.crsspctrm = b{i}.crsspctrm;
    conv_tf1{i}.labelcmb = conv_tf{i}.labelcmb;
    noch_tf1{i}.labelcmb = noch_tf{i}.labelcmb;
end

%%
GA_conv_tf = conv_tf1{1};
GA_conv_tf.powspctrm              = [];
GA_conv_tf.crsspctrm              = [];
GA_noch_tf = noch_tf1{1};
GA_noch_tf.powspctrm              = [];
GA_noch_tf.crsspctrm              = [];
for i=1:length(noch_tf1)
    GA_conv_tf.powspctrm = [GA_conv_tf.powspctrm conv_tf1{i}.powspctrm];
    GA_conv_tf.crsspctrm = [GA_conv_tf.crsspctrm conv_tf1{i}.crsspctrm];
    GA_noch_tf.powspctrm = [GA_noch_tf.powspctrm noch_tf1{i}.powspctrm];
    GA_noch_tf.crsspctrm = [GA_noch_tf.crsspctrm noch_tf1{i}.crsspctrm];
end
GA_conv_tf.powspctrm = mean(GA_conv_tf.powspctrm,2);
GA_conv_tf.crsspctrm = mean(GA_conv_tf.crsspctrm,2);
GA_noch_tf.powspctrm = mean(GA_noch_tf.powspctrm,2);
GA_noch_tf.crsspctrm = mean(GA_noch_tf.crsspctrm,2);

     

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff    = ft_math(cfg, GA_conv_tf, GA_noch_tf);

cfg.parameter = 'crsspctrm';
a     = ft_math(cfg, GA_conv_tf, GA_noch_tf);
TFR_diff.crsspctrm = a.crsspctrm;
TFR_diff.labelcmb = GA_conv_tf.labelcmb;

%% source
load('headmodel_biosemi64_grid2');

cfg              = [];
cfg.method       = 'dics';
cfg.frequency    = median(exp.freq);
cfg.grid         = grid;
cfg.headmodel          = vol;
cfg.senstype     = 'EEG'; % Remember this must be specified as either EEG, or MEG
cfg.dics.keepfilter   = 'yes';
cfg.dics.realfilter   = 'yes';
cfg.dics.lambda       = '15%';
source_diff = ft_sourceanalysis(cfg, TFR_diff);

load('standard_mri.mat');

cfg            = [];
cfg.parameter = 'pow';
source_diff_rescale  = ft_sourceinterpolate(cfg, source_diff, mri);

cfg = [];
cfg.nonlinear     = 'no';
sourceDiffIntNorm1 = ft_volumenormalise(cfg, source_diff_rescale);

cfg = [];
cfg.method         = 'surface';
cfg.funparameter   = 'pow';
cfg.maskparameter  = cfg.funparameter;
% cfg.funcolorlim    = [0 0.5];
cfg.funcolormap    = 'jet';
cfg.opacitymap    = 'vdown';
cfg.opacitylim    = 'maxabs'; % or 'maxabs'
% cfg.opacitylim     = [0.0 1.2]; 
% cfg.opacitymap     = 'rampup';  
% cfg.projmethod     = 'nearest'; 
% cfg.surffile       = 'surface_white_both.mat';
% cfg.surfdownsample = 10; 
ft_sourceplot(cfg, sourceDiffIntNorm1);



cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'pow';
cfg.maskparameter =  cfg.funparameter;
ft_sourceplot(cfg, sourceDiffIntNorm1);

cfg = [];
cfg.method        = 'ortho';
cfg.atlas         = 'C:\Users\SMukherjee\Desktop\matlab_toolbox\fieldtrip-master\template\atlas\aal\ROI_MNI_V4.nii';
cfg.funparameter  = 'pow';
cfg.maskparameter =  cfg.funparameter;
ft_sourceplot(cfg, sourceDiffIntNorm1);






















