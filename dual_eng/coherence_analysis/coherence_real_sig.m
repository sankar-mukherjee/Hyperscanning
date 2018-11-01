
channel_avg = {{'F5';'F7';'FT7';'FC5'};{'AF8';'F6';'F8';'FT8';'FC6'};{'C4';'C6';'CP6';'CP4'};{'POz';'P2';'P4';'PO4'}};
channel_no  = 4;

%% ======================= real pair coherence==========================
load([project.paths.processedData '/coherence/matlab.mat'], 'prespeech');
load([project.paths.svn_scripts_root '/surrogate_trial.mat']);

prelisten = prespeech;
group = [];
j=1;g=1;
for sub=1:2:16
    s = index_comb(find(ismember(index_comb(:,5),sub) & ismember(index_comb(:,6),sub+1)),:);
    
    % condition combination
    a = [prespeech{sub,1}.trialinfo(:,2)];
    A = ismember(s(:,1),a);
    b = [prelisten{sub+1,1}.trialinfo(:,2)];
    B = ismember(s(:,2),b);
    A = find(A.*B);
    s = s(A,:);
    
    
    A = [];
    for ch=1:length(channel_avg)
        cfg           = [];
        cfg.channel     = channel_avg{ch};
        cfg.avgoverchan = 'yes';
        a = ft_selectdata(cfg,prespeech{sub,1});
        b = ft_selectdata(cfg,prelisten{sub+1,1});
        A{ch,1} = a; A{ch,2} = b;
    end
    cfg = [];
    a = ft_appenddata(cfg,A{:,1});
    b = ft_appenddata(cfg,A{:,2});
    
    cfg           = [];
    cfg.latency         = [-0.8 0.3];
    a = ft_selectdata(cfg,a);
    b = ft_selectdata(cfg,b);
    
    a.label = strcat('L-',a.label);
    b.label = strcat('F-',b.label);
    
    B = [];C = [];
    for i=1:size(s,1)
        A = find(ismember(a.trialinfo(:,2),s(i,1)));
        B.trial{1,i} = a.trial{A};
        B.time{1,i}  = a.time{A};
        
        A = find(ismember(b.trialinfo(:,2),s(i,2)));
        C.trial{1,i} = b.trial{A};
        C.time{1,i}  = b.time{A};
    end
    a.trial = B.trial;
    a.time  = B.time;
    b.trial = C.trial;
    b.time  = C.time;
    
    group{g,1} = ft_appenddata(cfg,a,b);
    group{g,1}.trialinfo = s;

    g=g+1;
end

% normalization
for i= 1:length(group)
    cfg           = [];
    cfg.demean                    = 'yes';
    group{i,1} = ft_preprocessing(cfg,group{i,1});
end

% coherence
cfg           = [];
cfg.method    = 'mtmconvol';
cfg.taper     = 'hanning';
cfg.output    = 'powandcsd';
cfg.foi          = 1:40;
cfg.t_ftimwin    = ones(size(cfg.foi)).*0.3;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.025:0;                  % time window "sli
cfg.keeptrials = 'yes';
% % collapse time
% cfg           = [];
% cfg.method    = 'mtmfft';
% cfg.taper     = 'hanning';
% cfg.output    = 'fourier';
% cfg.foi          = 1:40;

%
[A,B] = meshgrid(1:channel_no,channel_no+1:channel_no+channel_no);
i=cat(2,A',B');
a=reshape(i,[],2);
cfg.channelcmb = [ group{1,1}.label(a(:,1)) group{1,1}.label(a(:,2))];

a = [];A=[];
for i= 1:length(group)
    a{i,1} = ft_freqanalysis(cfg, group{i,1});
    
    cfg_conn           = [];
    cfg_conn.method    = 'coh';
    cfg_conn.channelcmb = cfg.channelcmb;
    cfg_conn.keeptrials = 'yes';

    A{i,1} = ft_connectivityanalysis(cfg_conn, a{i,1});
end

coh_full = A;




save([project.paths.processedData '/coherence/coh_real_sig'],'coh_full','group');






