

load('leaderFolower_conv_noch')

stat=[];

% svm
cfg         = [];
cfg.layout  = 'biosemi64.lay';
cfg.method  = 'crossvalidate';
cfg.nfolds  = 10;
cfg.frequency    = [8 11];

cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',0.2)};

cfg.design  = [ones(size(conv_group_L.powspctrm,1),1); 2*ones(size(conv_group_F.powspctrm,1),1)]';

stat{1,1}       = ft_freqstatistics(cfg,conv_group_L,conv_group_F);
stat{1,1}.statistic

cfg.design  = [ones(size(no_group_L.powspctrm,1),1); 2*ones(size(no_group_F.powspctrm,1),1)]';
stat{1,2}       = ft_freqstatistics(cfg,no_group_L,no_group_F);
stat{1,2}.statistic





%% which feature contributed much
A = [];B=[];
for j=1:10
    A =  [A mean(mean(stat{1,1}.model{j}.weights,3),2)];
    B=  [B mean(mean(stat{1,2}.model{j}.weights,3),2)];
end

j = [-0.005 0.005]
A(find(A>j(1) & A<j(2)))=NaN;
B(find(B>j(1) & B<j(2)))=NaN;



figure;pcolor(A)
set(gca,'YTick',[1:64]);
set(gca,'YTickLabel',stat{1,1}.label);
caxis([-1.5e-3 1.5e-3]);
caxis([-0.005 0.005]);


figure;pcolor(B)
set(gca,'YTick',[1:64]);
set(gca,'YTickLabel',stat{1,2}.label);
caxis([-1.5e-3 1.5e-3]);

%% plot

for i =1:10
    stat.mymodel = stat.model{i}.primal;
    %     stat.mymodel     = stat.model{i}.weights;
    
    %% A
    A = stat;
    A.mymodel =  A.mymodel(1:64,:,:);
    A.label = A.label(1:64);
    A.label = cellfun(@(x) x(3:end), A.label, 'un', 0);
    
    cfg              = [];
    cfg.layout       = 'biosemi64.lay';
    cfg.parameter    = 'mymodel';
    cfg.comment      = '';
    cfg.colorbar     = 'yes';
    cfg.interplimits = 'electrodes';
    figure;ft_topoplotTFR(cfg,A);
    
    %% B
    A = stat;
    A.mymodel =  A.mymodel(65:end,:,:);
    A.label = A.label(65:end);
    A.label = cellfun(@(x) x(3:end), A.label, 'un', 0);
    
    cfg              = [];
    cfg.layout       = 'biosemi64.lay';
    cfg.parameter    = 'mymodel';
    cfg.comment      = '';
    cfg.colorbar     = 'yes';
    cfg.interplimits = 'electrodes';
    figure;ft_topoplotTFR(cfg,A);
end







