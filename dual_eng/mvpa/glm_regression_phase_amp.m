
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\mvpa\prespeech_tfr_phase.mat');
tframp = load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\mvpa\prespeech_tfr.mat');
load(['C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');

gmmScores = sum(gmmScores,2);


%% glm
glm_coeff1 = zeros(16,64,40,21);  %amp
glm_coeff2 = zeros(16,64,40,21); %sine phase
glm_coeff3 = zeros(16,64,40,21); %cos phase

for sub=1:16
    A = prespeechTFR{sub,1};
    B = tframp.prespeechTFR{sub,1};
    s = A.trialinfo(:,2);
    llr = gmmScores(s);
    parfor ch=1:64
        for f=1:40
            for t=1:21
                a = angle(A.fourierspctrm(:,ch,f,t));
                
                a1 = sin(a); a2 = cos(a);
                
                a = B.powspctrm(:,ch,f,t);
                
                [b,dev,stats] = glmfit([a a1 a2],llr);
                glm_coeff1(sub,ch,f,t) = b(2);
                glm_coeff2(sub,ch,f,t) = b(3);
                glm_coeff3(sub,ch,f,t) = b(4);
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
            a = squeeze(glm_coeff1(:,ch,f,t));
            a1 = squeeze(glm_coeff2(:,ch,f,t));
            a2 = squeeze(glm_coeff3(:,ch,f,t));
            
            p = T2Hot1([a a1 a2]);
            
            signifincat(ch,f,t) = p;
            if(p<=0.05)
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
    A = squeeze(signifincat(15,:,:));
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','yes');
    disp(ch)
end



[f,t] = ind2sub(size(h),find(h==1));
    
    
    
    
    
    
    
    
    
    
    
    
    