close all;
clear;clc;

exp.AAA = {'prespeech','prelisten','postlisten_24','postlisten_32'};

for condition=1:length(exp.AAA)
    close all;
    
    clearvars -except exp condition
    
    exp.cond=exp.AAA{condition};
    
    
    load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\idx.mat');
    load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\surrogate_trial.mat','index_comb');
    
    
    if(strcmp(exp.cond,'prespeech'))
        exp.time = [-0.27 -0.19];
        exp.freq = [12 14];
        load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\matlab.mat', exp.cond);
        
        
        eeg = prespeech;
        
    elseif(strcmp(exp.cond,'prelisten'))
        load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\matlab.mat', exp.cond);
        exp.time = [-0.26 -0.19];
        exp.freq = [22 24];
        eeg = prelisten;
        
        eeg = eeg([1:2 4:end]);
    elseif(strcmp(exp.cond,'postlisten_24'))
        load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\matlab.mat', 'postlisten');
        
        eeg = postlisten;
        eeg = eeg([1:2 4:end]);
        
        exp.time = [0.05 0.1];
        exp.freq = [24 29];
    elseif(strcmp(exp.cond,'postlisten_32'))
        load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\matlab.mat', 'postlisten');
        eeg = postlisten;
        eeg = eeg([1:2 4:end]);
        
        
        exp.time = [0.07 0.125];
        exp.freq = [32 34];
    end
    
    
    
    %%
    data_conv = [];data_noCh = [];
    
    for sub=1:length(eeg)
        s = eeg{sub}.trialinfo(:,2);
        a = find(ismember(s,conv_idx));
        
        cfg=[];
        cfg.trials = a ;
        data_conv{sub,1} = ft_selectdata(cfg,eeg{sub});
        
        a = find(ismember(s,conv_idx)==0);
        cfg.trials = a ;
        data_noCh{sub,1} = ft_selectdata(cfg,eeg{sub});
    end
    
    %
    cfg = [];
    cfg.toilim = exp.time;
    for i=1:length(data_noCh)
        data_conv{i,1} = ft_redefinetrial(cfg, data_conv{i,1});
        data_noCh{i,1} = ft_redefinetrial(cfg, data_noCh{i,1});
    end
    
    
    % Freqanalysis for beamformer
    cfg = [];
    cfg.method       = 'mtmfft';
    cfg.output       = 'powandcsd';
    cfg.taper ='hanning';
    cfg.foi          = exp.freq;
    % cfg.tapsmofrq    = 2;
    % cfg.pad        = 1;
    % cfg.padtype     = 'zero';
    conv_tf = [];noch_tf = [];freqAll=[];
    for i=1:length(data_noCh)
        conv_tf{i} = ft_freqanalysis(cfg, data_conv{i});
        noch_tf{i} = ft_freqanalysis(cfg, data_noCh{i});
        freqAll{i} = ft_freqanalysis(cfg, eeg{i});
    end
    save([exp.cond '_speech_freq.mat'],'conv_tf','noch_tf','freqAll');
    
    clearvars -except exp condition
    %% source analysis
    load('headmodel_biosemi64_grid2');
    load([exp.cond '_speech_freq.mat']);
    
    cfg              = [];
    cfg.method       = 'dics';
    cfg.frequency    = median(exp.freq);
    cfg.grid         = grid;
    cfg.headmodel          = vol;
    cfg.senstype     = 'EEG'; % Remember this must be specified as either EEG, or MEG
    cfg.dics.keepfilter   = 'yes';
    cfg.dics.realfilter   = 'yes';
    cfg.dics.lambda       = '15%';
    
    sourceAll=[];
    for i=1:length(freqAll)
        sourceAll{i,1} = ft_sourceanalysis(cfg, freqAll{i});
    end
    
    
    source_conv= [];source_noch=[];
    for i=1:length(freqAll)
        cfg.grid.filter = sourceAll{i}.avg.filter;
        source_conv{i,1} = ft_sourceanalysis(cfg, conv_tf{i});
        source_noch{i,1} = ft_sourceanalysis(cfg, noch_tf{i});
    end
    
    % save([exp.cond '_speech_source.mat'],'source_conv','source_noch');
    
    %% run statistics over subjects %
    cfg=[];
    cfg.dim         = source_conv{1}.dim;
    cfg.method      = 'montecarlo';
    cfg.statistic   = 'ft_statfun_depsamplesT';
    cfg.parameter   = 'avg.pow';
    cfg.correctm    = 'cluster';
    cfg.clusteralpha     = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.numrandomization = 2500;
    cfg.alpha       = 0.025; % note that this only implies single-sided testing
    cfg.tail        = 0;
    cfg.correcttail      = 'alpha';  % 'prob''alpha'
    
    nsubj=numel(source_conv);
    cfg.design(1,:) = [1:nsubj 1:nsubj];
    cfg.design(2,:) = [ones(1,nsubj) ones(1,nsubj)*2];
    cfg.uvar        = 1; % row of design matrix that contains unit variable (in this case: subjects)
    cfg.ivar        = 2; % row of design matrix that contains independent variable (the conditions)
    stat = ft_sourcestatistics(cfg, source_conv{:}, source_noch{:});
    
    if(sum(stat.mask)==0)
        a = min([stat.posclusters.prob stat.negclusters.prob]);
        A=zeros(length(stat.prob),1);
        A(find(stat.prob<=a))=1;
        stat.mask2 = logical(A);
    else
        stat.mask2 = stat.mask;
        a=0.05;
    end
    
    
    load('standard_mri.mat');
    % interpolate the t maps to the structural MRI of the subject %
    cfg = [];
    cfg.parameter = 'all';
    statplot = ft_sourceinterpolate(cfg, stat, mri);
    
    
    
    % plot the t values on the MRI %
    cfg = [];
    cfg.method        = 'surface';
    cfg.funparameter  = 'stat';
    cfg.maskparameter = 'mask2';
    cfg.funcolormap    = 'jet';
    % cfg.funcolorlim    = [-4 4];
    % cfg.opacitylim     = [0.0 1.2];
    % cfg.opacitymap     = 'vdown';
    % cfg.projmethod     = 'nearest';
    % cfg.surffile       = 'surface_white_both.mat';
    % cfg.surfdownsample = 10;
    ft_sourceplot(cfg, statplot);
    
    
    title(['p= ' num2str(a)]);
    saveas(gcf,[exp.cond '_top.png']);
    
    view ([90 0])
    saveas(gcf,[exp.cond '_R.png']);
    
    view([-90 0]);
    camlight
    saveas(gcf,[exp.cond '_L.png']);
    
    %
    % light('style','infinite','position',[0 -200 200]);
    
    cfg = [];
    cfg.atlas         = 'C:\Users\SMukherjee\Desktop\matlab_toolbox\fieldtrip-master\template\atlas\afni/TTatlas+tlrc.BRIK';
    cfg.maskparameter = 'mask2';
    cfg.inputcoord = 'mni';
    labels = ft_volumelookup(cfg, stat);
    
    [tmp ind] = sort(labels.count,1,'descend');
    sel = find(tmp);
    found_areas = [];
    for j = 1:length(sel)
        found_areas{j,1} = labels.name{ind(j)};
        found_areas{j,2} =labels.count(ind(j));
    end
    save([exp.cond '_sigAreas.mat'],'found_areas');
    
    %%
    %
    % % % plot the t values on the MRI %
    cfg = [];
    cfg.method        = 'slice';
    cfg.funparameter  = 'stat';
    cfg.maskparameter = 'mask2';
    ft_sourceplot(cfg, statplot);
    saveas(gcf,[exp.cond '_slice.png']);
    
    %
    % % plot the t values on the MRI %
    cfg = [];
    cfg.method        = 'ortho';
    cfg.atlas         = 'C:\Users\SMukherjee\Desktop\matlab_toolbox\fieldtrip-master\template\atlas\aal\ROI_MNI_V4.nii';
    cfg.funparameter  = 'stat';
    cfg.maskparameter = 'mask2';
    ft_sourceplot(cfg, statplot);
    saveas(gcf,[exp.cond '_ortho.png']);
    
    %%
    
    cfg = [];
    cfg.parameter          = 'pow';
    GA_source_conv = ft_sourcegrandaverage(cfg, source_conv{:});
    GA_source_noch = ft_sourcegrandaverage(cfg, source_noch{:});
    
    
    cfg = [];
    cfg.parameter = 'pow';
    cfg.operation = '(x1-x2)./x2';
    source_diff      = ft_math(cfg, GA_source_conv, GA_source_noch);
    
    cfg            = [];
    cfg.parameter = 'pow';
    source_diff_rescale  = ft_sourceinterpolate(cfg, source_diff, mri);
    
    cfg = [];
    cfg.nonlinear     = 'no';
    sourceDiffIntNorm = ft_volumenormalise(cfg, source_diff_rescale);
    
    % save([exp.cond '_sourceDiffIntNorm.mat'],'sourceDiffIntNorm');
    
    
    cfg = [];
    cfg.method         = 'surface';
    cfg.funparameter   = 'pow';
    cfg.maskparameter  = cfg.funparameter;
    cfg.funcolorlim    = [-0.5 0.5];
    cfg.funcolormap    = 'jet';
    % cfg.opacitylim     = [0.0 1.2];
    % cfg.opacitymap     = 'rampup';
    % cfg.projmethod     = 'nearest';
    % cfg.surffile       = 'surface_white_both.mat';
    % cfg.surfdownsample = 10;
    ft_sourceplot(cfg, sourceDiffIntNorm);
    saveas(gcf,[exp.cond '_diff_top.png']);
    
    
    view ([90 0])
    saveas(gcf,[exp.cond '_diff_R.png']);
    
    view([-90 0]);
    camlight
    saveas(gcf,[exp.cond '_diff_L.png']);
    
    
    
    
    cfg = [];
    cfg.method        = 'slice';
    cfg.funparameter  = 'stat';
    cfg.maskparameter = cfg.funparameter;
    ft_sourceplot(cfg, sourceDiffIntNorm);
    saveas(gcf,[exp.cond '_diff_slice.png']);
    
    %
    % % plot the t values on the MRI %
    cfg = [];
    cfg.method        = 'ortho';
    cfg.atlas         = 'C:\Users\SMukherjee\Desktop\matlab_toolbox\fieldtrip-master\template\atlas\aal\ROI_MNI_V4.nii';
    cfg.funparameter  = 'stat';
    cfg.maskparameter =cfg.funparameter;
    ft_sourceplot(cfg, sourceDiffIntNorm);
    saveas(gcf,[exp.cond '_diff_ortho.png']);
    
    
end

































