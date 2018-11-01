function stat = within_trial_tf_cluster(tf_CONV,tf_NOCH,neighbours,freq,latency)
%% with in trials


cfg = [];
cfg.channel          = {'EEG'};
cfg.latency          = latency;
cfg.method           = 'montecarlo';
cfg.frequency        = freq;
cfg.statistic        = 'ft_statfun_indepsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.correcttail      = 'alpha';  % 'prob''alpha'
cfg.numrandomization = 1000;
cfg.neighbours       = neighbours;

ntrials = size(tf_CONV.powspctrm,1);
design  = zeros(2,2*ntrials);
design(1,1:ntrials) = 1;
design(1,ntrials+1:2*ntrials) = 2;
design(2,1:ntrials) = [1:ntrials];
design(2,ntrials+1:2*ntrials) = [1:ntrials];

cfg.design   = design;
cfg.ivar     = 1;

% same no of sample has to be there
tf_NOCH1 = tf_NOCH;
a = randsample(1:size(tf_NOCH.powspctrm,1),ntrials);
tf_NOCH1.powspctrm = tf_NOCH1.powspctrm(a,:,:,:);
tf_NOCH1.cumtapcnt = tf_NOCH1.cumtapcnt(a,:,:,:);
tf_NOCH1.trialinfo = tf_NOCH1.trialinfo(a,:,:,:);


[stat] = ft_freqstatistics(cfg, tf_CONV, tf_NOCH1);


end