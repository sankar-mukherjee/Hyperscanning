%% Fieldtrip cluster permutation test

load([project.paths.processedData '/EEG.mat']);
load([project.paths.processedData '/processed_data_word_level.mat']);
EEG = pop_loadset([project.paths.projects_data_root '/dual_eng/05_nicholas_solo_raw_mc_pre_speech.set']);

save_cluster_data = [project.paths.projects_data_root '/dual_eng/mat/FiieldtripClustering/'];

%%
config.chanlocs = chanlocs;
config.eegrate  = 256;
baselineCorrect = 0;
reactionTime = 5;
logTransform = 0;

filelist = dir([project.paths.processedData '/convergence/convergence_' num2str(project.gmmUBM.gmmcomp) '_10_mwv_mfc.mat']);
for ff=1:length(filelist)
    
    load([project.paths.processedData '/convergence/' filelist(ff).name]);
    AAAA = strrep(filelist(ff).name,'convergence','');
    AAAA = strrep(AAAA,'.mat','');
    %%
    % condition = {'convVSnoch','convVSnoch_listen','leaderVSfollower'};
    
    condition = {'convVSnoch_listen'};
    subcondition = [25];
    for c=1:length(condition)
        if(strcmp(condition{c},'convVSnoch'))
            config.times = speech_eeg_times;%listen_eeg_times speech_eeg_times
            config.type = 'speech';
            config.trial_time_window = [-0.5 0];   %[-0.7 0.2]
            config.analysis_time_window = [-0.5 0];   %
            
            % convergence
            conv_idx = get_condition_index(D,convergence_data,'convergence');
            conv_idx = check_reactionTime(conv_idx,D,reactionTime);
            sub_idx = D(conv_idx,1);
            data_conv = get_trials_fieldtrip(EEG_data,EEG,sub_idx,conv_idx,config,baselineCorrect,convergence_data);
            
            % nochange
            noCh_idx = get_condition_index(D,convergence_data,'noch');
            noCh_idx = check_reactionTime(noCh_idx,D,reactionTime);
            sub_idx = D(noCh_idx,1);
            data_noCh = get_trials_fieldtrip(EEG_data,EEG,sub_idx,noCh_idx,config,baselineCorrect,convergence_data);
        elseif(strcmp(condition{c},'leaderVSfollower'))
            config.times = speech_eeg_times;%listen_eeg_times speech_eeg_times
            config.type = 'speech';
            config.analysis_time_window = [-0.5 0];   %[-0.2 0.6]
            
            % leader folower
            l= convergence_data(:,5);
            l(l==2)=0;
            a = convergence_data(:,1);
            a(a==2)=0;
            
            A = a .* l;
            conv_idx = find(a);
            conv_idx = check_reactionTime(conv_idx,D,reactionTime);
            
            sub_idx = D(conv_idx,1);
            data_conv = get_trials_fieldtrip(EEG_data,EEG,sub_idx,conv_idx,config,baselineCorrect);
            % nochange
            l= convergence_data(:,5);
            l(l==1)=0;
            a = convergence_data(:,1);
            a(a==1)=0;
            A = a .* l;
            noCh_idx = find(A);
            noCh_idx = check_reactionTime(noCh_idx,D,reactionTime);
            
            sub_idx = D(noCh_idx,1);
            session_idx = D(noCh_idx,2);
            temp = find(sub_idx == 0);
            noCh_idx(temp,1) = NaN;
            temp = find(session_idx == 1);
            noCh_idx(temp,1) = NaN;
            temp = find(session_idx == 6);
            noCh_idx(temp,1) = NaN;
            noCh_idx(find(isnan(noCh_idx(:,1))),:)=[];
            sub_idx = D(noCh_idx,1);
            data_noCh = get_trials_fieldtrip(EEG_data,EEG,sub_idx,noCh_idx,config,baselineCorrect);
        elseif(strcmp(condition{c},'convVSnoch_listen'))
            config.times = listen_eeg_times;%listen_eeg_times speech_eeg_times
            config.type = 'listen';
            
            config.trial_time_window = [-0.5 0.5];
            config.analysis_time_window = [0 0.5];   %
            config.analysis_time_window1 = [-0.5 0];
            
            % convergence
            conv_idx = get_condition_index(D,convergence_data,'convergence');
            conv_idx = check_reactionTime(conv_idx,D,reactionTime);
            
            sub_idx = D(conv_idx,1);
            data_conv = get_trials_fieldtrip(EEG_data,EEG,sub_idx,conv_idx,config,baselineCorrect,convergence_data);
            
            % nochange
            noCh_idx = get_condition_index(D,convergence_data,'noch');
            noCh_idx = check_reactionTime(noCh_idx,D,reactionTime);
            sub_idx = D(noCh_idx,1);
            data_noCh = get_trials_fieldtrip(EEG_data,EEG,sub_idx,noCh_idx,config,baselineCorrect,convergence_data);
        end
        
        
        %% cheking for cosistence subject
        a = find(cellfun('isempty',data_conv));
        b = find(cellfun('isempty',data_noCh));
        a = [a; b];
        a = unique(a);
        data_conv2 = data_conv;
        data_noCh2 = data_noCh;
        data_conv2(a) = [];
        data_noCh2(a) = [];
        
        data_noCh2 = data_noCh2(1:length(data_conv2));
        Nsub = length(data_conv2);
        
        % trial no in both cond
        a=[];b=[];
        for i=1:Nsub
            a = [a size(data_conv2{i,1}.trial,2)];
            b = [b size(data_noCh2{i,1}.trial,2)];
        end
        sum(a)
        sum(b)
        
        
        % cfg = [];
        % cfg.demean = 'yes';
        % data_conv2 = ft_preprocessing(cfg, data_conv2);
        % data_noCh2 = ft_preprocessing(cfg, data_noCh2);
        
        cfg.method    = 'distance';
        neighbours       = ft_prepare_neighbours(cfg, data_conv2{1});
        
        %% rereference
        cfg = [];
        cfg.reref       = 'yes';
        cfg.channel = {'all'};
        cfg.refchannel = {'all'};
        for i = 1: length(data_conv2)
            data_conv2{i}        = ft_preprocessing(cfg,data_conv2{i});
            data_noCh2{i}        = ft_preprocessing(cfg,data_noCh2{i});
        end
        %% ERP
        
        %         [CONV,GA_CONV,scd_CONV] = compute_ERP(data_conv2,config.trial_time_window);
        %         [NOCH,GA_NOCH,scd_NOCH] = compute_ERP(data_noCh2,config.trial_time_window);
        
        for subc=1:length(subcondition)
            fileName = [condition{c} '_' num2str(subcondition(subc)) 'ms' '.mat'];
            
            %% =============================================================== ERSP ===========================================================================
            [CONV_tf,~,GA_tf_CONV] = compute_ERSP(data_conv2,config.trial_time_window,subcondition(subc)/1e3,logTransform);
            [NOCH_tf,~,GA_tf_NOCH] = compute_ERSP(data_noCh2,config.trial_time_window,subcondition(subc)/1e3,logTransform);
            
            %             save([save_cluster_data 'EEG_' AAAA '_' fileName],'data_conv','data_noCh','CONV_tf','NOCH_tf','CONV','scd_CONV','NOCH','scd_NOCH');
%             save([save_cluster_data 'EEG_' AAAA '_' fileName],'data_conv','data_noCh','CONV_tf','NOCH_tf');
            
            %% fieldtrip cluster
            % ersp with in trial:
            within_trial_cluster = [];
            for subject = 1:length(CONV_tf)
                within_trial_subj_cluster = [];
                for freq = 1:size(GA_tf_CONV.freq,2)
                    within_subj_stat = within_trial_tf_cluster(CONV_tf{subject},NOCH_tf{subject},neighbours,GA_tf_CONV.freq(freq), config.analysis_time_window);
                    [within_trial_subj_cluster{freq,1},within_trial_subj_cluster{freq,2}] = significant_cluster_time_freq_channel(within_subj_stat);
                    within_trial_subj_cluster{freq,3} = within_subj_stat;
                    
%                     if(strcmp(condition{c},'convVSnoch_listen'))
%                         within_subj_stat = within_subj_tf_cluster(GA_tf_CONV,GA_tf_NOCH,neighbours,freq,Nsub, config.analysis_time_window1);
%                         [within_trial_cluster{freq,4},within_trial_cluster{freq,5}] = significant_cluster_time_freq_channel(within_subj_stat);
%                         within_trial_cluster{freq,6} = within_subj_stat;
%                     end
                end
                within_trial_cluster{subject,1} =  within_trial_subj_cluster;
            end
            
            % ersp:
            within_subj_cluster = [];
            for freq = 1:size(GA_tf_CONV.freq,2)
                within_subj_stat = within_subj_tf_cluster(GA_tf_CONV,GA_tf_NOCH,neighbours,freq,Nsub, config.analysis_time_window);
                [within_subj_cluster{freq,1},within_subj_cluster{freq,2}] = significant_cluster_time_freq_channel(within_subj_stat);
                within_subj_cluster{freq,3} = within_subj_stat;
                
                if(strcmp(condition{c},'convVSnoch_listen'))
                    within_subj_stat = within_subj_tf_cluster(GA_tf_CONV,GA_tf_NOCH,neighbours,freq,Nsub, config.analysis_time_window1);
                    [within_subj_cluster{freq,4},within_subj_cluster{freq,5}] = significant_cluster_time_freq_channel(within_subj_stat);
                    within_subj_cluster{freq,6} = within_subj_stat;
                end
                %     pause;
            end
            
            %erp
            %             within_subj_erp_cluster = within_subj_ERP_cluster(CONV,NOCH,neighbours,config.analysis_time_window,Nsub);            
            %             save([save_cluster_data 'fieldtrip_' AAAA '_' fileName],'within_subj_cluster','within_subj_erp_cluster');
            save([save_cluster_data 'fieldtrip_' AAAA '_' fileName],'within_subj_cluster');
            
            %% tfce cluster
            %         A = [];B =[];
            %         a =[];
            %         b=[];
            %         for i=1:Nsub
            %             a{i} =CONV_tf_d{1,i}.powspctrm;
            %             b{i}= NOCH_tf_d{1,i}.powspctrm;
            %         end
            %
            %         A = cat(4,a{:});
            %         A = permute(A, [4 1 2 3]);
            %         B = cat(4,b{:});
            %         B = permute(B, [4 1 2 3]);
            %                     ept_TFCE(double(A), double(B),chanlocs,'type', 'd', 'flag_ft', false, 'flag_tfce', true, 'nPerm', 2500,'rSample', config.eegrate,'saveName', [save_cluster_data 'tfce_' fileName]);
            
            close all;
        end
        
        
        
    end
    
    
end





% %% tfce cluster cut frequency upto 18 Hz for better resolution or
% analysis
% fileName = ['convVSnoch_listen_25ms.mat'];
% load([save_cluster_data 'EEG_' fileName])
% fileName = ['convVSnoch_listen_25ms_18Hzcut.mat'];
%
%
% A = [];B =[];
% a =[];
% b=[];
% for i=1:Nsub
%     a{i} =CONV_tf_d{1,i}.powspctrm(:,1:18,:);
%     b{i}= NOCH_tf_d{1,i}.powspctrm(:,1:18,:);
% end
%
% A = cat(4,a{:});
% A = permute(A, [4 1 2 3]);
% B = cat(4,b{:});
% B = permute(B, [4 1 2 3]);
%
% ept_TFCE(double(A), double(B),chanlocs,'type', 'd', 'flag_ft', false, 'flag_tfce', true, 'nPerm', 2500,'rSample', config.eegrate,'saveName', [save_cluster_data 'tfce_' fileName ]);
%
%
%
%



