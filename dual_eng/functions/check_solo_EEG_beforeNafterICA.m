function [data, b] = check_solo_EEG_beforeNafterICA(subj_name,O_path,F_path,cond_name,eeg_marker,project)
data = cell(40,1);
b=[];
%%

O_file_name = [O_path subj_name '_solo_' cond_name '_raw.set'];
O_EEG = pop_loadset(O_file_name);

F_file_name = [F_path subj_name '_solo_' cond_name '_raw_mc.set'];
F_EEG = pop_loadset(F_file_name);

all_events_latency=[O_EEG.event.latency];
all_events_type={O_EEG.event.type};


temp = find(ismember(all_events_type, eeg_marker));
S_speech_latency = all_events_latency(temp);

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
        S_speech_latency(SS) = NaN;
    end
    for j=1:size(removed_part,1)
        % remove the same amount from the  arrays
        if(j==size(removed_part,1))
            SS = find(S_speech_latency > removed_part(j,2));
        else
            SS = find(S_speech_latency > removed_part(j,2) & S_speech_latency < removed_part(j+1,1));
        end
        previous_diff = previous_diff + diff(removed_part(j,:));
        
        S_speech_latency(SS) = S_speech_latency(SS) - previous_diff;
    end
end

%% rename markers
all_events_latency=[F_EEG.event.latency];
all_events_type={F_EEG.event.type};

temp = find(ismember(all_events_type, '99'));
if(strcmp(cond_name,'pre'))
    all_events_type(temp) = {'21'};
    S_speech = '21';
    
else
    all_events_type(temp) = {'22'};
    S_speech = '22';
    
end


%% match original with final eeg event data
Final_SS = find(ismember(all_events_type, S_speech));
original_SS = find(~isnan(S_speech_latency));

if(length(Final_SS) == length(original_SS))
    trial_start = find(ismember(all_events_type, 'speech_start'));
    temp = trial_start+1;
    
    a = ismember(Final_SS,temp);
    b = original_SS(a);
    
    % get EEG data of trials
    trial_end = find(ismember(all_events_type, 'speech_end'));
    trial_latency = [all_events_latency(trial_start); all_events_latency(trial_end);all_events_latency(temp)]; % trial start, end, speech index
    
    %% EEG data trial
    session_eeg = pop_epoch(F_EEG,{S_speech},[project.eeg.solo.speech.trial_Start project.eeg.solo.speech.trial_End]);
    
    % baseline correction
    session_eeg_baseline = pop_epoch(F_EEG,{'9'},[0 0.4]);
    mbs                 = mean(session_eeg_baseline.data(:, :,:),2); %       mbs:        channel, 1,   epochs
    baseline            = repmat(mbs,1,session_eeg.pnts);                                            %       baseline:   channel, pnt, epochs
    if(session_eeg.trials<size(baseline,3))
        %         session_eeg.data            = session_eeg.data-baseline(:,:,1:session_eeg.trials);
        baseline = baseline(:,:,1:session_eeg.trials);
    elseif(session_eeg.trials>size(baseline,3))
        repeat_size = ceil(session_eeg.trials/size(baseline,3));
        if (repeat_size == 0)
            repeat_size=1;
        end
        baseline = repmat(baseline,[1 1 repeat_size]);
%         session_eeg.data            = session_eeg.data-baseline(:,:,1:session_eeg.trials);
        baseline = baseline(:,:,1:session_eeg.trials);
    else
%         session_eeg.data            = session_eeg.data-baseline;
        baseline = baseline(:,:,1:session_eeg.trials);
    end
    
    %%
    if(strcmp(subj_name,'01_riccardo')|| strcmp(subj_name,'02_dino')|| strcmp(subj_name,'03_luigi')|| strcmp(subj_name,'04_alessandro'))
        %% bad 1 2 3 4 subjects
        lable_path = 'C:\Users\SMukherjee\Desktop\data\label_creation\prompts\';
        if(strcmp(subj_name,'01_riccardo'))
            traget_file_name = ['01_' cond_name];
        elseif(strcmp(subj_name,'02_dino'))
            traget_file_name = ['02_' cond_name];
        elseif(strcmp(subj_name,'03_luigi'))
            traget_file_name = ['03_' cond_name];
        elseif(strcmp(subj_name,'04_alessandro'))
            traget_file_name = ['04_' cond_name];
        end
        text_filename = [lable_path traget_file_name];
        [id,words] = import_prompts(text_filename);
        temp_f = strrep(id,['*/' traget_file_name '-'],'');
        index =[];
        for tt=1:length(temp_f)
            index = [index;str2num(temp_f{tt})];
        end
        special_index = intersect(index,b);
        a = find(ismember(index,special_index));
        dd = find(ismember(b,special_index));
        for d=1:length(a)
            temp11(:,:,1) = session_eeg.data(:,:,d);
            temp11(:,:,2) = baseline(:,:,d);
            data{a(d),1} = temp11;
        end
        b=a;
    else
        for d=1:size(trial_latency,2)
            temp11(:,:,1) = session_eeg.data(:,:,d);
            temp11(:,:,2) = baseline(:,:,d);
            data{b(d),1} = temp11;
        end
    end
    
end

end