

channel_avg = {{'F5';'F7';'FT7';'FC5'};{'AF8';'F6';'F8';'FT8';'FC6'};{'C4';'C6';'CP6';'CP4'};{'POz';'P2';'P4';'PO4'}};
channel_no  = 4;




% channel_no = 64;
load('idx.mat');

%% ======================= real pair coherence==========================
load('matlab.mat', 'prespeech');
load('surrogate_trial.mat','index_comb');


prelisten = prespeech;
G = [];G_coh=[];
for con =1:2
    group = [];
    j=1;g=1;
    for sub=1:2:16
        s = index_comb(find(ismember(index_comb(:,4),sub) & ismember(index_comb(:,5),sub+1)),:);
        
        
        %% conv noch
        if(con==1)
            a = s(find(ismember(s(:,1),conv_idx)),:);
            s = a;
            a = s(find(ismember(s(:,2),conv_idx)),:);
            s = a;
        elseif(con == 2)
            a = s(find(ismember(s(:,1),noCh_idx)),:);
            s = a;
            a = s(find(ismember(s(:,2),noCh_idx)),:);
            s = a;
        end
        
        if not(isempty(s))
            %% condition combination
            a = [prespeech{sub,1}.trialinfo(:,2)];
            A = ismember(s(:,1),a);
            b = [prelisten{sub+1,1}.trialinfo(:,2)];
            B = ismember(s(:,2),b);
            A = find(A.*B);
            s = s(A,:);
            
            if not(isempty(s))
                
                
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
            end
        end
        g=g+1;
    end
    
    a = find(cellfun('isempty',group));
    group(a) = [];
    
    % normalization
    for i= 1:length(group)
        cfg           = [];
        cfg.demean                    = 'yes';
        group{i,1} = ft_preprocessing(cfg,group{i,1});
    end
    
    cfg=[];
    conv_group = ft_appenddata(cfg,group{:});
    
    
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
    cfg.channelcmb = [ conv_group.label(a(:,1)) conv_group.label(a(:,2))];
    
    a = ft_freqanalysis(cfg, conv_group);
    
    cfg_conn           = [];
    cfg_conn.method    = 'coh';
    cfg_conn.channelcmb = cfg.channelcmb;
    A = ft_connectivityanalysis(cfg_conn, a);
    
    G_coh{con,1} = A;
    G{con,1} = conv_group;
end




coh_conv_group =  G_coh{1,1};
coh_no_group =  G_coh{2,1};
conv_group = G{1,1};
no_group = G{2,1};


save('coherence_conv_noch_avgChannel.mat','coh_conv_group','conv_group','coh_no_group','no_group');






