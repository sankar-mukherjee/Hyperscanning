%% test to see if the real pair has singnificanct coherence than the fake ones using this paper
%{
Information flow between interacting human brains:Identification, validation, and relationship to social expertise

For the discovery sample, the reference distribution of nonpairs was created by 1,000 repetitions of the artificial sender/receiver pair assignments.
During each repetition, a random sample of 16 nonpairs (=^ 13 × 2 real pairs) was drawn from the distribution of permutated nonpairs, and lag estimation
was conducted as described above. For the replication sample, permutation
was repeated 10,000 times, and random samples of 50 nonpairs (=^ 25 ×
2 real pairs) were drawn. Next, the frequency of correlationNON-PAIRS >
correlationREAL PAIRS was determined (i.e., the ratio of (i) the number of cases
in which real pairs did not show higher neural coupling than nonpairs and
(ii) the number of total observations, i.e., 1,000 or 10,000). This frequency
represents the empirical P value testing whether neural coupling occurred
that is unique to real pairs. To determine the time window of neural
coupling, this procedure was repeated for every lag within the COI pair
until no significant difference of coupling indices between real pairs and

%}

%% detail analysis of the significant coherent channel real vs surogate pair
load([project.paths.processedData '/coherence/channel_combination.mat'])
load([project.paths.processedData '/coherence/coh_prob_real_surrogate_sig_wholeEXP.mat'])

A = squeeze(coh_prob);
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','yes');
[ch,f,t] = ind2sub(size(h),find(h==1));
r= [ch_comb.sig(ch,:) num2cell(freq(f)') num2cell(time(t)')];
%     r{g,1} = [ch freq(f)' time(t)'];
r= [ch f t];


% b=round(time,2);
% seleted_comb=1;freqLimt=5;
% AA = nan(length(freq),length(time));
% figure;
% for g=1:8
%     a = r{g,1};
%     a = a(find(a(:,1)==seleted_comb),:);
%     A = squeeze(coh_prob(g,seleted_comb,:,:));
%     B = AA;
%     B(a(:,2),a(:,3)) = 1./A(a(:,2),a(:,3));
%     B = B(freqLimt:end,:);
%     subplot(2,4,g)
%     imagesc(flipud(B));
%     set(get(gca,'YLabel'),'String','Freq');
%     set(get(gca,'XLabel'),'String','Time')
%     set(gca,'yTick',1:5:40-freqLimt);
%     set(gca,'YTickLabel',fliplr([freqLimt:5:40]));
%     set(gca,'xTick',0:5:21);
%     set(gca,'XTickLabel',b);
%     title(num2str(g))
%     caxis([100 inf]);
% end


%% plot coherence
load([project.paths.processedData '/coherence/coh_real_sig.mat'])

seleted_comb=1;freqLimt=5;
figure;
A = squeeze(a.cohspctrm(seleted_comb,:,:));
A = A(freqLimt:end,:);
imagesc(flipud(A));
set(get(gca,'YLabel'),'String','Freq');
set(get(gca,'XLabel'),'String','Time')
set(gca,'yTick',1:5:40-freqLimt);
set(gca,'YTickLabel',fliplr([freqLimt:5:40]));
set(gca,'xTick',1:2:21);
set(gca,'XTickLabel',round(time(1:2:end),2));

      
 %% singnificant connection (non parametric)
 fb = strcat(coh_full{1,1}.labelcmb(:,1),coh_full{1,1}.labelcmb(:,2));

Ngroup = 8;
coh_conv_pair1 = coh_full;
coh_noch_pair2 = coh_full;
for i= 1:Ngroup
    coh_conv_pair1{i}.cohspctrm = atanh(coh_full{i}.cohspctrm);
    coh_noch_pair2{i}.cohspctrm(:) = 0; %this is done for 5 subjects separately
    coh_conv_pair1{i}.label = fb;
    coh_noch_pair2{i}.label = fb;
end
% 
% cfg = [];
% cfg.method    = 'triangulation';
% neighbours       = ft_neighbourplot(cfg, prespeech{1});

cfg = [];
cfg.latency          = 'all';
cfg.frequency        = [2 4]; % this will be performed for different frequency bands
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
% cfg.neighbourdist    = 1;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.correcttail      = 'prob';  % 'prob''alpha'
cfg.numrandomization = 2500;
% specifies with which sensors other sensors can form clusters
cfg.neighbours       = neighbours;
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

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_freqstatistics(cfg,coh_conv_pair1{:},coh_noch_pair2{:});           













            