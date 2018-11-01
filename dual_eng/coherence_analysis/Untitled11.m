


load([project.paths.processedData '/coherence/coh_real_sig.mat'])


seleted_comb=1;freqLimt=[18 35] ;

A = [];
for g=1:8
    A = [A;squeeze(mean(coh_full{g}.cohspctrm(seleted_comb,freqLimt(1):freqLimt(2),:)))'];
end
errorbar(mean(A),std(A))
set(gca,'xTick',1:21);
set(gca,'XTickLabel',round(time,2));
xlim ([0 22])
title(num2str(freqLimt))

%% detail analysis of the significant coherent channel real vs surogate pair
load([project.paths.processedData '/coherence/channel_combination.mat'])
load([project.paths.processedData '/coherence/coh_prob_real_surrogate_sig.mat'])

r=cell(8,1);
for g=1:8
    A = squeeze(coh_prob(g,:,:,:));
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','yes');
    [ch,f,t] = ind2sub(size(h),find(h==1));
%     r{g,1} = [ch_comb.sig(ch,:) num2cell(freq(f)') num2cell(time(t)')];
%     r{g,1} = [ch freq(f)' time(t)'];
    r{g,1} = [ch f t];

end

C = zeros(8,36,21);
b=round(time,2);
seleted_comb=1;freqLimt=5;
AA = nan(length(freq),length(time));
figure;
for g=1:8
    a = r{g,1};
    a = a(find(a(:,1)==seleted_comb),:);
    A = squeeze(coh_prob(g,seleted_comb,:,:));
    B = AA;
    B(a(:,2),a(:,3)) = A(a(:,2),a(:,3));
    B = B(freqLimt:end,:);
    C(g,:,:) = B;
end
A = squeeze(mean(C,1));
% A = 1./A;
imagesc(flipud(A));
set(gca,'yTick',1:5:40-freqLimt);
set(gca,'YTickLabel',fliplr([freqLimt:5:40]));
set(gca,'xTick',1:2:21);
set(gca,'XTickLabel',round(time(1:2:end),2));





