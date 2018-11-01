function f = compute_reactiome_realtion(D,CONV_tf,NOCH_tf,conv_idx,noCh_idx,channel,freq,time_w)

[f.C_R,f.C_P,f.C_mean,f.C_RT] = confidence_interval_RT(D,CONV_tf,freq,time_w,channel ,conv_idx);
[f.N_R,f.N_P,f.N_mean,f.N_RT] = confidence_interval_RT(D,NOCH_tf,freq,time_w,channel ,noCh_idx);

% compute statistics with ft_statfun_indepsamleT
cfg = [];
cfg.statistic        = 'ft_statfun_correlationT';
cfg.method           = 'montecarlo';
cfg.channel          = channel;
cfg.latency          = time_w;              % 'all';
cfg.frequency        = [CONV_tf{1}.freq(freq(1)) CONV_tf{1}.freq(freq(2))];
cfg.avgoverchan = 'yes';
cfg.avgovertime = 'yes';
cfg.avgoverfreq = 'yes';
cfg.alpha            = 0.05;
cfg.tail             = 1;
cfg.computecritval   = 'yes';
cfg.numrandomization = 1000;

%conv
cfg_a = [];
cfg_a.parameter  = 'powspctrm';
a = ft_appendfreq(cfg_a, CONV_tf{:});
id = find(ismember(a.trialinfo(:,2),conv_idx));
a = ft_selectdata(a, 'rpt', id);
design = [];
n1 = size(a.trialinfo,1);    % n1 is the number of trials
design(1,1:n1)       = D(a.trialinfo(:,2),14); %here we insert our independent variable (behavioral data) in the cfg.design matrix, in this case accuracy per trial of 1 subject.
cfg.design           = design;
cfg.ivar             = 1;
stat = ft_freqstatistics(cfg, a);

f.coef = stat.rho
f.se = stat.cirange
f.t = stat.stat
f.p = stat.prob 
f.df = stat.df


%noch
cfg_a = [];
cfg_a.parameter  = 'powspctrm';
a = ft_appendfreq(cfg_a, NOCH_tf{:});
id = find(ismember(a.trialinfo(:,2),noCh_idx));
a = ft_selectdata(a, 'rpt', id);
design = [];
n1 = size(a.trialinfo,1);    % n1 is the number of trials
design(1,1:n1)       = D(a.trialinfo(:,2),14); %here we insert our independent variable (behavioral data) in the cfg.design matrix, in this case accuracy per trial of 1 subject.
cfg.design           = design;
cfg.ivar             = 1;
stat = ft_freqstatistics(cfg, a);

f.n.coef = stat.rho
f.n.se = stat.cirange
f.n.t = stat.stat
f.n.p = stat.prob 
f.n.df = stat.df

end