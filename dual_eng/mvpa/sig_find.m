function [ff]=sig_find(signifincat,freq,prespeechTFR,var)

if(var==1)
    ff=[];
    F = prespeechTFR{1,1}.freq(freq(1):freq(2));
    T = prespeechTFR{1,1}.time;
    A = squeeze(signifincat(:,freq(1):freq(2),:));
    [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','no');
    if not(length(find(h==1))==0)
        [ch,f,t] = ind2sub(size(h),find(h==1));
        t = T(t);
        f = F(f);
        %         disp([cell2mat(prespeechTFR{1,1}.label(ch)) ',' num2str(f) ',' num2str(t) ',' num2str(freq)])
        
        for j=1:length(t)
            ff = [ff; ch(j) f(j) t(j) freq];
        end
        %         ff{i,1} = [prespeechTFR{1,1}.label(ch) num2str(f) num2str(t) num2str(freq)];
    end
    
elseif(var ==2)
    
    ff=[];
    F = prespeechTFR{1,1}.freq(freq(1):freq(2));
    T = prespeechTFR{1,1}.time;
    for ch=1:64
        A = squeeze(signifincat(ch,freq(1):freq(2),:));
        [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','no');
        if not(length(find(h==1))==0)
            [f,t] = ind2sub(size(h),find(h==1));
            t = T(t);
            f = F(f);
            %         disp([cell2mat(prespeechTFR{1,1}.label(ch)) ',' num2str(f) ',' num2str(t) ',' num2str(freq)])
            
            for j=1:length(t)
                ff = [ff; ch f(j) t(j) freq];
            end
            %         ff{i,1} = [prespeechTFR{1,1}.label(ch) num2str(f) num2str(t) num2str(freq)];
        end
    end
    
elseif(var==3)
    
    ff=[];
    F = prespeechTFR{1,1}.freq(freq(1):freq(2));
    T = prespeechTFR{1,1}.time;
    for t=1:21
        A = squeeze(signifincat(:,freq(1):freq(2),t));
        [h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(A,0.05,'pdep','no');
        if not(length(find(h==1))==0)
            [ch,f] = ind2sub(size(h),find(h==1));
            
            f = F(f);
            %         disp([cell2mat(prespeechTFR{1,1}.label(ch)) ',' num2str(f) ',' num2str(t) ',' num2str(freq)])
            
            for j=1:length(ch)
                ff = [ff; ch(j) f(j) T(t) freq];
            end
            %         ff{i,1} = [prespeechTFR{1,1}.label(ch) num2str(f) num2str(t) num2str(freq)];
        end
    end
    
    
    
    
    
    
    
    
    
end











end