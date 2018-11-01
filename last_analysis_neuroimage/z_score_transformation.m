function Z = z_score_transformation(data)
% 
% X = data.powspctrm;
% for ch=1:size(data.powspctrm,2)
%     for f=1:size(data.powspctrm,3)
%         for t=1:size(data.powspctrm,4)
%             X(:,ch,f,t) = zscore(data.powspctrm(:,ch,f,t));
%         end
%     end
% end
% 
% 
% Z = data;
% Z.powspctrm=X;


ntrl = length(data.trial);
%---zscore
zwindow = [-inf inf];
sumval  = 0;
sumsqr  = 0;
numsmp  = 0;
trlindx = [];
for k = 1:ntrl
    begsmp = nearest(data.time{k}, zwindow(1));
    endsmp = nearest(data.time{k}, zwindow(2));
    if endsmp>=begsmp
        sumval  = sumval + sum(data.trial{k}(:, begsmp:endsmp),    2);
        sumsqr  = sumsqr + sum(data.trial{k}(:, begsmp:endsmp).^2, 2);
        numsmp  = numsmp + endsmp - begsmp + 1;
        trlindx = [trlindx; k];
    end
end
datavg = sumval./numsmp;
datstd = sqrt(sumsqr./numsmp - (sumval./numsmp).^2);

data.trial = data.trial(trlindx);
data.time  = data.time(trlindx);
ntrl       = length(trlindx);
for k = 1:ntrl
    rvec          = ones(1,size(data.trial{k},2));
    data.trial{k} = (data.trial{k} - datavg*rvec)./(datstd*rvec);
end

Z = data;
end