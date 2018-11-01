function [conv_mean,noch_mean,CI] = confidence_interval2(conv_tf,noch_tf,freq,time,channel,th,cell)

if(cell)
    ch_idx = find(ismember(conv_tf{1}.label,channel));
    
    C =[];
    i=1;
    for sub = 1:size(conv_tf,2)
        a = conv_tf{sub};
        C{i,1} = a.powspctrm(:,ch_idx,freq,time);
        i =i+1;
    end    
    a = cell2mat(C);
    
    N =[];
    i=1;
    for sub = 1:size(noch_tf,2)
        b = noch_tf{sub};
        N{i,1} = b.powspctrm(:,ch_idx,freq,time);
        i =i+1;
    end    
    b = cell2mat(N);
    
else
    ch_idx = find(ismember(conv_tf.label,channel));
    a = conv_tf.powspctrm(:,ch_idx,freq,time);
end

conv_mean = squeeze(mean(mean(a,2),3));
noch_mean = squeeze(mean(mean(b,2),3));

CI = zeros(2,size(conv_mean,2));

for i=1:size(conv_mean,2)
%     x = C_mean(:,i);
%     SEM = std(x)/sqrt(length(x));               % Standard Error
%     ts = tinv([th  th],length(x)-1);      % T-Score
%     CI(:,i) = mean(x) + ts*SEM;
    [~,~,CI(:,i),~] = ttest2(conv_mean(:,i),noch_mean(:,i));

end

conv_mean = mean(conv_mean);
noch_mean = mean(noch_mean);


end