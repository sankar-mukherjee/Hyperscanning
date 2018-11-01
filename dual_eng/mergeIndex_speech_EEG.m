
% clear;clc;


all_subj = zeros(200,32);
all_eeg = cell(200,32);
all_index = zeros(200,32);
all_session_index = cell(16,2);
data_prepost=[];
b_prepost=[];
%%
sss=1;
for ss = 1:length(project.subjects.list)
    subj_name = project.subjects.data(1,ss).name;
    
    ALL = zeros(200,2);
    data = cell(200,2);
    ALL_index = zeros(200,2);
    for c =  1 : length(project.eeg.configaration)
        project.conf_file_name      = project.eeg.configaration{c};
        project = put_speech_listen_trigger(project,ss,project.eeg.duet.F_path);
        
        if(c==1||c==2)
            % for bad files
            if(ss == 8 || ss== 10 || ss== 14 || ss== 16)
                temp_O_path = project.eeg.duet.other_path;
            else
                temp_O_path = project.eeg.duet.O_path;
            end
            
            %% eeg baselne
            if(strcmp(subj_name,'04_alessandro'))
                baseline_end_time = 0.6;
            else
                baseline_end_time = 1;
            end
            
            %%
            O_file_name = [temp_O_path project.subjects.data(1,ss).name '_duet_raw.set'];
            O_EEG = pop_loadset(O_file_name);
            
            F_file_name = [project.eeg.duet.F_path project.subjects.data(1,ss).name '_duet_raw_mc.set'];
            F_EEG = pop_loadset(F_file_name);
            
            all_events_latency=[O_EEG.event.latency];
            all_events_type={O_EEG.event.type};
            
            if(strcmp(subj_name,'01_riccardo')|| strcmp(subj_name,'02_dino')|| strcmp(subj_name,'03_luigi')|| strcmp(subj_name,'04_alessandro'))
                start_idx = find(ismember(all_events_type, '3'));
                end_idx = find(ismember(all_events_type, '2'));
                if(strcmp(all_events_type(start_idx(3)+1),'31') && strcmp(all_events_type(start_idx(3)+2),'41'))
                    all_events_type{start_idx(3)+1} = '77';
                    all_events_type{start_idx(3)+2} = '78';
                end
                if(strcmp(all_events_type(start_idx(4)+1),'31') && strcmp(all_events_type(start_idx(4)+2),'41'))
                    all_events_type{start_idx(4)+1} = '77';
                    all_events_type{start_idx(4)+2} = '78';
                end
            end
            
            numev = size(all_events_type, 2);
            if(project.subjects.data(1,ss).position == 1)
                S_visual = '31';
                S_speech = '41';
                L_visual = '32';
                L_speech = '42';
            else
                S_visual = '32';
                S_speech = '42';
                L_visual = '31';
                L_speech = '41';
            end
            
            
            temp = find(ismember(all_events_type, S_speech));     S_speech_latency = all_events_latency(temp);
            temp = find(ismember(all_events_type, S_visual));     S_visual_latency = all_events_latency(temp);
            temp = find(ismember(all_events_type, L_visual));     L_visual_latency = all_events_latency(temp);
            temp = find(ismember(all_events_type, L_speech));     L_speech_latency = all_events_latency(temp);
            
            %% read history and adjust eeg event latency
            temp = strsplit(F_EEG.history,');')';
            idx = strfind(temp,'eeg_eegrej( EEG, [');
            temp_idx = find(not(cellfun('isempty', idx)));
            for i=1:length(temp_idx)
                temp_history = cell2mat(temp(temp_idx(i)));
                begin_index = strfind(temp_history,'eeg_eegrej( EEG, [') + 17; % advance no of char in the search string
                end_index = strfind(temp_history,']');
                removed_part = [];
                for idx=1:length(begin_index)
                    removed_part = [removed_part;str2double(temp_history(begin_index(idx)+1:end_index(idx)-1))];
                end
                
                %%
                previous_diff = 0;
                for j=1:size(removed_part,1)
                    % remove in between
                    SS = find(S_speech_latency > removed_part(j,1) & S_speech_latency < removed_part(j,2));
                    SV = find(S_visual_latency > removed_part(j,1) & S_visual_latency < removed_part(j,2));
                    LS = find(L_speech_latency > removed_part(j,1) & L_speech_latency < removed_part(j,2));
                    LV = find(L_visual_latency > removed_part(j,1) & L_visual_latency < removed_part(j,2));
                    
                    S_speech_latency(SS) = NaN;
                    S_visual_latency(SV) = NaN;
                    L_speech_latency(LS) = NaN;
                    L_visual_latency(LV) = NaN;
                end
                for j=1:size(removed_part,1)
                    % remove the same amount from the all the 4 arrays
                    if(j==size(removed_part,1))
                        SS = find(S_speech_latency > removed_part(j,2));
                        SV = find(S_visual_latency > removed_part(j,2));
                        LS = find(L_speech_latency > removed_part(j,2));
                        LV = find(L_visual_latency > removed_part(j,2));
                    else
                        SS = find(S_speech_latency > removed_part(j,2) & S_speech_latency < removed_part(j+1,1));
                        SV = find(S_visual_latency > removed_part(j,2) & S_visual_latency < removed_part(j+1,1));
                        LS = find(L_speech_latency > removed_part(j,2) & L_speech_latency < removed_part(j+1,1));
                        LV = find(L_visual_latency > removed_part(j,2) & L_visual_latency < removed_part(j+1,1));
                    end
                    previous_diff = previous_diff + diff(removed_part(j,:));
                    
                    S_speech_latency(SS) = S_speech_latency(SS) - previous_diff;
                    S_visual_latency(SV) = S_visual_latency(SV) - previous_diff;
                    L_speech_latency(LS) = L_speech_latency(LS) - previous_diff;
                    L_visual_latency(LV) = L_visual_latency(LV) - previous_diff;
                end
            end
            
            %% rename markers
            all_events_latency=[F_EEG.event.latency];
            all_events_type={F_EEG.event.type};
            
            temp = find(ismember(all_events_type, '99'));
            if(c==1)
                all_events_type(temp) = {'41'};
            else
                all_events_type(temp) = {'42'};
            end
            
            % for subject 15
            if(ss==15)
                S_speech_latency(38) = NaN;
            end
            %% match original with final eeg event data
            
            % chane because final eeg file has always speech in 41 and listen in 42
            % in each listen and speech condition trial the markers are listen condition = [42 31] speech condition = [41 32]
            
            S_visual = '32';
            S_speech = '41';
            L_visual = '31';
            L_speech = '42';
            
            Final_SS = find(ismember(all_events_type, S_speech));
            Final_SV = find(ismember(all_events_type, S_visual));
            Final_LV = find(ismember(all_events_type, L_visual));
            Final_LS = find(ismember(all_events_type, L_speech));
            
            original_SS = find(~isnan(S_speech_latency));
            original_SV = find(~isnan(S_visual_latency));
            original_LV = find(~isnan(L_visual_latency));
            original_LS = find(~isnan(L_speech_latency));
            
            % check by plotting
            %                 a=S_speech_latency;
            %                 a(isnan(a))=[];
            %                 plot(a,'.b');hold on;plot(all_events_latency(Final_SS),'.r');
            %                 aa = find(ismember( all_events_type(1:401), '41'));
            %                 aaa= find(isnan(S_speech_latency(1:50)));
            %                 aa = all_events_latency(aa);
            %                 aa = [aa(1:8) NaN aa(9:30) NaN NaN aa(31:34) NaN aa(35:end)];
            %                 plot(S_speech_latency(1:50),'.-b');hold on;plot(aa,'.-r');
            %                 set(gca,'XTick',1:50);grid minor;
            %                 ax=gca;
            %                 ax.MinorGridAlpha = 0.1;
            
            if(c==1)
                if(length(Final_SS) == length(original_SS) )
                    trial_start = find(ismember(all_events_type, 'speech_start'));
                    temp = trial_start+1;
                    
                    a = ismember(Final_SS,temp);
                    b = original_SS(a);
                    
                    % get EEG data of trials
                    trial_end = find(ismember(all_events_type, 'speech_end'));
                    trial_latency = [all_events_latency(trial_start); all_events_latency(trial_end);all_events_latency(temp)]; % trial start, end, speech index
                    trial_events_index = [trial_start];
                    %%
                    % bad files for subject 1 extra (AHH)
                    if(ss == 2)
                        bad_idx = [1 2 99 151]; %bad index for subject 2
                        bad_idx = [1 2]; %bad index for subject 2
                        
                        for n=1:length(bad_idx)
                            idx = find(b==bad_idx(n));
                            b(idx) = 0;
                            trial_latency(:,idx) = 0;
                        end
                        b(find(b==0))=[];
                        
                        %                     idx1 = find(b>bad_idx(3));          % shifting for session 3 and 4
                        %                     b(idx1:end) = b(idx1:end)-1;
                        %                     idx1 = find(b>bad_idx(4));
                        %                     b(idx1:end) = b(idx1:end)-1;
                        
                        trial_events_index(:, find(sum(abs(trial_latency)) == 0)) = [];
                        trial_latency(:, find(sum(abs(trial_latency)) == 0)) = [];
                    elseif(ss==4)
                        %                     bad_idx = [101 153]; %bad index for subject 4
                        %                     for n=1:length(bad_idx)
                        % %                         idx1 = find(b>bad_idx(n));
                        % %                         b(idx1:end) = b(idx1:end)-1;
                        %                         idx = find(b==bad_idx(n));
                        %                         b(idx) = 0;
                        %                         trial_latency(:,idx) = 0;
                        %                     end
                        %                     b(find(b==0))=[];
                        %
                        %                     idx1 = find(b>bad_idx(1));      % shifting for session 3 and 4
                        %                     b(idx1:end) = b(idx1:end)-1;
                        %                     idx1 = find(b>bad_idx(2));
                        %                     b(idx1:end) = b(idx1:end)-1;
                        
                        trial_events_index(:, find(sum(abs(trial_latency)) == 0)) = [];
                        trial_latency(:, find(sum(abs(trial_latency)) == 0)) = [];
                    end
                    %% EEG data trial
                    session_eeg_speech = pop_epoch(F_EEG,project.eeg.duet.speech.condition_EEG_marker,[project.eeg.duet.speech.trial_Start project.eeg.duet.speech.trial_End]);
                    
                    % baseline correction
                    B_EEG = pop_loadset(project.subjects.data(ss).baseline_file);
                    session_eeg_speech_baseline = pop_epoch(B_EEG,{project.eeg.duet.baselineS},[0 baseline_end_time]);
                    mbs                 = mean(session_eeg_speech_baseline.data(:, :,:),2); %       mbs:        channel, 1,   epochs
                    baseline            = repmat(mbs,1,session_eeg_speech.pnts);                                            %       baseline:   channel, pnt, epoch
                    
                    if(session_eeg_speech.trials<size(baseline,3))
                        %                         session_eeg_speech.data            = session_eeg_speech.data-baseline(:,:,1:session_eeg_speech.trials);
                        baseline            = baseline(:,:,1:session_eeg_speech.trials);
                        
                    elseif(session_eeg_speech.trials>size(baseline,3))
                        repeat_size = ceil(session_eeg_speech.trials/size(baseline,3));
                        if (repeat_size == 0)
                            repeat_size=1;
                        end
                        baseline = repmat(baseline,[1 1 repeat_size]);
                        %                         session_eeg_speech.data            = session_eeg_speech.data-baseline(:,:,1:session_eeg_speech.trials);
                        baseline            = baseline(:,:,1:session_eeg_speech.trials);
                        
                    else
                        %                         session_eeg_speech.data            = session_eeg_speech.data-baseline;
                        baseline            = baseline(:,:,1:session_eeg_speech.trials);
                        
                    end
                    
                    %
                    for d=1:size(trial_latency,2)
                        temp11(:,:,1) = session_eeg_speech.data(:,:,d);
                        temp11(:,:,2) = baseline(:,:,d);
                        data{b(d),1} = temp11;
                    end
                    
                    % get speech marker sample point
                    ALL(b,1) = floor(trial_latency(3,:)) - floor(trial_latency(1,:));
                    
                    ALL_index(b,1) = trial_events_index';
                end
            else
                if(length(Final_LS) == length(original_LS) )
                    trial_start = find(ismember(all_events_type, 'listen_start'));
                    temp = trial_start+1;
                    
                    a = ismember(Final_LS,temp);
                    b = original_LS(a);
                    
                    % get EEG data of trials
                    trial_end = find(ismember(all_events_type, 'listen_end'));
                    trial_latency = [all_events_latency(trial_start); all_events_latency(trial_end);all_events_latency(temp)]; % trial start, end, speech index
                    trial_events_index = [trial_start];
                    % bad files for subject 1 extra (AHH)
                    if(ss == 1)
                        bad_idx = [1 100 152]; %bad index for subject 1
                        bad_idx = [1 ]; %bad index for subject 1
                        
                        for n=1:length(bad_idx)
                            idx = find(b==bad_idx(n));
                            b(idx) = 0;
                            trial_latency(:,idx) = 0;
                        end
                        b(find(b==0))=[];
                        
                        %                     idx1 = find(b>bad_idx(2));      % shifting for session 3 and 4
                        %                     b(idx1:end) = b(idx1:end)-1;
                        %                     idx1 = find(b>bad_idx(3));
                        %                     b(idx1:end) = b(idx1:end)-1;
                        
                        
                        trial_events_index(:, find(sum(abs(trial_latency)) == 0)) = [];
                        trial_latency(:, find(sum(abs(trial_latency)) == 0)) = [];
                    elseif(ss==3)
                        %                     bad_idx = [101 153]; %bad index for subject 4
                        %                     for n=1:length(bad_idx)
                        % %                         idx1 = find(b>bad_idx(n));      % -1 beacuse of indexing
                        % %                         b(idx1:end) = b(idx1:end)-1;
                        %                         idx = find(b==bad_idx(n));
                        %                         b(idx) = 0;
                        %                         trial_latency(:,idx) = 0;
                        %                     end
                        %                     b(find(b==0))=[];
                        %
                        %                     idx1 = find(b>bad_idx(1));  % shifting for session 3 and 4
                        %                     b(idx1:end) = b(idx1:end)-1;
                        %                     idx1 = find(b>bad_idx(2));
                        %                     b(idx1:end) = b(idx1:end)-1;
                        
                        trial_events_index(:, find(sum(abs(trial_latency)) == 0)) = [];
                        trial_latency(:, find(sum(abs(trial_latency)) == 0)) = [];
                    end
                    
                    %% EEG data trial
                    session_eeg_listen = pop_epoch(F_EEG,project.eeg.duet.listen.condition_EEG_marker,[project.eeg.duet.listen.trial_Start project.eeg.duet.listen.trial_End]);
                    
                    % baseline correction
                    B_EEG = pop_loadset(project.subjects.data(ss).baseline_file);
                    session_eeg_listen_baseline = pop_epoch(B_EEG,{project.eeg.duet.baselineS},[0 baseline_end_time]);
                    mbs                 = mean(session_eeg_listen_baseline.data(:, :,:),2); %       mbs:        channel, 1,   epochs
                    baseline            = repmat(mbs,1,session_eeg_listen.pnts);                                            %       baseline:   channel, pnt, epoch
                    
                    if(session_eeg_listen.trials<size(baseline,3))
                        %                         session_eeg_listen.data            = session_eeg_listen.data-baseline(:,:,1:session_eeg_listen.trials);
                        baseline            = baseline(:,:,1:session_eeg_listen.trials);
                    elseif(session_eeg_listen.trials>size(baseline,3))
                        repeat_size = ceil(session_eeg_listen.trials/size(baseline,3));
                        if (repeat_size == 0)
                            repeat_size=1;
                        end
                        baseline = repmat(baseline,[1 1 repeat_size]);
                        %                         session_eeg_listen.data            = session_eeg_listen.data-baseline(:,:,1:session_eeg_listen.trials);
                        baseline            = baseline(:,:,1:session_eeg_listen.trials);
                        
                    else
                        %                         session_eeg_listen.data            = session_eeg_listen.data-baseline;
                        baseline            = baseline(:,:,1:session_eeg_listen.trials);
                        
                    end
                    
                    %
                    for d=1:size(trial_latency,2)
                        temp11(:,:,1) = session_eeg_listen.data(:,:,d);
                        temp11(:,:,2) = baseline(:,:,d);
                        data{b(d),2} = temp11;
                    end
                    
                    ALL(b,2) = floor(trial_latency(3,:)) - floor(trial_latency(1,:));
                    ALL_index(b,2) = trial_events_index';
                end
            end
            %% which word is present in the EGG data
            bb= [];ids = 50;pids=0;
            for sess = 1:4
                aa = b(find(b>pids & b<=ids));
                if(sess ~= 1)
                    bb{sess} = aa-pids;
                else
                    bb{sess} = aa;
                end
                pids = ids;
                ids = ids + 50;
            end
            all_session_index{ss,c} = bb;
            b=[];
        else
            % for bad files
            if(ss == 8 )
                temp_O_path = project.eeg.solo_pre.other_path;
            else
                temp_O_path = project.eeg.solo_pre.O_path;
            end
            [data_prepost{ss,1}, b_prepost{ss,1}] = check_solo_EEG_beforeNafterICA(subj_name,temp_O_path,project.eeg.solo_pre.F_path,'pre','21',project);
            [data_prepost{ss,2}, b_prepost{ss,2}] = check_solo_EEG_beforeNafterICA(subj_name,project.eeg.solo_post.O_path,project.eeg.solo_post.F_path,'post','22',project);
            
        end
    end
    all_subj(:,sss:sss+1) = ALL;
    all_eeg(:,sss:sss+1) = data;
    all_index(:,sss:sss+1) = ALL_index;
    sss=sss+2;
end

%% format as same structure as \processed_data_word_level.mat (D)
load([project.paths.processedData '\processed_data_word_level.mat']);


EEG = cell(size(D,1),2);
EEG_idx = zeros(size(D,1),2);
EEG_idx1 = zeros(size(D,1),2);

%%duet
j=40;
for i = 1:2:size(all_eeg,2)
    a = all_eeg(:,i:i+1);
    b = all_subj(:,i:i+1);
    c = all_index(:,i:i+1);
    EEG(j+1:j+200,1:2) = a;
    EEG_idx(j+1:j+200,1:2) = b;
    EEG_idx1(j+1:j+200,1:2) = c;
    j=j+280;
end

%%pre post
j=0;
for i = 1:16
    a = data_prepost{i,1};
    EEG(j+1:j+40,1) = a;
    j=j+240;
    
    a = data_prepost{i,2};
    EEG(j+1:j+40,1) = a;
    j=j+40;
end


EEG_data = [EEG num2cell(EEG_idx) num2cell(EEG_idx1)];
speech_eeg_times = session_eeg_speech.times;
listen_eeg_times = session_eeg_listen.times;

speech.xmin = session_eeg_speech.xmin;
speech.xmax = session_eeg_speech.xmax;

chanlist        = {session_eeg_speech.chanlocs.labels};
chanlocs        = session_eeg_speech.chanlocs;



save([project.paths.processedData '\EEG.mat'],'EEG_data','all_session_index','speech_eeg_times','listen_eeg_times','b_prepost','chanlist','chanlocs');






