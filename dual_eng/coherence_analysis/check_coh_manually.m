

coh_full = coh_conv_pair;
coh_full = coh_noch_pair;

for i= 1:8
    coh_full{i}.cohspctrm = atanh(coh_conv_pair{i}.cohspctrm) - atanh(coh_noch_pair{i}.cohspctrm);
end

a=[];
for g=1:8
    [a{g,1},a{g,2},a{g,3}]  = ind2sub(size(coh_full{g,1}.cohspctrm),find(coh_full{g,1}.cohspctrm > 0.5));
    
end

d = coh_full{g,1}.labelcmb;
t = coh_full{g,1}.time;

freq = [11 30];
A = [];

for g=1:8
    b = cell2mat(a(g,:));
    if not(isempty(b))
        
        c = find(b(:,2)>=freq(1) & b(:,2)<=freq(2));
        if not(isempty(c))
            A{g,1} = d(b(c,1),:);
            A{g,2} = t(b(c,3))';

        end
    end
end

% check which freq present
c = cell2mat(a(:,2));
unique(c)





% plot topo map compared to SPeakers elctrode to others

g=4;comb=1;

b = A{g,1}(comb);

c = coh_full{g,1};
% b='S-FC5';

% b = c.labelcmb{aa,1};
b = c.labelcmb(find(ismember(c.labelcmb(:,1),b)),:);
cfg           = [];
cfg.channelcmb         = b;
b = ft_selectdata(cfg,c);
b.label = cellfun(@(x) x(3:end), b.labelcmb(:,2), 'un', 0);
b = rmfield(b,'labelcmb');

cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.layout           = 'biosemi64.lay';
cfg.showlabels       = 'yes';
        cfg.colormap = jet;
cfg.zlim = [0 1];
figure; ft_multiplotTFR(cfg, b);
title(A{g,1}(comb))



