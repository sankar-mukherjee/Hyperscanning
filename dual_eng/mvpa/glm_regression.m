
load(['C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\mvpa\prespeech_tfr.mat');

gmmScores = sum(gmmScores,2);

%% glm
glm_coeff = zeros(16,64,40,21);
for sub=1:16    
    A = prespeechTFR{sub,1};
    s = A.trialinfo(:,2);
    llr = gmmScores(s);    
    parfor ch=1:64
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
signifincat = nan(64,40,21);
mask = zeros(64,40,21);

for ch=1:64
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

A = [];
A.stat = signifincat;
A.mask = logical(mask);
A.freq = prespeechTFR{sub,1}.freq;
A.label = prespeechTFR{sub,1}.label;
A.time = prespeechTFR{sub,1}.time;
A.dimord = 'chan_freq_time';

cfg               = [];
cfg.marker        = 'off';
cfg.layout        = 'biosemi64.lay';
cfg.parameter     = 'stat';  % plot the t-value
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'saturation';
cfg.showlabels       = 'yes';
figure;ft_multiplotTFR(cfg, A);




[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(signifincat,0.05,'pdep','yes');

for ch=1:64
    A = squeeze(signifincat(ch,:,:));
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','yes');
%     disp(ch)
end











    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    