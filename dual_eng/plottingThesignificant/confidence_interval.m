function [C_mean,CI] = confidence_interval(tf,freq,time,channel,th,cell)

if(cell)
    ch_idx = find(ismember(tf{1}.label,channel));
    
    C =[];
    i=1;
    for sub = 1:size(tf,2)
        a = tf{sub};
        
%         cfg           = [];
%         cfg.parameter = 'powspctrm';
%         cfg.operation = 'log10';
%         a    = ft_math(cfg, a);
        
        C{i,1} = a.powspctrm(:,ch_idx,freq,time);
        i =i+1;
    end
    
    a = cell2mat(C);
else
    ch_idx = find(ismember(tf.label,channel));
    a = tf.powspctrm(:,ch_idx,freq,time);
end

C_mean = squeeze(mean(mean(a,2),3));
CI = zeros(2,size(C_mean,2));

for i=1:size(C_mean,2)
    x = C_mean(:,i);
    SEM = std(x)/sqrt(length(x));               % Standard Error
    %     ts = tinv([th  th],length(x)-1);      % T-Score
    %     CI(:,i) = mean(x) + ts*SEM;
    %     CI(1,i) = mean(x) + th*SEM;
    %     CI(2,i) = mean(x) - th*SEM;
    CI(:,i) = SEM;
    
end

C_mean = mean(squeeze(mean(mean(a,2),3)));


end