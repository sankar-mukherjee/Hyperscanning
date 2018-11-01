

clear;clc;
load('headmodel_biosemi64_grid');

atlas = ft_read_atlas('C:\Users\SMukherjee\Desktop\matlab_toolbox\fieldtrip-master\template\atlas\afni/TTatlas+tlrc.BRIK');
% atlas = ft_read_atlas('C:\Users\SMukherjee\Desktop\matlab_toolbox\fieldtrip-master/template/atlas/aal/ROI_MNI_V4.nii'); 
% atlas = ft_convert_units(atlas,'mm');% assure that atlas and template_grid are expressed in the %same units 
cfg = [];
cfg.atlas = atlas;
% cfg.roi = atlas.tissuelabel;
% cfg.inputcoord = 'mni';
cfg.roi = [atlas.brick0label; atlas.brick1label];
cfg.inputcoord = 'tal';
mask = ft_volumelookup(cfg,grid); 
% create temporary mask according to the atlas entries
tmp                  = repmat(grid.inside,1,1);
tmp(tmp==1)          = 0;
tmp(mask)            = 1; 
% define inside locations according to the atlas based mask
grid.inside = tmp; 
% plot the atlas based grid
figure;ft_plot_mesh(grid.pos(grid.inside,:));

load('standard_mri.mat');
cfg                = [];
cfg.grid.warpmni   = 'yes';
cfg.grid.template  = grid;
cfg.grid.nonlinear = 'yes';
cfg.mri            = mri;
cfg.grid.unit       = 'mm';
sourcemodel        = ft_prepare_sourcemodel(cfg);

% common grid/filter
cfg                 = [];
cfg.elec            = elecR; 
cfg.headmodel       = vol;
cfg.reducerank      = 3; % default is 3 for EEG, 2 for MEG
cfg.grid = sourcemodel;
cfg.grid.unit       = 'mm';
[grid] = ft_prepare_leadfield(cfg);




figure; hold on     % plot all objects in one figure 
ft_plot_vol(vol,  'facecolor', 'cortex', 'edgecolor', 'none');alpha 0.5; %camlight;
alpha 0.4           % make the surface transparent 
ft_plot_mesh(sourcemodel.pos(sourcemodel.inside,:));% plot only locations inside the volume 
ft_plot_sens(elecR,'style','*r');% plot the sensor array
view ([0 -90 0])


save('headmodel_biosemi64_grid2.mat','vol','elecR','grid');









