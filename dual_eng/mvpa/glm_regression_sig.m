channel_avg = {{'F5' 'F7' 'FT7' 'FC5'};{'AF8' 'F6' 'F8' 'FT8' 'FC6'};{'C4' 'C6' 'CP6' 'CP4'};{'POz' 'P2' 'P4' 'PO4'}};
channel_no  = 4;

load(['C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\mvpa\prespeech_tfr_sig.mat');

gmmScores = sum(gmmScores,2);



%% glm
glm_coeff = zeros(16,channel_no,40,21);
for sub=1:16    
    A = prespeechTFR{sub,1};
    s = A.trialinfo(:,2);
    llr = gmmScores(s);    
    for ch=1:channel_no
        for f=1:40
            for t=1:21                
                a = A.powspctrm(:,ch,f,t);
                [b,dev,stats] = glmfit(a,llr);
                glm_coeff(sub,ch,f,t) = b(2);
            end
        end        
    end
    disp(sub)
end

%% ttest
signifincat = nan(channel_no,40,21);
mask = zeros(channel_no,40,21);

for ch=1:channel_no
    for f=1:40
        for t=1:21
            a = squeeze(glm_coeff(:,ch,f,t));
            [h,p] = ttest(a);
            if(h==1)
                signifincat(ch,f,t) = p;
                mask(ch,f,t) = 1;
            end
        end
    end
end



freqLimt=0;
time = prespeechTFR{1,1}.time;


figure;
for ch=1:channel_no
    A = squeeze(signifincat(ch,:,:));
    subplot(2,2,ch)
    imagesc(flipud(A));
    set(get(gca,'YLabel'),'String','Freq');
    set(get(gca,'XLabel'),'String','Time')
    set(gca,'yTick',1:5:40-freqLimt);
    set(gca,'YTickLabel',fliplr([freqLimt:5:40]));
    set(gca,'xTick',1:5:21);
    set(gca,'XTickLabel',round(time(1:5:end),2));
    title(channel_avg{ch});
end




[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(signifincat,0.05,'pdep','yes');

for ch=1:channel_no
    A = squeeze(signifincat(ch,:,:));
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','yes');
%     disp(ch)
end











    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    