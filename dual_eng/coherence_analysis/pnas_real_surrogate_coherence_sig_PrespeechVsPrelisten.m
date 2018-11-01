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

r=cell(7,1);
for g=1:7
    A = squeeze(coh_prob(g,:,:,:));
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','yes');
    [ch,f,t] = ind2sub(size(h),find(h==1));
%     r{g,1} = [ch_comb.sig(ch,:) num2cell(freq(f)') num2cell(time(t)')];
%     r{g,1} = [ch freq(f)' time(t)'];
    r{g,1} = [ch f t];

end

seleted_comb=1;freqLimt=5;
AA = nan(length(freq),length(time));
figure;
for g=1:7
    a = r{g,1};
    a = a(find(a(:,1)==seleted_comb),:);
    A = squeeze(coh_prob(g,seleted_comb,:,:));
    B = AA;
    B(a(:,2),a(:,3)) = 1./A(a(:,2),a(:,3));
    B = B(freqLimt:end,:);
    subplot(2,4,g)
    imagesc(flipud(B));
    set(get(gca,'YLabel'),'String','Freq');
    set(get(gca,'XLabel'),'String','Time')
    set(gca,'yTick',1:5:40-freqLimt);
    set(gca,'YTickLabel',fliplr([freqLimt:5:40]));
%     set(gca,'XTickLabel',[num2str(round(time([5 10 15 20]),2))]);
    title(num2str(g))
    caxis([100 inf]);
end


%% plot coherence
load([project.paths.processedData '/coherence/coh_real_sig_Prespeech_PostListen.mat'])

b= [1 2 4 5 6 7 8];
seleted_comb=1;freqLimt=5;
figure;
for g=1:8
    a = coh_full{g,1};
    A = squeeze(a.cohspctrm(seleted_comb,:,:));
    A = A(freqLimt:end,:);
    subplot(2,4,g)
    imagesc(flipud(A));
    set(get(gca,'YLabel'),'String','Freq');
    set(get(gca,'XLabel'),'String','Time')
    set(gca,'yTick',1:5:40-freqLimt);
    set(gca,'YTickLabel',fliplr([freqLimt:5:40]));
    %     set(gca,'XTickLabel',[num2str(round(time([5 10 15 20]),2))]);
    title(num2str(b(g)))
    caxis([0 0.2]);
end
      
            













            