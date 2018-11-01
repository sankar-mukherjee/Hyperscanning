%% tfr
cfg           = [];
cfg.method    = 'mtmconvol';
cfg.taper     = 'hanning';
cfg.output    = 'pow';
cfg.foi          = 1:40;
cfg.t_ftimwin    = ones(size(cfg.foi)).*0.3;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.025:0;                  % time window "sli
cfg.keeptrials = 'yes';
prespeechTFR = [];
for sub=1:16
    prespeechTFR{sub,1} = ft_freqanalysis(cfg, prespeech{sub,1});
end


%% phase
cfg           = [];
cfg.method    = 'mtmconvol';
cfg.taper     = 'hanning';
cfg.output    = 'fourier';
cfg.foi          = 1:40;
cfg.t_ftimwin    = ones(size(cfg.foi)).*0.3;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.025:0;                  % time window "sli
cfg.keeptrials = 'yes';
prespeechTFR = [];
for sub=1:16
    prespeechTFR{sub,1} = ft_freqanalysis(cfg, prespeech{sub,1});
end

%% signifcant channels
channel_avg = {{'F5';'F7';'FT7';'FC5'};{'AF8';'F6';'F8';'FT8';'FC6'};{'C4';'C6';'CP6';'CP4'};{'POz';'P2';'P4';'PO4'}};
freq_avg  = [12 14; 22 24; 24 29; 32 34];




channel_no  = 4;
load([project.paths.processedData '/coherence/matlab.mat'], 'prespeech');

prespeech_avg = [];
for sub=1:16
    B = prespeech{sub,1};
    
    % avg channel
    a = [];
    for ch=1:length(channel_avg)
        cfg           = [];
        cfg.channel     = channel_avg{ch};
        cfg.avgoverchan = 'yes';
        A = ft_selectdata(cfg,B);
        a{ch,1} =A;
    end    
    cfg = [];
    B = ft_appenddata(cfg,a{:,1});
    B.freq = [1:40];
    % avg freq
    a=[];
    for ch=1:size(freq_avg,1)
        cfg           = [];
        cfg.frequency     = freq_avg(ch,:);
        cfg.avgoverfreq = 'yes';
        A = ft_selectdata(cfg,B);
        a{ch,1} =A;
    end    
    cfg = [];
    B = ft_appenddata(cfg,a{:,1});
    
    
    prespeech_avg{sub,1} = B;    
end
% tfr
cfg           = [];
cfg.method    = 'mtmconvol';
cfg.taper     = 'hanning';
cfg.output    = 'pow';
cfg.foi          = 1:40;
cfg.t_ftimwin    = ones(size(cfg.foi)).*0.3;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.025:0;                  % time window "sli
cfg.keeptrials = 'yes';
prespeechTFR = [];
for sub=1:16
    prespeechTFR{sub,1} = ft_freqanalysis(cfg, prespeech_avg{sub,1});
end

save(['C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\mvpa\prespeech_tfr_sig'],'prespeechTFR');

% phase
cfg           = [];
cfg.method    = 'mtmconvol';
cfg.taper     = 'hanning';
cfg.output    = 'fourier';
cfg.foi          = 1:40;
cfg.t_ftimwin    = ones(size(cfg.foi)).*0.3;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.025:0;                  % time window "sli
cfg.keeptrials = 'yes';
prespeechTFR = [];
for sub=1:16
    prespeechTFR{sub,1} = ft_freqanalysis(cfg, prespeech_avg{sub,1});
end

save(['C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eng\mat\mvpa\prespeech_tfr_phase_sig'],'prespeechTFR');











