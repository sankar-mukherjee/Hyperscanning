












load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\convergence\word_pair_position_32_10_mwv_mfc.mat')
index =  [reshape(word_pair_position(:,:,2)',32,1) reshape(word_pair_position(:,:,3)',32,1) reshape(word_pair_position(:,:,1)',32,1)];
index_O = cellfun(@transpose,index,'UniformOutput',false);

load('F:\WORK\25ms\-1-1\EEG__32_10_mwv_mfc_convVSnoch_25ms_10.mat')

group = [];
g=1;j=1;
for sub = 1:2:16
    S = cell2mat(index_O(j:j+3,:));    
    for cond =1:2
        temp = [];
        B = [];
        if(cond ==1)
            B{1,1} = CONV_tf{sub};
            B{1,2} = CONV_tf{sub+1};
        else
            B{1,1} = NOCH_tf{sub};
            B{1,2} = NOCH_tf{sub+1};
        end
        
        
        a = ismember(S(:,1),B{1,1}.trialinfo(:,2));
        b = ismember(S(:,2),B{1,2}.trialinfo(:,2));
        a = find(a.*b);
        s = S(a,:);
        
        % select the sub A as leader
        s(find(s(:,3)==2),:)=[];
        %         % select the sub B as leader
        %         s(find(s(:,3)==1),:)=[];
        
        if not(isempty(s))            
            cfg           = [];
            cfg.trials = find(ismember(B{1,1}.trialinfo(:,2),s(:,1)));
            temp{1,1} = ft_selectdata(cfg,B{1,1});
            temp{1,1}.label = strcat('A-',temp{1,1}.label);
            
            cfg           = [];
            cfg.trials = find(ismember(B{1,2}.trialinfo(:,2),s(:,2)));
            temp{1,2} = ft_selectdata(cfg,B{1,2});
            temp{1,2}.label = strcat('B-',temp{1,2}.label);
            
            A = temp{1,1};
            A.label = [A.label temp{1,2}.label];
            A.powspctrm = cat(2,A.powspctrm,temp{1,2}.powspctrm);
            
            group{g,cond} = A;
        end
    end
    g=g+1;j=j+4;
end

group(5,:)=[];
%% group wise
statistic = [];
stat = [];
for g=1:7
    tfrconv = group{g,1};
    tfrnoch = group{g,2};
    
    % svm
    cfg         = [];
    cfg.layout  = 'biosemi64.lay';
    cfg.method  = 'crossvalidate';
    cfg.nfolds  = 10;
    cfg.frequency    = [8 14];
    cfg.design  = [ones(size(tfrconv.powspctrm,1),1); 2*ones(size(tfrnoch.powspctrm,1),1)]';
%     cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',0.2)};
    
    stat{g,1}        = ft_freqstatistics(cfg,tfrconv,tfrnoch);
    statistic = [statistic; stat{g,1}.statistic];
end



%% which feature contributed much
i=2;
B=[];
for g=1:7
    
    A = [];
    for j=1:10
        A =  [A mean(mean(stat{g}.model{j}.primal,3),2)];
    end
%     B = [B;A(i,:)];
    figure;pcolor(A)
    set(gca,'YTick',[1:128]);
    set(gca,'YTickLabel',stat{g}.label);
    caxis([1e-4 2e-4]);
end


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


