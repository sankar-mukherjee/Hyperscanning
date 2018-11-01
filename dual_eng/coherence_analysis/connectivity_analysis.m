%% permutation test for coherence
load('surrogate_coh.mat')

fb = strcat(coh_full{1,1}.labelcmb(:,1),coh_full{1,1}.labelcmb(:,2));

%% averege surrogate coherence
coh_surrogate{1,1} = coh_surrogate{2,1};
for i=1:length(coh_surrogate)
    coh_surrogate{i}.label = fb;
    coh_surrogate{i}.dimord = 'chan_freq_time';
end

cfg = [];
cfg.parameter = 'cohspctrm';
cfg.channel          = fb;
coh_surrogate_avg = ft_freqgrandaverage(cfg,coh_surrogate{:});

%% singnificant connection (full)

Ngroup = length(coh_full);

coh_full1 = coh_full;coh_full2=[];
for i= 1:Ngroup
    coh_full2{i,1} = coh_surrogate_avg;
end
for i= 1:Ngroup
%     coh_full1{i}.cohspctrm = atanh(coh_full1{i}.cohspctrm) - atanh(coh_full2{i}.cohspctrm);
%     coh_full2{i}.cohspctrm(:) = 0; %this is done for 5 subjects separately
    coh_full1{i}.label = fb;
    coh_full2{i}.label = fb;
end

cfg = [];
% cfg.latency          = 'all';
% cfg.frequency        = [25 35]; % this will be performed for different frequency bands
cfg.method    = 'analytic';
cfg.correctm  = 'fdr';
cfg.statistic = 'indepsamplesT';


% 
% cfg.correctm         = 'cluster';
% cfg.clusteralpha     = 0.05;
% cfg.clusterstatistic = 'maxsum';
% cfg.minnbchan        = 2;
% % cfg.neighbourdist    = 1;
% cfg.tail             = 0;
% cfg.clustertail      = 0;
% cfg.alpha            = 0.025;
% cfg.correcttail      = 'prob';  % 'prob''alpha'
% cfg.numrandomization = 500;
% % specifies with which sensors other sensors can form clusters
% cfg.neighbours       = neighbours;


cfg.parameter   = 'cohspctrm';
cfg.channel          = fb;

design = zeros(2,2*Ngroup);
for i = 1:Ngroup
    design(1,i) = i;
end
for i = 1:Ngroup
    design(1,Ngroup+i) = i;
end
design(2,1:Ngroup)        = 1;
design(2,Ngroup+1:2*Ngroup) = 2;

% design = design(:,1:8);

cfg.design   = design;
% cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_freqstatistics(cfg,coh_full1{1},coh_full2{1});





a = 'L-CP5';


stat.channelcmb = [coh_full{1,1}.labelcmb(:,1),coh_full{1,1}.labelcmb(:,2)];
b = find(ismember(stat.channelcmb(:,1),a));

A = stat;

A.stat = stat.stat(b,:,:);
A.prob = stat.prob(b,:,:);
A.mask = stat.mask(b,:,:);
A.label = stat.label(b,:,:);
A.label = cellfun(@(x) x(8:end), A.label(:,1), 'un', 0);


cfg               = [];
cfg.marker        = 'off';
cfg.layout        = 'biosemi64.lay';
cfg.parameter     = 'stat';  % plot the t-value
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'saturation';
% cfg.xlim = [0.2 0.9]; % Specify the time range to plot
% cfg.zlim = [-3 3]; % Specify the time range to plot
cfg.box              = 'yes';
cfg.colorbar         = 'yes';
cfg.showlabels       = 'yes';
% cfg.comment       = condition_comb{:};

figure; ft_multiplotTFR(cfg, A);




