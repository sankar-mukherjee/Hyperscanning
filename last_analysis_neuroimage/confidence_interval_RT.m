function [R,P,C_mean,RT] = confidence_interval_RT(D,tf,freq,time,channel,idx)

    ch_idx = find(ismember(tf{1}.label,channel));
    time = find(tf{1}.time>=time(1) & tf{1}.time<=time(2));
    freq = freq(1):freq(2);
    C =[];
    RT = [];
    i=1;
    for sub = 1:size(tf,2)
        a = tf{sub};
        
        id = find(ismember(a.trialinfo(:,2),idx));
        
        C{i,1} = a.powspctrm(id,ch_idx,freq,time);
        
        RT{i,1} = D(a.trialinfo(id,2),14);

        i =i+1;
    end
    
    a = cell2mat(C);
    RT =  cell2mat(RT);


C_mean = squeeze(mean(mean(mean(a,2),3),4));
% CI = zeros(2,size(C_mean,2));
% 
% for i=1:size(C_mean,2)
%     x = C_mean(:,i);
%     SEM = std(x)/sqrt(length(x));               % Standard Error
%     %     ts = tinv([th  th],length(x)-1);      % T-Score
%     %     CI(:,i) = mean(x) + ts*SEM;
%     %     CI(1,i) = mean(x) + th*SEM;
%     %     CI(2,i) = mean(x) - th*SEM;
%     CI(:,i) = SEM;
%     
% end

[R,P] = corrcoef(C_mean,RT);
R = R(1,2);P=P(1,2);

end