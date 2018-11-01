function stat = within_subj_ERP_cluster(CONV,NOCH,neighbours,time_window,Nsub)
%% channel-time cluster
cfg = [];
cfg.channel     = 'EEG';
cfg.neighbours  = neighbours; % defined as above
cfg.latency     = time_window;
cfg.avgovertime = 'no';
cfg.parameter   = 'avg';
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization = 2500;
cfg.minnbchan        = 2; % minimal neighbouring channels
 
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
 
stat = ft_timelockstatistics(cfg,CONV{:},NOCH{:});
% 
% % try
% % make a plot
% cfg = [];
% cfg.highlightsymbolseries = ['*','*','.','.','.'];
% cfg.layout = 'biosemi64.lay';
% cfg.contournum = 0;
% cfg.markersymbol = '.';
% cfg.alpha = 0.4;
% cfg.parameter='stat';
% cfg.zlim = [-5 5];
% ft_clusterplot(cfg,within_subj_erp_cluster);
% % catch
% %
% % make a plot all at once
% cfg = [];
% cfg.style     = 'blank';
% % cfg.layout = 'biosemi64.lay';
% cfg.highlight = 'on';
% cfg.highlightchannel = find(stat.mask);
% cfg.comment   = 'no';
% figure; ft_topoplotER(cfg, CONV{1})
% title('Nonparametric: significant with cluster multiple comparison correction')
% % end
end