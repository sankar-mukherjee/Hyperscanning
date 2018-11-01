load(['C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');

gmmScores = sum(gmmScores,2);

%% glm
glm_coeff = zeros(16,4,21);
for sub=1:16
    A = prespeechTFR{sub,1};
    
    cfg           = [];
    cfg.frequency     = [11 30];
    cfg.avgoverfreq = 'yes';
    cfg.channel     =  {'F5','F7','FT7','FC5'};
    A = ft_selectdata(cfg,A);
    
    s = A.trialinfo(:,2);
    llr = gmmScores(s);
    
    for ch=1:4
        for t=1:21
            a = squeeze(A.powspctrm(:,ch,1,t));
            [b,dev,stats] = glmfit(a,llr);
            glm_coeff(sub,ch,t) = b(2);
        end
    end
end


%% ttest
signifincat = nan(4,21);
mask = zeros(4,21);

for ch=1:4    
    for t=1:21
        a = squeeze(glm_coeff(:,ch,t));
        p = T2Hot1(a);
        
        signifincat(ch,t) = p;
        if(p<=0.05)
            mask(ch,t) = 1;
        end
    end
end


for ch=1:4
    A = squeeze(signifincat(ch,:));
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','yes');
%     disp(ch)
end



freqLimt=0;
time = prespeechTFR{1,1}.time;


figure;
for ch=1:4
    A = squeeze(signifincat(ch,:));
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


set(gca,'yTick',1:4);
set(gca,'YTickLabel',{'F5','F7','FT7','FC5'});
title('12 14hz significant beta regression coeff');
title('12 14hz p values beta regression coeff');







%%  %%
glm_coeff = zeros(16,4,21);
for sub=1:16
    A = prespeechTFR{sub,1};
    
    cfg           = [];
    cfg.frequency     = [10 15];
    cfg.avgoverfreq = 'yes';
    cfg.channel     =  {'F5','F7','FT7','FC5'};
    A = ft_selectdata(cfg,A);
    
    s = A.trialinfo(:,2);
    llr = gmmScores(s);
    
    for t=1:21
        a=[];
        for ch=1:4
            a = [a squeeze(A.powspctrm(:,ch,1,t))];
        end
        [b,dev,stats] = glmfit(a,llr);
        glm_coeff(sub,:,t) = b(2:end);
    end
end


%% ttest
signifincat = nan(21,1);
mask = zeros(21,1);


for t=1:21
    a = squeeze(glm_coeff(:,:,t));
    p = T2Hot1(a);
    
    signifincat(t,1) = p;
    if(p<=0.05)
        mask(t,1) = 1;
    end
end








































