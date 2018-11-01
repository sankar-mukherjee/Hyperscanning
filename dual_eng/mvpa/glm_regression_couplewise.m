
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\mvpa\prespeech_tfr.mat');
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\surrogate_trial.mat','index_comb');
load(['C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');

gmmScores = sum(gmmScores,2);

%% glm
glm_coeff = zeros(8,64,40,21);g=1;
for sub=1:2:16
    s = index_comb(find(ismember(index_comb(:,5),sub) & ismember(index_comb(:,6),sub+1)),:);
    if not(isempty(s))
        %% condition combination
        a = [prespeechTFR{sub,1}.trialinfo(:,2)];
        A = ismember(s(:,1),a);
        b = [prespeechTFR{sub+1,1}.trialinfo(:,2)];
        B = ismember(s(:,2),b);
        A = find(A.*B);
        s = s(A,:);
        
        if not(isempty(s))            
            llr_diff = gmmScores(s(:,1)) - gmmScores(s(:,2));           
            a = prespeechTFR{sub,1};    b = prespeechTFR{sub+1,1};
            
            
            B=[];C=[];
            B.powspctrm = zeros(size(s,1),64,40,21);
            C.powspctrm=zeros(size(s,1),64,40,21);
            for i=1:size(s,1)
                A = find(ismember(a.trialinfo(:,2),s(i,1)));
                B.powspctrm(i,:,:,:) = a.powspctrm(A,:,:,:);
                
                A = find(ismember(b.trialinfo(:,2),s(i,2)));
                C.powspctrm(i,:,:,:) = b.powspctrm(A,:,:,:);
            end
            
            for ch=1:64
                for f=1:40
                    for t=1:21
                        a = B.powspctrm(:,ch,f,t);
                        b = C.powspctrm(:,ch,f,t);
                        a = mean([a b],2);
                        [b,dev,stats] = glmfit(a,llr_diff);
                        glm_coeff(g,ch,f,t) = b(2);
                    end
                end
            end
            
        end
    end    
    disp(g)
    g=g+1;
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
A = signifincat(8,10:15,:);
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','yes');
end



[ch,f,t] = ind2sub(size(h),find(h==1));









