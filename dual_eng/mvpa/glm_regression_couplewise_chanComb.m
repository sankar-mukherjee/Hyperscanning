
load([project.paths.processedData '/mvpa/prespeech_tfr.mat']);
load([project.paths.processedData '/coherence/surrogate_trial.mat'],'index_comb');
load([project.paths.processedData '/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');

gmmScores = sum(gmmScores,2);


%% channel combination
 
[A,B] = meshgrid(1:64,1:64);
i=cat(2,A',B');
ch_comb =reshape(i,[],2);


%% glm

coeff_len = 2;

glm_coeff = zeros(coeff_len,8,length(ch_comb),40,21); 

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
            B.powspctrm = zeros(size(s,1),64,40,21);
            C.powspctrm=zeros(size(s,1),64,40,21);
            for i=1:size(s,1)
                A = find(ismember(a.trialinfo(:,2),s(i,1)));
                B.powspctrm(i,:,:,:) = a.powspctrm(A,:,:,:);
                
                A = find(ismember(b.trialinfo(:,2),s(i,2)));
                C.powspctrm(i,:,:,:) = b.powspctrm(A,:,:,:);
            end
            
            parfor ch=1:length(ch_comb)
                for f=1:40
                    for t=1:21
                         a = B.powspctrm(:,ch_comb(ch,1),f,t);
                        b = C.powspctrm(:,ch_comb(ch,2),f,t);

                        [b,dev,stats] = glmfit([a b],llr_diff);
                        glm_coeff(:,g,ch,f,t) = b(2:end);
                    end
                end
            end
            
        end
    end    
    disp(g)
    g=g+1;
end

save('couplewise_GLMcoeff_chanComb','glm_coeff');


%% ttest
signifincat = nan(length(ch_comb),40,21);
mask = zeros(length(ch_comb),40,21);

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

[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(signifincat,0.05,'pdep','yes');




for ch=1:length(ch_comb)
    A = signifincat(8,10:15,:);
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','yes');
    disp(ch)
end



[ch,f,t] = ind2sub(size(h),find(h==1));









