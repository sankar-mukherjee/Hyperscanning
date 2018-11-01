%% create head model with BEM for biosemi64

%% create electrode location
load('biosemi_loc.mat');

elec.chanpos = [cell2mat({chanlocs.X})' cell2mat({chanlocs.Y})' cell2mat({chanlocs.Z})'];
[a{1:64}] = deal('eeg');
elec.chantype =  a';
[a{1:64}] = deal('V');
elec.chanunit =  a';
elec.elecpos = [cell2mat({chanlocs.X})' cell2mat({chanlocs.Y})' cell2mat({chanlocs.Z})'];
elec.label = {chanlocs.labels}';
elec.type = 'biosemi64';
elec.unit = 'mm';

save('biosemi64_elec.mat','elec');

%% realigh electrode to headmodel (standard)
load('biosemi64_elec.mat');
% read  headmodel
load('C:\Users\SMukherjee\Desktop\matlab_toolbox\fieldtrip-master\template\headmodel\standard_bem.mat');
% electrode realign as good as possible
% i.e. rotete 0 0 90
cfg=[];
cfg.method = 'interactive';
cfg.elec = elec;
cfg.headshape = vol.bnd(1);
elecR = ft_electroderealign(cfg);

% make them closer to the skin
[vol, elecR]=ft_prepare_vol_sens(vol,elecR);
elecR.type = 'biosemi64';


% % verify how the electrodes fit toghether with the brain volume
% cfg=[];
% cfg.method = 'interactive';
% cfg.elec = elecR;
% cfg.headshape = vol.bnd(3).pos;
% elecR = ft_electroderealign(cfg);

%% Compute lead field (discretize the brain volume into a grid.)

% common grid/filter
cfg                 = [];
cfg.elec            = elecR; 
cfg.headmodel             = vol;
cfg.reducerank      = 3; % default is 3 for EEG, 2 for MEG
cfg.grid.resolution = 0.5;   % use a 3-D grid with a 0.5 mm resolution
cfg.grid.unit       = 'mm';
cfg.grid.tight      = 'yes';
[grid] = ft_prepare_leadfield(cfg);

save('headmodel_biosemi64_grid.mat','vol','elecR','grid');