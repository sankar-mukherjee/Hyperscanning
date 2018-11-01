

clear
clc
load('listen_entrainment.mat');

freq_band = [0.5 2;1 4;2 6;4 8;8 12;12 18;18 24;24 36; 30 40];
for f=1:length(freq_band)
    %% normalization
    cfg           = [];
    cfg.channel = data{1}.label(1:64);
    cfg.demean                    = 'yes';
    % cfg.detrend                    = 'yes';
    cfg.bpfilter      = 'yes';
    cfg.bpfreq        = freq_band(f,:);
    cfg.hilbert    = 'complex';
    % cfg.keeptrials = 'yes';
    
    cfg_S = [];
    cfg_S.channel = data{1}.label(65);
    % cfg_S.demean                    = 'yes';
    % cfg_S.detrend                    = 'yes';
    cfg_S.lpfilter      = 'yes';
    cfg_S.lpfreq        = 12;
    cfg_S.hilbert    = 'complex';
    
    new_data=[];
    for i= 1:length(data)
        a = ft_preprocessing(cfg,data{i,1});
        b = ft_preprocessing(cfg_S,data{i,1});
        new_data{i,1} = ft_appenddata([], a, b);
    end
    
    %%
    delay_samples = 0:40;
    delays = delay_samples * 5; % ms
    Ndel = length(delay_samples);
    Nt = size(new_data{1,1}.trial{1,1},2);
    Nch = 64;
    
    %% amp amp
    MI_amp_amp =[];
    for i= 1:length(data)
        A = new_data{i,1};
        Isig = cell(1,length(A.trial));
        
        for t=1:length(A.trial)
            eeg = real(A.trial{1,t}(1:Nch,:))';
            speech = real(A.trial{1,t}(65,:))';
            
            Iplnsum = zeros(Nch,Ndel);
            for di=1:Ndel
                d = delay_samples(di);
                for chi=1:Nch
                    Iplnsum(chi,di) = gcmi_cc(eeg((1+d):end,chi), speech(1:(end-d)));
                end
            end
            Isig{1,t} = Iplnsum;
        end
        
        a = data{i,1}.trialinfo;
        conv = Isig(find(a));
        noch = Isig(find(a==0));
        
        MI_amp_amp{i,1}.trial = conv;
        MI_amp_amp{i,1}.label = data{1}.label(1:64);
        MI_amp_amp{i,1}.time = repmat({delays},[1 length(conv)]);
        
        MI_amp_amp{i,2}.trial = noch;
        MI_amp_amp{i,2}.label = data{1}.label(1:64);
        MI_amp_amp{i,2}.time = repmat({delays},[1 length(noch)]);
        
        disp(i)
    end
    
    %% amp phase
    MI_amp_phase =[];
    for i= 1:length(data)
        A = new_data{i,1};
        Isig = cell(1,length(A.trial));
        
        for t=1:length(A.trial)
            eeg = real(A.trial{1,t}(1:Nch,:))';
            
            speech = A.trial{1,t}(65,:)';
            a = sqrt(real(speech).^2 + imag(speech).^2);
            speech = cat(2,real(speech), imag(speech));
            % normalise away amplitude so points lie on unit circle (direction only)
            speech = speech./[a a];
            speech = copnorm(speech);
            
            
            Iplnsum = zeros(Nch,Ndel);
            for di=1:Ndel
                d = delay_samples(di);
                for chi=1:Nch
                    Iplnsum(chi,di) = gcmi_cc(eeg((1+d):end,chi), speech(1:(end-d),:));
                end
            end
            Isig{1,t} = Iplnsum;
        end
        a = data{i,1}.trialinfo;
        conv = Isig(find(a));
        noch = Isig(find(a==0));
        
        MI_amp_phase{i,1}.trial = conv;
        MI_amp_phase{i,1}.label = data{1}.label(1:64);
        MI_amp_phase{i,1}.time = repmat({delays},[1 length(conv)]);
        
        MI_amp_phase{i,2}.trial = noch;
        MI_amp_phase{i,2}.label = data{1}.label(1:64);
        MI_amp_phase{i,2}.time = repmat({delays},[1 length(noch)]);
        
        disp(i)
    end
    
    %% phase amp
    MI_phase_amp =[];
    for i= 1:length(data)
        A = new_data{i,1};
        Isig = cell(1,length(A.trial));
        
        for t=1:length(A.trial)
            eeg = (A.trial{1,t}(1:Nch,:))';
            a = sqrt(real(eeg).^2 + imag(eeg).^2);
            eeg = cat(2, reshape(real(eeg),[Nt 1 Nch]), reshape(imag(eeg), [Nt 1 Nch]));
            eeg = bsxfun(@rdivide, eeg, reshape(a, [Nt 1 Nch]));
            eeg = copnorm(eeg);
            
            speech = real(A.trial{1,t}(65,:))';
            
            Iplnsum = zeros(Nch,Ndel);
            for di=1:Ndel
                d = delay_samples(di);
                for chi=1:Nch
                    Iplnsum(chi,di) = gcmi_cc(eeg((1+d):end,:,chi), speech(1:(end-d)));
                end
            end
            Isig{1,t} = Iplnsum;
        end
        a = data{i,1}.trialinfo;
        conv = Isig(find(a));
        noch = Isig(find(a==0));
        
        MI_phase_amp{i,1}.trial = conv;
        MI_phase_amp{i,1}.label = data{1}.label(1:64);
        MI_phase_amp{i,1}.time = repmat({delays},[1 length(conv)]);
        
        MI_phase_amp{i,2}.trial = noch;
        MI_phase_amp{i,2}.label = data{1}.label(1:64);
        MI_phase_amp{i,2}.time = repmat({delays},[1 length(noch)]);
        
        disp(i)
    end
    
    %% phase phase
    MI_phase_phase =[];
    for i= 1:length(data)
        A = new_data{i,1};
        Isig = cell(1,length(A.trial));
        
        for t=1:length(A.trial)
            eeg = (A.trial{1,t}(1:Nch,:))';
            a = sqrt(real(eeg).^2 + imag(eeg).^2);
            eeg = cat(2, reshape(real(eeg),[Nt 1 Nch]), reshape(imag(eeg), [Nt 1 Nch]));
            eeg = bsxfun(@rdivide, eeg, reshape(a, [Nt 1 Nch]));
            eeg = copnorm(eeg);
            
            speech = A.trial{1,t}(65,:)';
            a = sqrt(real(speech).^2 + imag(speech).^2);
            speech = cat(2,real(speech), imag(speech));
            % normalise away amplitude so points lie on unit circle (direction only)
            speech = speech./[a a];
            speech = copnorm(speech);
            
            
            Iplnsum = zeros(Nch,Ndel);
            for di=1:Ndel
                d = delay_samples(di);
                for chi=1:Nch
                    Iplnsum(chi,di) = gcmi_cc(eeg((1+d):end,:,chi), speech(1:(end-d),:));
                end
            end
            Isig{1,t} = Iplnsum;
        end
        a = data{i,1}.trialinfo;
        conv = Isig(find(a));
        noch = Isig(find(a==0));
        
        MI_phase_phase{i,1}.trial = conv;
        MI_phase_phase{i,1}.label = data{1}.label(1:64);
        MI_phase_phase{i,1}.time = repmat({delays},[1 length(conv)]);
        
        MI_phase_phase{i,2}.trial = noch;
        MI_phase_phase{i,2}.label = data{1}.label(1:64);
        MI_phase_phase{i,2}.time = repmat({delays},[1 length(noch)]);
        
        disp(i)
    end
    
    
    %% cluster in timelockstat, time as delay
    load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\neighbours.mat');
    subj_stat=[];
    
    for cond=1:4
        if(cond==1)
            A = MI_amp_amp;
        elseif(cond==2)
            A = MI_amp_phase;
        elseif(cond==3)
            A = MI_phase_amp;
        else
            A = MI_phase_phase;
        end
        
        for i=1:length(A)
            cfg = [];
            cfg.keeptrials = 'yes';
            conv  = ft_timelockanalysis(cfg,  A{i,1});
            noch  = ft_timelockanalysis(cfg,  A{i,2});
            
            
            cfg = [];
            cfg.method           = 'montecarlo';
            cfg.statistic        = 'ft_statfun_indepsamplesT';
            cfg.correctm         = 'cluster';
            cfg.clusteralpha     = 0.05;
            cfg.clusterstatistic = 'maxsum';
            cfg.minnbchan        = 2;
            cfg.tail             = 0;
            cfg.clustertail      = 0;
            cfg.alpha            = 0.025;
            cfg.correcttail      = 'alpha';  % 'prob''alpha'
            cfg.numrandomization = 2500;
            cfg.neighbours       = neighbours;
            
            design = zeros(1,size(conv.trial,1) + size(noch.trial,1));
            design(1,1:size(conv.trial,1)) = 1;
            design(1,(size(conv.trial,1)+1):(size(conv.trial,1) + size(noch.trial,1)))= 2;
            cfg.design = design;             % design matrix
            cfg.ivar  = 1;                   % number or list with indices indicating the independent variable(s)
            
            
            subj_stat{i,cond} = ft_timelockstatistics(cfg, conv, noch);
            
        end
        
        %% group stat
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
        
        group_stat{cond,1} = ft_timelockstatistics(cfg, conv{:}, noch{:});        
        
    end
    save(['MI_conv_noch_' num2str(freq_band(f,1)) '_' num2str(freq_band(f,2)) '.mat'],'MI_amp_amp','MI_amp_phase','MI_phase_amp','MI_phase_phase','subj_stat','group_stat');
end































