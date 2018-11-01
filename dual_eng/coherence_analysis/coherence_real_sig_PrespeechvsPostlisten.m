
channel_avg = {{'F5';'F7';'FT7';'FC5'};{'AF8';'F6';'F8';'FT8';'FC6'};{'C4';'C6';'CP6';'CP4'};{'POz';'P2';'P4';'PO4'}};
channel_no  = 4;

%% ======================= real pair coherence==========================
load([project.paths.processedData '/coherence/matlab.mat'], 'prespeech','prelisten');
load([project.paths.svn_scripts_root '/surrogate_trial.mat']);

group = [];
j=1;g=1;
for sub=1:2:16
    if not(sub==3)
        s = index_comb(find(ismember(index_comb(:,5),sub) & ismember(index_comb(:,6),sub+1)),:);
        
        %% condition combination
        speech_A = s(find(s(:,3)==1),1);
        speech_B = s(find(s(:,3)==2),2);
        listen_A = s(find(s(:,3)==2),1);
        listen_B = s(find(s(:,3)==1),2);
        
        a = [prespeech{sub,1}.trialinfo(:,2)];
        speech_AA = ismember(speech_A,a);
        a = [prespeech{sub+1,1}.trialinfo(:,2)];
        speech_BB = ismember(speech_B,a);
        a = [prelisten{sub,1}.trialinfo(:,2)];
        listen_AA = ismember(listen_A,a);
        a = [prelisten{sub+1,1}.trialinfo(:,2)];
        listen_BB = ismember(listen_B,a);
        
        A = find(speech_AA.*listen_BB);
        A = [speech_A(A) listen_B(A)];
        B = find(listen_AA.*speech_BB);
        B = [listen_A(B) speech_B(B)];
        
        a = find(ismember(s(:,1:2),A,'rows'));
        b = find(ismember(s(:,1:2),B,'rows'));
        A = sort([a;b]);
        
        s = s(A,:);
        
        %%
        A = [];
        for ch=1:length(channel_avg)
            cfg           = [];
            cfg.channel     = channel_avg{ch};
            cfg.avgoverchan = 'yes';
            speech_A = ft_selectdata(cfg,prespeech{sub,1});
            speech_B = ft_selectdata(cfg,prespeech{sub+1,1});
            listen_A = ft_selectdata(cfg,prelisten{sub,1});
            listen_B = ft_selectdata(cfg,prelisten{sub+1,1});
            A{ch,1} = speech_A;
            A{ch,2} = speech_B;
            A{ch,3} = listen_A;
            A{ch,4} = listen_B;
        end
        cfg = [];
        speech_A = ft_appenddata(cfg,A{:,1});
        speech_B = ft_appenddata(cfg,A{:,2});
        listen_A = ft_appenddata(cfg,A{:,3});
        listen_B = ft_appenddata(cfg,A{:,4});
        
        cfg           = [];
        cfg.latency         = [-0.8 0.3];
        speech_A = ft_selectdata(cfg,speech_A);
        speech_B = ft_selectdata(cfg,speech_B);
        listen_A = ft_selectdata(cfg,listen_A);
        listen_B = ft_selectdata(cfg,listen_B);
        
        F = speech_A;L =speech_A;
        L.label = strcat('L-',speech_A.label);
        F.label = strcat('F-',speech_A.label);
        
        %%
        B = [];C = [];
        for i=1:size(s,1)
            if(s(i,3)==1)
                a = speech_A;b=listen_B;
            elseif(s(i,3)==2)
                a = listen_A;b=speech_B;
            end
            
            A = find(ismember(a.trialinfo(:,2),s(i,1)));
            B.trial{1,i} = a.trial{A};
            B.time{1,i}  = a.time{A};
            
            A = find(ismember(b.trialinfo(:,2),s(i,2)));
            C.trial{1,i} = b.trial{A};
            C.time{1,i}  = b.time{A};
        end
        
        L.trial = B.trial;
        L.time  = B.time;
        F.trial = C.trial;
        F.time  = C.time;
        
        group{g,1} = ft_appenddata(cfg,L,F);
        group{g,1}.trialinfo = s;
        g=g+1;
    end
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
    A{i,1} = ft_connectivityanalysis(cfg_conn, a{i,1});
end

coh_full = A;




save([project.paths.processedData '/coherence/coh_real_sig_Prespeech_PostListen'],'coh_full','group');






