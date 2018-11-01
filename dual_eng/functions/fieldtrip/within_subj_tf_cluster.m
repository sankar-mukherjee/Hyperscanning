function stat = within_subj_tf_cluster(GA_tf_CONV,GA_tf_NOCH,neighbours,freq,subj,latency)
%%
cfg = [];
cfg.channel          = {'EEG'};
cfg.latency          = latency;              % 'all';
cfg.frequency        = freq;
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 0;
cfg.neighbourdist    = 1;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.correcttail      = 'prob';  % 'prob''alpha'
cfg.numrandomization = 500;
% specifies with which sensors other sensors can form clusters
cfg.neighbours       = neighbours;
cfg.avgoverfreq = 'yes';

design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_freqstatistics(cfg, GA_tf_CONV, GA_tf_NOCH);

% cfg = [];
% cfg.alpha            = 0.05;
% cfg.parameter = 'stat';
% cfg.zlim   = [-4 4];
% cfg.layout = 'biosemi64.lay';
% ft_clusterplot(cfg, stat);
% hold on;suptitle(['Frequency ' num2str(freq)]);
disp(['----------------------------------------------------------------------Frequency ' num2str(freq)]);
end