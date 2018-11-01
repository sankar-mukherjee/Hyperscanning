%% ======================= real pair coherence==========================
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\matlab.mat', 'postlisten');
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\surrogate_trial.mat','index_comb');
load(['C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat/processed_data_word_level.mat'],'fileList_name');
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\idx.mat');

project.paths.wav = 'C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\label_creation\wav';
%% speech envelop [park et al 2016 elife lip entrainment]
fco = equal_xbm_bands(100, 10000, 9);

eeg = postlisten;
group = [];
for sub=1:2:16
    if not(sub==3)
        s = index_comb(find(ismember(index_comb(:,5),sub) & ismember(index_comb(:,6),sub+1)),:);
        
        % condition combination
        a = [eeg{sub,1}.trialinfo(:,2)];
        A = ismember(s(:,1),a);
        b = [eeg{sub+1,1}.trialinfo(:,2)];
        B = ismember(s(:,2),b);
        A = find(A.*B);
        s = s(A,:);
        
        cfg           = [];
        cfg.latency         = [-0.3 0.8];
        a = ft_selectdata(cfg,eeg{sub,1});
        b = ft_selectdata(cfg,eeg{sub+1,1});
        
        
        B = [];C = [];
        B.trialinfo = [];        C.trialinfo = [];
        j=1;k=1;
        for i=1:size(s,1)
            if(s(i,3)==2)
                [X,fs] = audioread([project.paths.wav '\' fileList_name{s(i,2)}]);
            else
                [X,fs] = audioread([project.paths.wav '\' fileList_name{s(i,1)}]);
            end
            
            %% speech envelop
%             [yupper,ylower] = envelope(X,500,'analytic');
%             yupper = ft_preproc_resample(yupper, fs, a.fsample, 'downsample');
            %% speech envelop
            hilbert_env = [];
            for ii=1:length(fco)-1
                filt = ft_preproc_bandpassfilter(X', fs, [fco(ii) fco(ii+1)], 4,'but','twopass');
                hilbert_env = [hilbert_env;ft_preproc_hilbert(filt, 'abs')];
            end
            hilbert_env = mean(hilbert_env);
            hilbert_env = ft_preproc_resample(hilbert_env, fs, a.fsample, 'downsample')';
        
            %% alingnment
            if(length(hilbert_env)>length(a.time{1}))
                l=length(a.time{1});
                hilbert_env = hilbert_env(1:l);
            else
                l=length(a.time{1}) - length(hilbert_env);
                hilbert_env = [hilbert_env; zeros(l,1)];
            end
            
            
            %%
            if(s(i,3)==2)
                if(find(conv_idx==s(i,1)))
                    aa = 1;
                else
                    aa = 0;
                end
                
                A = find(ismember(a.trialinfo(:,2),s(i,1)));
                B.trial{1,j} = [a.trial{A} ;hilbert_env'];
                B.time{1,j}  = a.time{A};
                B.trialinfo = [B.trialinfo;aa];
                j=j+1;
            else
                if(find(conv_idx==s(i,2)))
                    aa = 1;
                else
                    aa = 0;
                end
                
                A = find(ismember(b.trialinfo(:,2),s(i,2)));
                C.trial{1,k} = [b.trial{A}; hilbert_env'];
                C.time{1,k}  = b.time{A};
                C.trialinfo = [C.trialinfo;aa];
                k=k+1;
            end
        end
        
        B.label = [a.label , 'speech_envelop'];
        C.label  = [a.label , 'speech_envelop'];
        
        
        
        group{sub,1} = B;       group{sub+1,1} = C;
    end
    
end

data = group(~cellfun('isempty',group));  

%% normalization
for i= 1:length(data)
    cfg           = [];
    cfg.demean                    = 'yes';
    data{i,1} = ft_preprocessing(cfg,data{i,1});
end



%% coherence
cfg           = [];
cfg.method    = 'mtmconvol';
cfg.taper     = 'hanning';
cfg.output    = 'powandcsd';
cfg.foi          = 1:40;
cfg.t_ftimwin    = ones(size(cfg.foi)).*0.3;   % length of time window = 0.5 sec
cfg.toi          = 0:0.025:0.5;                  % time window "sli
cfg.keeptrials = 'yes';

% % collapse time
% cfg           = [];
% cfg.method    = 'mtmfft';% cfg.taper     = 'hanning';
% cfg.output    = 'fourier';
% cfg.foi          = 1:40;

%

[A,B] = meshgrid(1:64,65);
i=cat(2,A',B');
a=reshape(i,[],2);
channelcmb = [ data{1,1}.label(a(:,1))' data{1,1}.label(a(:,2))'];

TF = [];
for i= 1:length(data)
    cfg.trials = 'all';
    cfg.channelcmb = channelcmb;
    TF{i,1} = ft_freqanalysis(cfg, data{i,1});
    
    cfg.trials = find(data{i,1}.trialinfo==1);
    TF{i,2} = ft_freqanalysis(cfg, data{i,1});
    
    cfg.trials = find(data{i,1}.trialinfo==0);
    TF{i,3} = ft_freqanalysis(cfg, data{i,1});    
end

cfg_conn           = [];
cfg_conn.method    = 'coh';
cfg_conn.channelcmb = channelcmb;
coh_full=[];
for i= 1:length(TF)
    coh_full{i,1} = ft_connectivityanalysis(cfg_conn, TF{i,1});
    coh_full{i,2} = ft_connectivityanalysis(cfg_conn, TF{i,2});
    coh_full{i,3} = ft_connectivityanalysis(cfg_conn, TF{i,3});
end

cfg           = [];
cfg.method    = 'plv';
cfg.channelcmb = channelcmb;
cfg.keeptrials = 'yes';

coh_full=[];
for i= 1:length(TF)
    cfg.trials = 'all';
    coh_full{i,1} = ft_connectivityanalysis(cfg, TF{i,1});
    coh_full{i,2} = ft_connectivityanalysis(cfg, TF{i,2});
    coh_full{i,3} = ft_connectivityanalysis(cfg, TF{i,3});
end

cfg           = [];
cfg.method    = 'corr';
cfg.channelcmb = channelcmb;
cfg.keeptrials = 'yes';
cfg.covariance         = 'yes';
cfg.removemean         = 'yes';

coh_full=[];
for i= 1:length(data)
    a = ft_timelockanalysis(cfg,data{i,1});
    coh_full{i,1} = ft_connectivityanalysis(cfg,a);
    
    cfg.trials = find(data{i,1}.trialinfo==1);
    a = ft_timelockanalysis(cfg,data{i,1});
    coh_full{i,2} = ft_connectivityanalysis(cfg, a);
    
    a = ft_timelockanalysis(cfg,data{i,1});
    coh_full{i,3} = ft_connectivityanalysis(cfg, a);
end

cfg                  = [];
cfg.parameter        = 'plvspctrm';
cfg.xlim             = [0 0.5];
cfg.ylim             = [6 40];
cfg.refchannel       = 'speech_envelop';
cfg.layout           = 'biosemi64.lay';
cfg.showlabels       = 'yes';
figure; ft_multiplotTFR(cfg, coh_full{1,3});

cfg.xlim             = [0:0.1: 0.5];
figure; ft_topoplotER(cfg, coh_full{1,2})


TFR_diff=[];
cfg = [];
cfg.parameter = 'plvspctrm';
cfg.operation = '(x1-x2)./x2';
for i=1:length(data)
    
    TFR_diff{i}     = ft_math(cfg, coh_full{i,2}, coh_full{i,3});
    TFR_diff{i}.label=data{1,1}.label(1:end-1);
    TFR_diff{i}.dimord = 'chan_freq_time';
end

cfg = [];
cfg.parameter = 'plvspctrm';
a = ft_freqgrandaverage(cfg, TFR_diff{:});

cfg                  = [];
cfg.parameter        = 'plvspctrm';
cfg.xlim             = [0 0.5];
% cfg.zlim             = [0 50];
cfg.refchannel       = 'speech_envelop';
cfg.layout           = 'biosemi64.lay';
cfg.showlabels       = 'yes';
figure; ft_multiplotTFR(cfg, a);



a=[];
cfg           = [];
cfg.parameter = 'cohspctrm';
cfg.operation = 'log10';
for i=1:length(data)
    a{i,1} = ft_math(cfg, coh_full{i,2});    a{i,2} = ft_math(cfg, coh_full{i,3});

end


cfg = [];
cfg.parameter = 'cohspctrm';
cfg.operation = 'log10';
TFR_diff     = ft_math(cfg,TFR_diff);


tf_d=[];
for i=1:length(coh_full)
    tf_d{i} = coh_full{i,2};
    tf_d{i}.label=data{1,1}.label(1:end-1);
end

cfg = [];
cfg.channel   = data{1,1}.label(1:end-1);
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'cohspctrm';
a = ft_freqgrandaverage(cfg, tf_d);



%% parametric statistics
coh_conv_pair1 = coh_full([1:5 7:end],2);
coh_noch_pair2 = coh_full([1:5 7:end],3);

cfg = [];
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.parameter   = 'plvspctrm';
Nsub = 13;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
cfg.latency          = [0 0.5];
cfg.frequency          =  'all';
cfg.method    = 'analytic';
cfg.correctm  = 'fdr';


    cfg.alpha            = 0.025;



stat     = ft_freqstatistics(cfg, coh_conv_pair1{:},coh_noch_pair2{:});
stat.dimord = 'chan_freq_time';
stat.label  = data{1,1}.label(1:end-1);


cfg               = [];
cfg.marker        = 'off';
cfg.layout        = 'biosemi64.lay';
cfg.parameter     = 'stat';  % plot the t-value
cfg.maskparameter = 'mask';  % use the thresholded probability to mask the data
cfg.maskstyle     = 'saturation';
cfg.box              = 'yes';
cfg.colorbar         = 'yes';
cfg.showlabels       = 'yes';

figure;ft_multiplotTFR(cfg, stat);

% find significant channels
sig_tiles = find(stat.mask); % find significant time-frequency tiles
[chan freq time] = ind2sub(size(stat.mask),sig_tiles); % transform linear indices to subscript to extract significant channels, timepoints and frequencies

A = [];
for i=1:length(chan)
    A = [A;chan(i) stat.freq(freq(i)) stat.time(time(i))];    
end


%% singnificant connection (non parametric)
fb = strcat(channelcmb(:,1),channelcmb(:,2));

Ngroup = 13;
coh_conv_pair1 = coh_full([1:5 7:end],2);
coh_noch_pair2 = coh_full([1:5 7:end],3);
for i= 1:Ngroup
    coh_conv_pair1{i}.cohspctrm = atanh(coh_conv_pair1{i}.cohspctrm) - atanh(coh_noch_pair2{i}.cohspctrm);
    coh_noch_pair2{i}.cohspctrm(:) = 0; %this is done for 5 subjects separately
    coh_conv_pair1{i}.label = fb;
    coh_noch_pair2{i}.label = fb;
end
load('C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\coherence\neighbours.mat')

clc
for f=1:40    
    cfg = [];
    cfg.latency          = 'all';
    cfg.frequency        = coh_full{1,1}.freq(f); % this will be performed for different frequency bands
    cfg.method           = 'montecarlo';
    cfg.statistic        = 'ft_statfun_depsamplesT';
    cfg.correctm         = 'cluster';
    cfg.clusteralpha     = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.minnbchan        = 2;
    % cfg.neighbourdist    = 1;
    cfg.tail             = 0;
    cfg.clustertail      = 0;
    cfg.alpha            = 0.025;
    cfg.correcttail      = 'prob';  % 'prob''alpha'
    cfg.numrandomization = 500;
    % specifies with which sensors other sensors can form clusters
    cfg.neighbours       = neighbours;
    cfg.parameter   = 'cohspctrm';
    cfg.channel          = fb;
    
    design = zeros(2,2*Ngroup);
    for i = 1:Ngroup
        design(1,i) = i;
    end
    for i = 1:Ngroup
        design(1,Ngroup+i) = i;
    end
    design(2,1:Ngroup)        = 1;
    design(2,Ngroup+1:2*Ngroup) = 2;
    
    cfg.design   = design;
    cfg.uvar     = 1;
    cfg.ivar     = 2;
    
    [stat] = ft_freqstatistics(cfg,coh_conv_pair1{:},coh_noch_pair2{:});
end






%%


cfg = [];
cfg.method = 'wavelet';
cfg.toi          = 0:0.025:0.5;                  % time window "sli
cfg.output = 'fourier';
freq = ft_freqanalysis(cfg, data{1,1});

% make a new FieldTrip-style data structure containing the ITC
% copy the descriptive fields over from the frequency decomposition

itc = [];
itc.label     = freq.label;
itc.freq      = freq.freq;
itc.time      = freq.time;
itc.dimord    = 'chan_freq_time';

F = freq.fourierspctrm;   % copy the Fourier spectrum
N = size(F,1);           % number of trials
% compute inter-trial phase coherence (itpc) 
itc.itpc      = F./abs(F);         % divide by amplitude  
itc.itpc      = sum(itc.itpc,1);   % sum angles
itc.itpc      = abs(itc.itpc)/N;   % take the absolute value and normalize
itc.itpc      = squeeze(itc.itpc); % remove the first singleton dimension
% compute inter-trial linear coherence (itlc)
itc.itlc      = sum(F) ./ (sqrt(N*sum(abs(F).^2)));
itc.itlc      = abs(itc.itlc);     % take the absolute value, i.e. ignore phase
itc.itlc      = squeeze(itc.itlc); % remove the first singleton dimension

figure
subplot(2, 1, 1);
imagesc(itc.time, itc.freq, squeeze(itc.itpc(1,:,:))); 
axis xy
title('inter-trial phase coherence');
subplot(2, 1, 2);
imagesc(itc.time, itc.freq, squeeze(itc.itlc(1,:,:))); 
axis xy
title('inter-trial linear coherence');


















