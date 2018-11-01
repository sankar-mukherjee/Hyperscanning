function [comp,comp_r] = filedtrip_BSS(b,target_data,config,no_of_time)
%% [Step 3:1] ICA and BSS-CCA two times
cfg        = [];
cfg.channel = b';
cfg.method = 'fastica'; % fastica bsscca
comp = ft_componentanalysis(cfg, target_data);

% check the components
% average the components timelocked to the QRS-complex
cfg           = [];
timelock      = ft_timelockanalysis(cfg, comp);
figure
subplot(2,1,1); plot(timelock.time, timelock.avg(1,:))
subplot(2,1,2); plot(timelock.time, timelock.avg(2:end,:))
figure
subplot(2,1,1); plot(timelock.time, timelock.avg(1,:))
subplot(2,1,2); imagesc(timelock.avg(2:end,:));
% % %
% % % % plot the components for visual inspection
% cfg          = [];
% % cfg.channel  = [2:5 15:18]; % components to be plotted
% cfg.viewmode = 'component';
% cfg.layout   = 'biosemi64.lay'; % specify the layout file that should be used for plotting
% ft_databrowser(cfg, comp);

%
comp_r = component_remove_criteria(comp,config.time_window);

% figure;  pcolor(comp_r);
% s = sum(comp_r)
% find(s)
% pause;
% % if(no_of_time)    
% %     %% [Step 3:2] ICA and BSS-CCA
% %     
% %     badcomp = input('bad components [] --> ');
% %     
% %     cfg        = [];
% %     cfg.component = size(comp.topo,1) - length(badcomp);
% %     cfg.channel = b';
% %     cfg.method = 'bsscca'; % fastica bsscca
% %     comp = ft_componentanalysis(cfg, target_data);
% %     
% %     %
% %     cfg           = [];
% %     timelock      = ft_timelockanalysis(cfg, comp);
% %     figure
% %     subplot(2,1,1); plot(timelock.time, timelock.avg(1,:))
% %     subplot(2,1,2); plot(timelock.time, timelock.avg(2:end,:))
% %     figure
% %     subplot(2,1,1); plot(timelock.time, timelock.avg(1,:))
% %     subplot(2,1,2); imagesc(timelock.avg(2:end,:));
% %     % % %
% %     % % % % plot the components for visual inspection
% %     figure
% %     cfg = [];
% %     cfg.component = [1:size(comp.topo,2)];       % specify the component(s) that should be plotted
% %     cfg.layout    = 'biosemi64.lay'; % specify the layout file that should be used for plotting
% %     cfg.comment   = 'no';
% %     ft_topoplotIC(cfg, comp);
% %     
% %     %
% %     [comp_r,tf] = component_remove_criteria(comp,config.time_window);
% %     figure;  pcolor(comp_r);
% % end
end