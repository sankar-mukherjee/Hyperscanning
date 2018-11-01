
clear;clc;
freq_band = [0.5 2;1 4;2 6;4 8;8 12;12 18;18 24;24 36; 30 40];dd = 41;
% freq_band = [1 4;4 8;8 12;12 18;24 36; 30 40];dd=10;


load('listen_entrainment.mat');
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\neighbours.mat');



beta_coeff = [];
MI_betaCoeff_group_stat = [];MI_group_stat=[];
for f=1:length(freq_band)
    load(['MI_conv_noch_' num2str(freq_band(f,1)) '_' num2str(freq_band(f,2)) '.mat'])
    
    for j=1:4
        if(j==4)
            name = 'phase_phase';            A = MI_phase_phase;
        elseif(j==3)
            name = 'phase_amp';            A = MI_phase_amp;
        elseif(j==2)
            name = 'amp_phase';            A = MI_amp_phase;
        elseif(j==1)
            name = 'amp_amp';            A = MI_amp_amp;
        end
        
        all=[];
        for subj= 1:length(A)
            all{subj,1} = ft_appenddata([], A{subj,1}, A{subj,2});
        end
        %%
        
        for subj= 1:length(A)
            a = all{subj,1}.trial;
            a = cat(3,a{:});
            a = permute(a, [3 1 2]);
            
            B = data{subj,1}.trialinfo;
            
            for d=1:dd
                for ch=1:64
                    [b,dev,stats] = glmfit(a(:,ch,d),B);
                    beta_coeff(f,j,subj,ch,d) = b(2);
                end
            end
        end
        
        
        %% group stat on beata coeff
        cfg = [];
        BB=[];
        BB2 = [];
        for subj=1:length(data)
            BB{subj,1}.avg  = squeeze(beta_coeff(f,j,subj,:,:));
            BB{subj,1}.time  = A{1,1}.time{1,1};
            BB{subj,1}.label  = A{1,1}.label;
            BB{subj,1}.dimord  = 'chan_time';
            
            BB2{subj,1} = BB{subj,1};
            BB2{subj,1}.avg(:) = 0;
        end
        
        cfg = [];
        cfg.method = 'montecarlo';
        cfg.statistic = 'depsamplesT';
        cfg.correctm = 'cluster';
        cfg.clusteralpha = 0.05;
        cfg.clusterstatistic = 'maxsum';
        cfg.minnbchan = 2;
        cfg.neighbours = neighbours;  % same as defined for the between-trials experiment
        cfg.tail = 0;
        cfg.clustertail = 0;
        cfg.alpha = 0.05;
        cfg.correcttail      = 'alpha';  % 'prob''alpha'
        cfg.numrandomization = 2500;
        
        subj = length(data);
        design = zeros(2,2*subj);
        for i = 1:subj
            design(1,i) = i;
        end
        for i = 1:subj
            design(1,subj+i) = i;
        end
        design(2,1:subj)        = 1;
        design(2,subj+1:2*subj) = 2;
        
        cfg.design = design;
        cfg.uvar  = 1;
        cfg.ivar  = 2;
        
        for d=1:dd
            cfg.latency     = d;
            MI_betaCoeff_group_stat{f,j,d} = ft_timelockstatistics(cfg, BB{:}, BB2{:});
            %             disp(['================================ ' num2str(f) ' ' num2str(j) ' ' num2str(d)])
        end
        
        %% group stat on MI
        cfg = [];
        conv=[];noch=[];
        for subj=1:length(A)
            conv{subj,1}  = ft_timelockanalysis(cfg,  A{subj,1});
            noch{subj,1}  = ft_timelockanalysis(cfg,  A{subj,2});
        end
        
        
        cfg = [];
        cfg.method = 'montecarlo';
        cfg.statistic = 'depsamplesT';
        cfg.correctm = 'cluster';
        cfg.clusteralpha = 0.05;
        cfg.clusterstatistic = 'maxsum';
        cfg.minnbchan = 2;
        cfg.neighbours = neighbours;  % same as defined for the between-trials experiment
        cfg.tail = 0;
        cfg.clustertail = 0;
        cfg.alpha = 0.025;
        cfg.correcttail      = 'alpha';  % 'prob''alpha'
        cfg.numrandomization = 2500;
        
        subj = length(A);
        design = zeros(2,2*subj);
        for i = 1:subj
            design(1,i) = i;
        end
        for i = 1:subj
            design(1,subj+i) = i;
        end
        design(2,1:subj)        = 1;
        design(2,subj+1:2*subj) = 2;
        
        cfg.design = design;
        cfg.uvar  = 1;
        cfg.ivar  = 2;
        
        for d=1:dd
            cfg.latency     = d;
            MI_group_stat{f,j,d} = ft_timelockstatistics(cfg, conv{:}, noch{:});
        end
        
        
    end
end

save('beta_coeff_MI.mat','beta_coeff','MI_group_stat','MI_betaCoeff_group_stat');
%%
%
%
%
%
%
%
%
% cfg = [];
% cfg.parameter = 'stat';
% cfg.layout = 'biosemi64.lay';
% ft_clusterplot(cfg, a{1,1});





















