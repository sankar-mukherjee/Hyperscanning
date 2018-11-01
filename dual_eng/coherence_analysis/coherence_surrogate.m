

channel_avg = {{'F5';'F7';'FT7';'FC5'};{'AF8';'F6';'F8';'FT8';'FC6'};{'C4';'C6';'CP6';'CP4'};{'POz';'P2';'P4';'PO4'}};
channel_no  = 4;



% channel_no = 64;


%% coherence with surrogate data
load('matlab.mat', 'prespeech');
load([project.paths.svn_scripts_root '/surrogate_trial.mat']);


%% ================ sorrogate coherence creation ==============================
no_repetation = 1000;

cfg=[];
data = ft_appenddata(cfg,prespeech{:});
Otrials = data.trialinfo(:,2);
% sgroup = [];
% coh_surrogate = cell(no_repetation,1);

for g=1:no_repetation
    
    sgroup = [];
    coh_surrogate = [];
    
    
    trials =[];
    for i=[1:197 199:length(s_comb)-1]  % not selecting the last word of session (recording prob i guess)
        A = s_comb{i,1};
        a = find(ismember(A(:,1),Otrials));
        b = find(ismember(A(:,2),Otrials));
        a = intersect(a,b);
        
        b = randsample(a,1);
        A = s_comb{i,1}(b,:);
        trials = [trials;A];
    end
    
    
    A = [];
    for ch=1:length(channel_avg)
        cfg           = [];
        cfg.channel     = channel_avg{ch};
        cfg.avgoverchan = 'yes';
        
        a = ft_selectdata(cfg,data);
        b = ft_selectdata(cfg,data);
        
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
    for i=1:size(trials,1)
        A = find(ismember(a.trialinfo(:,2),trials(i,1)));
        B.trial{1,i} = a.trial{A};
        B.time{1,i}  = a.time{A};
        
        A = find(ismember(b.trialinfo(:,2),trials(i,2)));
        C.trial{1,i} = b.trial{A};
        C.time{1,i}  = b.time{A};
    end
    a.trial = B.trial;
    a.time  = B.time;
    b.trial = C.trial;
    b.time  = C.time;
    
    cfg=[];
    %     sgroup{g,1} = ft_appenddata(cfg,a,b);
    sgroup = ft_appenddata(cfg,a,b);
    
    
    % normalization
    cfg           = [];
    cfg.demean                    = 'yes';
    %     sgroup{g,1} = ft_preprocessing(cfg,sgroup{g,1});
    sgroup = ft_preprocessing(cfg,sgroup);
    
    % coherence
    cfg           = [];
    cfg.method    = 'mtmconvol';
    cfg.taper     = 'hanning';
    cfg.output    = 'powandcsd';
    cfg.foi          = 1:40;
    cfg.t_ftimwin    = ones(size(cfg.foi)).*0.3;   % length of time window = 0.5 sec
    cfg.toi          = -0.5:0.025:0;                  % time window "sli
    
    % % collapse time
    % cfg           = [];
    % cfg.method    = 'mtmfft';
    % cfg.taper     = 'hanning';
    % cfg.output    = 'fourier';
    % cfg.foi          = 1:40;
    [A,B] = meshgrid(1:channel_no,channel_no+1:channel_no+channel_no);
    i=cat(2,A',B');
    a=reshape(i,[],2);
    %     cfg.channelcmb = [ sgroup{g,1}.label(a(:,1)) sgroup{g,1}.label(a(:,2))];
    cfg.channelcmb = [ sgroup.label(a(:,1)) sgroup.label(a(:,2))];
    
    %     a = ft_freqanalysis(cfg, sgroup{g,1});
    a = ft_freqanalysis(cfg, sgroup);
    cfg_conn           = [];
    cfg_conn.method    = 'coh';
    cfg_conn.channelcmb = cfg.channelcmb;
    coh_surrogate = ft_connectivityanalysis(cfg_conn, a);
    
    %     coh_surrogate{g,1} = A;
    save([project.paths.processedData '/coherence/surrogate_coh_avgChannel/surrogate_coh_avgChannel_' num2str(g) '.mat'],'coh_surrogate','sgroup');
    
    g=g+1;
end


% save('surrogate_coh.mat','coh_surrogate','sgroup');
%%

















