

load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\coherence_analysis\idx.mat');

%% ======================= real pair coherence==========================
load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\coherence_analysis\matlab.mat', 'prespeech');
load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\coherence_analysis\surrogate_trial.mat','index_comb');

prelisten = prespeech;
G = [];
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
                cfg           = [];
                cfg.latency         = [-0.8 0.3];
                a = ft_selectdata(cfg,prespeech{sub,1});
                b = ft_selectdata(cfg,prelisten{sub+1,1});
                
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
                
                group{g,1} = a;                
                group{g,2} = b;

            end
        end
        g=g+1;
    end
    
    a = find(cellfun('isempty',group(:,1)));
    group(a,:) = [];
    
    % normalization
    for i= 1:length(group)
        cfg           = [];
        cfg.demean                    = 'yes';
        group{i,1} = ft_preprocessing(cfg,group{i,1});
        group{i,2} = ft_preprocessing(cfg,group{i,2});
    end
    
    cfg=[];
    conv_group = [];
    conv_group{1,1} = ft_appenddata(cfg,group{:,1});
    conv_group{1,2} = ft_appenddata(cfg,group{:,2});

    
    % coherence
    cfg           = [];
    cfg.method    = 'mtmconvol';
    cfg.taper     = 'hanning';
    cfg.output    = 'pow';
    cfg.foi          = 1:40;
    cfg.t_ftimwin    = ones(size(cfg.foi)).*0.3;   % length of time window = 0.5 sec
    cfg.toi          = -0.5:0.025:0;                  % time window "sli
    cfg.keeptrials  = 'yes';
%    
    G{con,1} = ft_freqanalysis(cfg, conv_group{1,1});
    G{con,2} = ft_freqanalysis(cfg, conv_group{1,2});
    
    G{con,3} = conv_group{1,1};
    G{con,4} = conv_group{1,2};
end
conv_group_L = G{1,1};
conv_group_F = G{1,2};
no_group_L = G{2,1};
no_group_F = G{2,2};

data = G(:,3:4);

save('leaderFolower_conv_noch.mat','conv_group_L','conv_group_F','no_group_L','no_group_F','data');
% save('leaderFolower_conv_noch_PreListen.mat','conv_group_L','conv_group_F','no_group_L','no_group_F','data');

freq = no_group_F.freq;
time = no_group_F.time;
channel = no_group_F.label;
conv_group_L = conv_group_L.powspctrm;
conv_group_F = conv_group_F.powspctrm;
no_group_L = no_group_L.powspctrm;
no_group_F = no_group_F.powspctrm;

save('leaderFolower_conv_noch_python.mat','conv_group_L','conv_group_F','no_group_L','no_group_F','freq','time','channel');
% save('leaderFolower_conv_noch_PreListen_python.mat','conv_group_L','conv_group_F','no_group_L','no_group_F','freq','time','channel');





