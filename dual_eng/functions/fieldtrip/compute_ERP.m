function [avg_erp,GA_avg_erp,scd_avg_erp] = compute_ERP(data,time_window)
%% ERP
cfg = [];
cfg.channel   = 'all';
cfg.latency   = time_window;
cfg.parameter = 'avg';

for i=1:length(data)
    avg_erp{i} = ft_timelockanalysis(cfg, data{i});
end

GA_avg_erp         = ft_timelockgrandaverage(cfg,avg_erp{:});



% % Scalp current density [Laplacian trnasform]
% cfg                 = [];
% cfg.method          = 'spline';
% cfg.elec            = avg_erp{1}.elec;
% cfg.layout          = 'biosemi64.lay'; 
% cfg.zlim            = 'maxabs';
% cfg.xlim            = time_window;
% cfg.style           = 'straight';
% cfg.comment         = 'no';
% cfg.marker          = 'off';
% cfg.colorbar        = 'southoutside';
% 
% scd_avg_erp = []; 
% 
% for sub = 1:length(data)    
%     scd_avg_erp{sub}    = ft_scalpcurrentdensity(cfg, data{sub});
% end
scd_avg_erp = 0;
end