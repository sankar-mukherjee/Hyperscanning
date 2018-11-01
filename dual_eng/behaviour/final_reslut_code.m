load([project.paths.processedData '/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');
gmmScores = sum(gmmScores,2);

load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\surrogate_trial.mat','index_comb');
load([project.paths.processedData '/processed_data_word_level.mat'],'D');
load([project.paths.processedData '/convergence/convergence_' num2str(project.gmmUBM.gmmcomp) '_new_versioncode.mat'],'convergence_data','TH');
load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\SPIC_text.mat', 'Oindex_comb');


%% joint task 
%%CC vs LLRDiff   all together

corealtion = [];corealtion_std=[];
for sub=1:2:16
    i = Oindex_comb(find(Oindex_comb(:,5)==sub),:);
    for s=1:4
        A = i(find(i(:,4)==s),:);        
        %
        j = [A(find(A(:,3)==1),:); A(find(A(:,3)==2),:)];
        
        [a,b] = corr(D(j(:,1),4), D(j(:,2),4));
        [c,d] = corr(D(j(:,1),5), D(j(:,2),5));
        [e,f] = corr(D(j(:,1),6), D(j(:,2),6));
        [g,h] = corr(D(j(:,1),10), D(j(:,2),10));
        [k,l] = corr(D(j(:,1),11), D(j(:,2),11));

        [ii,jj] = corr(D(j(:,1),14), D(j(:,2),14));
        
        LLR = mean([gmmScores(A(:,1)) - gmmScores(A(:,2))]);
        LLR1 = std([gmmScores(A(:,1)) - gmmScores(A(:,2))]);
        
        corealtion = [corealtion;   LLR a c e g k ii];
        corealtion_std = [corealtion_std; LLR1  b d f h l jj];       
        
    end
end

%%
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\convergence\GMM_speech_conv_spy_32_10_mwv_mfc.mat')
% convergence
a = GMM_conv.convergence .* GMM_conv.rare_event;
A = [];
for s=1:8
j=1;
    for i=1:4
        A = [A; length(find(a(s,j:j+98)))];
        j=j+98;
    end
end

R = [];
for i=1:7
    [r,p] = corr(A(:,1),corealtion(:,i),'rows','complete');
    R = [R; r p];
end

% gender effect
a = find(ismember(project.subjects.gender,'m'));
a = find(ismember(project.subjects.gender,'f'));

R = [];
for i=1:7
    C = reshape(corealtion(:,i),4,8);
    C = C(:,a);
    CC = reshape(A(:,1),4,8);
    CC = CC(:,a);
    
    [r,p] = corr(C(:),CC(:),'rows','complete');
    R = [R; r p];
end

figure;

scatter(A(:,1),corealtion(:,2),'k','filled')
xlabel(gca,'No of Convergence')
ylabel(gca,'CC')
set(gca,'xlim',[-3 20])
set(gca,'ylim',[-0.7 0.7])

title('F0 vs No of Convergence')


figure;

scatter(A(:,1),corealtion(:,5),'filled')
xlabel(gca,'No of Convergence')
ylabel(gca,'CC')
set(gca,'xlim',[-3 20])
set(gca,'ylim',[-0.4 0.7])
title('Intensity vs No of Convergence')




%% conv nochange


load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\coherence_analysis\idx.mat')
         

sub = D(conv_idx,1);
[a,b]=hist(sub,unique(sub));
A=[a' b];

a = find(ismember(project.subjects.gender,'f'));
b = find(ismember(sub,a));
conv_idx(b) = [];noCh_idx(b)=[];

f0 = [mean(D(conv_idx,4)) mean(D(noCh_idx,4))];
f0_std = [std(D(conv_idx,4)) std(D(noCh_idx,4))];

bar(f0);hold on
errorbar(f0,f0_std,'.')
A = [D(conv_idx,4)' D(noCh_idx,4)'];
B = [zeros(1,length(D(conv_idx,4))) ones(1,length(D(noCh_idx,4)))];
boxplot(A,B)

intensity = [mean(D(conv_idx,10)) mean(D(noCh_idx,10))];
intensity_std = [std(D(conv_idx,10)) std(D(noCh_idx,10))];

bar(intensity);hold on
errorbar(intensity,intensity_std,'.')

dur= [mean(D(conv_idx,11)) mean(D(noCh_idx,11))];
dur_std= [std(D(conv_idx,11)) std(D(noCh_idx,11))];

bar(dur);hold on
errorbar(dur,dur_std,'.')

RT = [mean(D(conv_idx,14)) mean(D(noCh_idx,14))];
RT_std = [std(D(conv_idx,14)) std(D(noCh_idx,14))];

bar(RT);hold on
errorbar(RT,RT_std,'.')


[h,p] = ttest2(D(conv_idx,4),D(noCh_idx,4))
[h,p] = ttest2(D(conv_idx,10),D(noCh_idx,10))
[h,p] = ttest2(D(conv_idx,11),D(noCh_idx,11))
[h,p] = ttest2(D(conv_idx,14),D(noCh_idx,14))



[p,h, stats] = ranksum(D(conv_idx,4),D(noCh_idx,4))
[p,h, stats] = ranksum(D(conv_idx,10),D(noCh_idx,10))
[p,h, stats] = ranksum(D(conv_idx,11),D(noCh_idx,11))
[p,h, stats] = ranksum(D(conv_idx,14),D(noCh_idx,14))



% gender converge more
sub = D(conv_idx,1);
[a,b]=hist(sub,unique(sub));
A=[a' b];

sum(A(project.subjects.male,1))
sum(A(project.subjects.female,1))





