cfg = [];
cfg.toilim = [0.35 0.85];
data_timewindow = ft_redefinetrial(cfg,data_clean_EEG_responselocked);

% Freqanalysis for beamformer
cfg = [];
cfg.method       = 'mtmfft';
cfg.taper        = 'dpss';
cfg.output       = 'powandcsd';
cfg.keeptrials   = 'no';
cfg.foi          = 18;
cfg.tapsmofrq    = 4;
 
% for common filter over conditions and full duration
powcsd_all      = ft_freqanalysis(cfg, data_timewindow);
 
% for conditions
cfg.trials       = find(data_timewindow.trialinfo(:,1) == 256);
powcsd_left      = ft_freqanalysis(cfg, data_timewindow);
cfg.trials       = find(data_timewindow.trialinfo(:,1) == 4096);
powcsd_right     = ft_freqanalysis(cfg, data_timewindow);

% common grid/filter
cfg                 = [];
cfg.elec            = powcsd_all.elec; 
cfg.headmodel       = headmodel_eeg;
cfg.reducerank      = 3; % default is 3 for EEG, 2 for MEG
cfg.grid.resolution = 1;   % use a 3-D grid with a 0.5 cm resolution
cfg.grid.unit       = 'cm';
cfg.grid.tight      = 'yes';
[grid1] = ft_prepare_leadfield(cfg);

% beamform common filter
cfg              = []; 
cfg.method       = 'dics';
cfg.frequency    = 18;  
cfg.grid         = grid1; 
cfg.headmodel          = headmodel_eeg;
cfg.senstype     = 'EEG'; % Remember this must be specified as either EEG, or MEG
cfg.dics.keepfilter   = 'yes';
cfg.dics.lambda       = '15%';
source_all = ft_sourceanalysis(cfg, powcsd_all);

% beamform conditions
cfg              = []; 
cfg.method       = 'dics';
cfg.frequency    = 18;  
cfg.grid         = grid1; 
cfg.grid.filter  = source_all.avg.filter; % Use the common filter
cfg.headmodel          = headmodel_eeg;
cfg.senstype     = 'EEG';
 
source_left = ft_sourceanalysis(cfg, powcsd_left);
source_right = ft_sourceanalysis(cfg, powcsd_right);



source_diff_int  = source_left;
source_diff_int.pow  = (source_left.avg.pow - source_right.avg.pow) ./ (source_left.avg.pow + source_right.avg.pow);
cfg            = [];
cfg.parameter = 'pow';
source_diff  = ft_sourceinterpolate(cfg, source_diff_int, mri_resliced);
cfg = [];
cfg.method        = 'surface';
cfg.funparameter  = 'pow';
cfg.funcolorlim   = 'maxabs'; 
ft_sourceplot(cfg, source_diff);



cfg            = [];
cfg.parameter = 'pow';
source_left_int  = ft_sourceinterpolate(cfg, source_left, mri_resliced);
source_right_int  = ft_sourceinterpolate(cfg, source_right, mri_resliced);


source_diff_int  = source_left_int;
source_diff_int.pow  = (source_left_int.pow - source_right_int.pow) ./ (source_left_int.pow + source_right_int.pow);


cfg = [];
cfg.method        = 'surface';
cfg.funparameter  = 'pow';
cfg.funcolorlim   = 'maxabs';
 
ft_sourceplot(cfg, source_diff_int);

cfg              = [];
cfg.method       = 'slice';
cfg.funparameter = 'pow';
ft_sourceplot(cfg,source_diff_int);


cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'pow';
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim   = [4.0 6.2];
cfg.opacitylim    = [4.0 6.2]; 
cfg.opacitymap    = 'rampup';  
ft_sourceplot(cfg, source_diff_int);




%%%%%%%%%%%%%%%%%%%%







%%
source_diff=[];
for i=1:length(source_conv)
    source_diff{i,1}  = source_noch{i,1};
    source_diff{i,1}.pow  = source_conv{i,1}.pow - source_noch{i,1}.pow;
end



cfg = [];
cfg.resolution = 1;
cfg.xrange = [-100 100];
cfg.yrange = [-110 140];
cfg.zrange = [-80 120];
mri_resliced = ft_volumereslice(cfg, mri);



the call to "ft_sourceinterpolate" took 9 seconds
the input is volume data with dimensions [201 251 201]
the input is source data with 32190 brainordinates on a [29 37 30] grid






cfg              = [];tf_d = [];

for i=1:length(data_noCh)
    tf_d{i} = ft_freqdescriptives(cfg, conv_tf{i});
end
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'powspctrm';
GA_NOCH = ft_freqgrandaverage(cfg, tf_d{:});

GA_NOCH.elec = elecR;



% load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\10000it\EEG__32_10_mwv_mfc_convVSnoch_5ms_1.mat');
% GA_tf_CONV.elec = elecR;
% beamform common filter
cfg              = []; 
cfg.method       = 'dics';
cfg.frequency    = 13;  
cfg.grid         = grid; 
cfg.vol          = vol;
cfg.senstype     = 'eeg'; % Remember this must be specified as either EEG, or MEG
cfg.dics.keepfilter   = 'yes';
cfg.dics.lambda       = '15%';

source_conv= [];source_noch=[];
for i=1:length(data_noCh)
    source_conv{i,1} = ft_sourceanalysis(cfg, conv_tf{i});
    source_noch{i,1} = ft_sourceanalysis(cfg, noch_tf{i});    
end


cfg = [];
cfg.method        = 'ortho';
cfg.funparameter  = 'pow';
cfg.funcolorlim   = 'maxabs'; 
ft_sourceplot(cfg, source_conv{1,1});













% verify how the electrodes fit toghether with the brain volume
cfg=[];
cfg.method = 'interactive';
cfg.elec = elecR;
cfg.headshape = vol.bnd(1).pos;
elecRR = ft_electroderealign(cfg);










% verify how the electrodes fit toghether with the brain volume
cfg=[];
cfg.method = 'interactive';
cfg.elec = elecR;
cfg.headshape = vol.bnd(1);
elecRR = ft_electroderealign(cfg);


[volR, elecR]=ft_prepare_vol_sens(volR,elecRR);
cfg=[];
cfg.method = 'interactive';
cfg.elec = elecR;
cfg.headshape = volR.bnd(1);
elecRR = ft_electroderealign(cfg);








figure;
% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); 
hold on;
% electrodes
ft_plot_sens(elecR,'style', 'sk');    

load segmentedmri







%%
mri = ft_read_mri('C:\Users\SMukherjee\Desktop\matlab_toolbox\fieldtrip-master\external\spm8\templates\T1.nii');

% segment the MRI
cfg           = [];
cfg.output    = {'brain'  'skull'  'scalp'};
segmentedmri  = ft_volumesegment(cfg, mri);


% create the headmodel (BEM)
cfg        = [];
cfg.method ='openmeeg'; % TODO FIXME download openmeeg
cfg.method ='dipoli'; % dipoli only works under linux
hdm        = ft_prepare_headmodel(cfg, segmentedmri);

elec       = ft_read_sens('standard_1020.elc');
hdm        = ft_convert_units(hdm, elec.unit);

cfg = [];
cfg.grid.xgrid  = -125:8:125;
cfg.grid.ygrid  = -125:8:125;
cfg.grid.zgrid  = -125:8:125;
cfg.grid.tight  = 'yes';
cfg.grid.unit   = hdm.unit;
cfg.inwardshift = -1.5;
cfg.vol        = hdm;
grid  = ft_prepare_sourcemodel(cfg)
grid        = ft_convert_units(grid, elec.unit);

figure;
hold on;
ft_plot_mesh(hdm.bnd(1), 'facecolor',[0.2 0.2 0.2], 'facealpha', 0.3,'edgecolor', [1 1 1], 'edgealpha', 0.05);
ft_plot_mesh(grid.pos(grid.inside, :));

% this step is not necessary, cause you will see that everything is already aligned
cfg           = [];
cfg.method    = 'interactive';
cfg.elec      = elec;
cfg.headshape = hdm.bnd(1);
tmp  = ft_electroderealign(cfg);
elec = tmp; % I had a bug here that I couldn't assign elec directly

% verify location of occipital electrodes

occ_elec = elec;
occ_chan = ft_channelselection({'O*', 'PO*', 'Cz*', 'Fz*'}, elec.label);
occ_idx = match_str(elec.label, occ_chan);
occ_elec.chanpos = occ_elec.chanpos(occ_idx, :);
occ_elec.elecpos = occ_elec.elecpos(occ_idx, :);
occ_elec.label = occ_elec.label(occ_idx, :);
figure;
ft_plot_sens(occ_elec)
hold on;
ft_plot_vol(ft_convert_units(hdm, elec.unit))


























%%

load segmentedmri
cfg=[];
cfg.tissue={'brain','skull','scalp'};
cfg.numvertices = [3000 2000 1000];
bnd=ft_prepare_mesh(cfg,segmentedmri);
















%%
load segmentedmri
cfg = [];
cfg.method = 'singleshell';
headmodel = ft_prepare_headmodel(cfg, segmentedmri);


cfg                 = [];
cfg.grad            = freqPost.grad;
cfg.headmodel       = headmodel;
cfg.reducerank      = 2;
cfg.grid.resolution = 1;   % use a 3-D grid with a 1 cm resolution
cfg.grid.unit       = 'cm';
[grid] = ft_prepare_leadfield(cfg);

load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\10000it\EEG__32_10_mwv_mfc_convVSnoch_5ms_1.mat');

cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'powandcsd';
cfg.tapsmofrq = 4;
cfg.foilim    = [13];
tf_conv = ft_freqanalysis(cfg, data_conv);

cfg = [];
cfg.method = 'bemcp';
cfg.conductivity = [1 1/20 1].*0.33; % brain, skull, scalp
headmodel_eeg = ft_prepare_headmodel(cfg, mesh_eeg);










cfg = [];
cfg.toilim = [0.35 0.85];
data_timewindow = ft_redefinetrial(cfg,data_clean_EEG_responselocked);

% Freqanalysis for beamformer
cfg = [];
cfg.method       = 'mtmfft';
cfg.taper        = 'dpss';
cfg.output       = 'powandcsd';
cfg.keeptrials   = 'no';
cfg.foi          = 18;
cfg.tapsmofrq    = 4;
 
% for common filter over conditions and full duration
powcsd_all      = ft_freqanalysis(cfg, data_timewindow);
 
% for conditions
cfg.trials       = find(data_timewindow.trialinfo(:,1) == 256);
powcsd_left      = ft_freqanalysis(cfg, data_timewindow);
cfg.trials       = find(data_timewindow.trialinfo(:,1) == 4096);
powcsd_right     = ft_freqanalysis(cfg, data_timewindow);

% common grid/filter
cfg                 = [];
cfg.elec            = powcsd_all.elec; 
cfg.vol             = headmodel_eeg;
cfg.reducerank      = 3; % default is 3 for EEG, 2 for MEG
cfg.grid.resolution = 0.5;   % use a 3-D grid with a 0.5 cm resolution
cfg.grid.unit       = 'cm';
cfg.grid.tight      = 'yes';
[grid1] = ft_prepare_leadfield(cfg);

% beamform common filter
cfg              = []; 
cfg.method       = 'dics';
cfg.frequency    = 18;  
cfg.grid         = grid1; 
cfg.vol          = headmodel_eeg;
cfg.senstype     = 'EEG'; % Remember this must be specified as either EEG, or MEG
cfg.dics.keepfilter   = 'yes';
cfg.dics.lambda       = '15%';
source_all = ft_sourceanalysis(cfg, powcsd_all);

% beamform conditions
cfg              = []; 
cfg.method       = 'dics';
cfg.frequency    = 18;  
cfg.grid         = grid1; 
cfg.grid.filter  = source_all.avg.filter; % Use the common filter
cfg.vol          = headmodel_eeg;
cfg.senstype     = 'EEG';
 
source_left = ft_sourceanalysis(cfg, powcsd_left);
source_right = ft_sourceanalysis(cfg, powcsd_right);

cfg            = [];
cfg.parameter = 'pow';
source_left_int  = ft_sourceinterpolate(cfg, source_left, mri_resliced);
source_right_int  = ft_sourceinterpolate(cfg, source_right, mri_resliced);


source_diff_int  = source_left_int;
source_diff_int.pow  = (source_left_int.pow - source_right_int.pow) ./ (source_left_int.pow + source_right_int.pow);


cfg = [];
cfg.method        = 'ortho';
cfg.funparameter  = 'pow';
cfg.funcolorlim   = 'maxabs';
 
ft_sourceplot(cfg, source_left_int);












