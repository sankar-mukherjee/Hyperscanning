
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\mvpa\prespeech_tfr_phase.mat');
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\surrogate_trial.mat','index_comb');
load(['C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');

gmmScores = sum(gmmScores,2);

%% glm
coeff_len = 4;

glm_coeff = zeros(coeff_len,8,64,40,21); 

g=1;
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
            B.fourierspctrm = zeros(size(s,1),64,40,21);
            C.fourierspctrm=zeros(size(s,1),64,40,21);
            for i=1:size(s,1)
                A = find(ismember(a.trialinfo(:,2),s(i,1)));
                B.fourierspctrm(i,:,:,:) = a.fourierspctrm(A,:,:,:);
                
                A = find(ismember(b.trialinfo(:,2),s(i,2)));
                C.fourierspctrm(i,:,:,:) = b.fourierspctrm(A,:,:,:);
            end
            
            for ch=1:64
                for f=1:40
                    for t=1:21
                         a = angle(B.fourierspctrm(:,ch,f,t));
                        b = angle(C.fourierspctrm(:,ch,f,t));
                        
                        a1 = sin(a); 
                        a2 = cos(a);
                        b1 = sin(b); 
                        b2 = cos(b);
                        
                        [b,dev,stats] = glmfit([a1 a2 b1 b2],llr_diff);
                        glm_coeff(:,g,ch,f,t) = b(2:end);                        
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
          a = [];
            for c =1:coeff_len
                a = [a squeeze(glm_coeff(c,:,ch,f,t))'];     
            end
            p = T2Hot1(a);     
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
    A = signifincat(ch,:,:);
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','yes');
end



[ch,f,t] = ind2sub(size(h),find(h==1));




%% plot effect size
effect = nan(64,40,21);
for ch=1:64
    for f=1:40
        for t=1:21
            a =  squeeze(glm_coeff(:,:,ch,f,t))';
            b = mean(a);
            a = 0;
            for i=1:length(b)
                a = a+b(i)^2;
            end
            effect(ch,f,t) = sqrt(a);
        end
    end
end

mask = zeros(40,21);
for f=1:40
    for t=1:21
        mask(f,t) =  mean(effect(:,f,t));        
    end
end

freqLimt=5;

time = prespeechTFR{1,1}.time;
A = mask(freqLimt:25,:);
figure;imagesc(flipud(A));
set(get(gca,'YLabel'),'String','Freq');
set(get(gca,'XLabel'),'String','Time')
set(gca,'yTick',1:2:40-freqLimt);
set(gca,'YTickLabel',fliplr([freqLimt:2:40]));
set(gca,'xTick',1:2:21);
set(gca,'XTickLabel',round(time(1:2:end),2));
title('subject phase-amp')







