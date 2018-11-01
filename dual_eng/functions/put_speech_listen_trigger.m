function project = put_speech_listen_trigger(project,subj,worksapce_path)

list_select_subjects = {project.subjects.data.name};

subj_name=list_select_subjects{subj};
if(strcmp(project.conf_file_name,'project_structure_study_duet_listen') || strcmp(project.conf_file_name,'project_structure_study_duet_speech'))
    filename = [worksapce_path project.subjects.data(1,subj).name '_duet_raw_mc.set'];
    % copy from backup ICA
    copyfile([project.paths.backupICA '\' subj_name '_duet_raw_mc.set'],filename);
    copyfile([project.paths.backupICA '\' subj_name '_duet_raw_mc.fdt'],strrep(filename,'.set','.fdt'));
    
    %% only for first 4 subjects removing AHH
    if(strcmp(subj_name,'01_riccardo')|| strcmp(subj_name,'02_dino')|| strcmp(subj_name,'03_luigi')|| strcmp(subj_name,'04_alessandro'))
        EEG = pop_loadset(filename);
        all_events_type={EEG.event.type};
        start_idx = find(ismember(all_events_type, '3'));
        end_idx = find(ismember(all_events_type, '2'));
        temp = find(ismember(all_events_type, 'boundary'));
        
        if(strcmp(all_events_type(start_idx(3)+1),'31') && strcmp(all_events_type(start_idx(3)+2),'41'))
            EEG.event(start_idx(3)+1).type = '77';
            EEG.event(start_idx(3)+2).type = '78';
            EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
            EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
            
        end
        if(strcmp(all_events_type(start_idx(4)+1),'31') && strcmp(all_events_type(start_idx(4)+2),'41'))
            EEG.event(start_idx(4)+1).type = '77';
            EEG.event(start_idx(4)+2).type = '78';
            EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
            EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
            
        end
    end
    
    %% swap speaking to listining marker according to subjects sides
    if(strcmp(project.conf_file_name,'project_structure_study_duet_listen'))
        if(strcmp(subj_name,'01_riccardo') || strcmp(subj_name,'03_luigi') || strcmp(subj_name,'05_nicholas') ...
                || strcmp(subj_name,'07_chiara') || strcmp(subj_name,'09_alice') || strcmp(subj_name,'12_sara')...
                || strcmp(subj_name,'13_luca') || strcmp(subj_name,'15_valentina'))
            
            eeglab_subject_events_rename(filename, {'41'},{'99'});      % listen in those subjects
            eeglab_subject_events_rename(filename, {'42'},{'41'});
            eeglab_subject_events_rename(filename, {'99'},{'42'});
            
            eeglab_subject_events_rename(filename, {'32'},{'99'});      % speech visual in those subjects
            eeglab_subject_events_rename(filename, {'31'},{'32'});
            eeglab_subject_events_rename(filename, {'99'},{'31'});
            
            eeglab_subject_events_rename(filename, {'42'},{'99'});      % rename to select the correct sequence
            eeglab_subject_events_rename(filename, {'5'},{'88'});       % rename to select the correct sequence
            
            eeglab_subject_events_add_event_around_other_events(filename, '31', 'le', project.eeg.duet.listen.trial_End);
            eeglab_subject_events_add_event_around_other_events(filename, '99', 'ls', project.eeg.duet.listen.trial_Start);
            duet_subject_check_events_seq(filename,{'ls','99', '88','31','le'},{'listen_start','42','5','listen_end'});
        else
            eeglab_subject_events_rename(filename, {'42'},{'99'});
            eeglab_subject_events_rename(filename, {'5'},{'88'});
            
            eeglab_subject_events_add_event_around_other_events(filename, '31', 'le', project.eeg.duet.listen.trial_End);
            eeglab_subject_events_add_event_around_other_events(filename, '99', 'ls', project.eeg.duet.listen.trial_Start);
            duet_subject_check_events_seq(filename,{'ls','99', '88','31','le'},{'listen_start','42','5','listen_end'});
        end
        
    elseif(strcmp(project.conf_file_name,'project_structure_study_duet_speech'))
        if(strcmp(subj_name,'01_riccardo') || strcmp(subj_name,'03_luigi') || strcmp(subj_name,'05_nicholas') ...
                || strcmp(subj_name,'07_chiara') || strcmp(subj_name,'09_alice') || strcmp(subj_name,'12_sara')...
                || strcmp(subj_name,'13_luca') || strcmp(subj_name,'15_valentina'))
            
            eeglab_subject_events_rename(filename, {'42'},{'99'});      % speech in those subjects
            eeglab_subject_events_rename(filename, {'41'},{'42'});
            eeglab_subject_events_rename(filename, {'99'},{'41'});
            
            eeglab_subject_events_rename(filename, {'32'},{'99'});      % speech visual in those subjects
            eeglab_subject_events_rename(filename, {'31'},{'32'});
            eeglab_subject_events_rename(filename, {'99'},{'31'});
            
            eeglab_subject_events_rename(filename, {'41'},{'99'});
            eeglab_subject_events_rename(filename, {'5'},{'88'});
            
            eeglab_subject_events_add_event_around_other_events(filename, '32', 'se', project.eeg.solo.speech.trial_End);
            eeglab_subject_events_add_event_around_other_events(filename, '99', 'ss', project.eeg.solo.speech.trial_Start);
            duet_subject_check_events_seq(filename,{'ss','99', '88','32','se'},{'speech_start','41','5','speech_end'});
        else
            eeglab_subject_events_rename(filename, {'41'},{'99'});
            eeglab_subject_events_rename(filename, {'5'},{'88'});
            
            eeglab_subject_events_add_event_around_other_events(filename, '32', 'se', project.eeg.solo.speech.trial_End);
            eeglab_subject_events_add_event_around_other_events(filename, '99', 'ss', project.eeg.solo.speech.trial_Start);
            duet_subject_check_events_seq(filename,{'ss','99', '88','32','se'},{'speech_start','41','5','speech_end'});
        end
    end
    
    
    % different marker for different session
    EEG = pop_loadset(filename);
    all_events_type={EEG.event.type};
    start_idx = find(ismember(all_events_type, '3'));
    end_idx = find(ismember(all_events_type, '2'));
    
    if(strcmp(subj_name,'14_fabio'))
        temp = find(ismember(all_events_type, 'boundary'));
        start_idx = [start_idx(1) temp(7) start_idx(2:end)];
        end_idx = [temp(7) end_idx(1:end)];
    elseif(strcmp(subj_name,'08_jessica'))
        temp = find(ismember(all_events_type, 'boundary'));
        start_idx = [start_idx temp(16) temp(23)];
        end_idx = [end_idx(1) temp(15) temp(23) end_idx(end)];
        %             elseif(strcmp(subj_name,'02_dino'))
        %                 temp = find(ismember(all_events_type, 'boundary'));
        %                 start_idx = [start_idx temp(48)];
        %                 end_idx = [end_idx(1:2) temp(48) end_idx(end)];
    end
    
    
    EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
    
    %% swap electrods  when the first electrodes cable is plugged into the
    % second plug (14_fabio 16_mariacarla)
    
    filename = [EEG.filepath '\' EEG.filename];
    if(strcmp(subj_name,'14_fabio') || strcmp(subj_name,'16_mariacarla'))
        eeglab_subject_swap_two_halves_electrodes(filename,filename);
    end
    
    %% baseline copy from backup
    
    subj_name_b = [list_select_subjects{subj} '_baseline'];
    filename_baseline = project.subjects.data(subj).baseline_file;
    
    % extend base line for these subjects because they have little
    if(strcmp(subj_name_b,'01_riccardo_baseline') || strcmp(subj_name_b,'02_dino_baseline') ...
            || strcmp(subj_name_b,'03_luigi_baseline')  || strcmp(subj_name_b,'04_alessandro_baseline'))
        
        copyfile([project.paths.backupICA_baseline_initial '\' subj_name_b '_duet_raw.set'],filename_baseline);
        copyfile([project.paths.backupICA_baseline_initial '\' subj_name_b '_duet_raw.fdt'],strrep(filename_baseline,'.set','.fdt'));
        
        EEG = pop_loadset(filename_baseline);
        O_EEG = pop_loadset(filename_baseline);
        for rep=1:50
            %                     EEG.data(:,end+1:end+size(O_EEG.data,2)) = O_EEG.data(:,:);
            disp(rep);
            EEG = pop_mergeset(EEG,O_EEG);
        end
        EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
        EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
        
    else
        copyfile([project.paths.backupICA_baseline '\' subj_name_b '_duet_raw_mc.set'],filename_baseline);
        copyfile([project.paths.backupICA_baseline '\' subj_name_b '_duet_raw_mc.fdt'],strrep(filename_baseline,'.set','.fdt'));
    end
    
    
    
    %% mark baseline
    
    target_events_file  = filename;
    baseline_file       = project.subjects.data(subj).baseline_file;
    
    EEG_target          = pop_loadset(target_events_file);
    EEG_baseline        = pop_loadset(baseline_file);
    
    OUTEEG = EEG_baseline;
    project.subjects.baseline_file_interval_s = 1;
    
    baseline_file_interval_pts      =  floor(project.subjects.baseline_file_interval_s * OUTEEG.srate);
    if(strcmp(project.conf_file_name,'project_structure_study_duet_listen'))
        project.epoching.baseline_duration.s = 0 - project.eeg.duet.listen.trial_Start;
    elseif(strcmp(project.conf_file_name,'project_structure_study_duet_speech'))
        project.epoching.baseline_duration.s = project.eeg.duet.speech.trial_End - 0;
    end
    
    baseline_duration_pts           =  floor(project.epoching.baseline_duration.s * OUTEEG.srate);
    
    list_eve_target = {EEG_target.event.type};
    eve_target_baseline = EEG_target.event;
    
    for neve = 1:length(list_eve_target)
        
        lat1 = baseline_file_interval_pts(1) + (neve-1) *floor(baseline_file_interval_pts/2);
        lat2 = lat1 + baseline_duration_pts;
        
        n1 = length(OUTEEG.event)+1;
        n2 = length(OUTEEG.event)+2;
        
        OUTEEG.event(n1)         =   eve_target_baseline(neve);
        OUTEEG.event(n1).latency =   lat1;
        OUTEEG.event(n1).type    =   project.eeg.duet.baselineS;
        
        OUTEEG.event(n2)         =   eve_target_baseline(neve);
        OUTEEG.event(n2).latency =   lat2;
        OUTEEG.event(n2).type    =   '5';
        
    end
    
    OUTEEG = eeg_checkset(OUTEEG);
    OUTEEG              = pop_saveset(OUTEEG, 'filename',OUTEEG.filename, 'filepath', OUTEEG.filepath);
    
    
    % pre post
elseif(strcmp(project.conf_file_name,'project_structure_study_solo_visual') || strcmp(project.conf_file_name,'project_structure_study_solo_speech'))
    
    filename_pre   = ['C:\Users\SMukherjee\Desktop\data\dual_eeg\MNI\sankar\spic\epochs\solo_pre\04_mc\' subj_name '_solo_pre_raw_mc.set'];
    filename_post   = ['C:\Users\SMukherjee\Desktop\data\dual_eeg\MNI\sankar\spic\epochs\solo_post\04_mc\' subj_name '_solo_post_raw_mc.set'];
    
    % copy from backup ICA
    copyfile([project.paths.backupICA_pre '\' subj_name '_solo_pre_raw_mc.set'],filename_pre);
    copyfile([project.paths.backupICA_pre '\' subj_name '_solo_pre_raw_mc.fdt'],strrep(filename_pre,'.set','.fdt'));
    copyfile([project.paths.backupICA_post '\' subj_name '_solo_post_raw_mc.set'],filename_post);
    copyfile([project.paths.backupICA_post '\' subj_name '_solo_post_raw_mc.fdt'],strrep(filename_post,'.set','.fdt'));
    
    % add missing marker
    if(strcmp(subj_name,'05_nicholas') || strcmp(subj_name,'06_garrlo') || strcmp(subj_name,'07_chiara') ...
            || strcmp(subj_name,'08_jessica')|| strcmp(subj_name,'09_alice')|| strcmp(subj_name,'11_anna')...
            || strcmp(subj_name,'12_sara') || strcmp(subj_name,'13_luca')|| strcmp(subj_name,'14_fabio')...
            || strcmp(subj_name,'15_valentina')|| strcmp(subj_name,'16_mariacarla')|| strcmp(subj_name,'10_mrium'))
        
        eeglab_subject_events_add_event_around_other_events(filename_pre, {'10'}, '11' , 0.05);
        
    end
    
    % swap elcetrodes halve
    if(strcmp(subj_name,'14_fabio') || strcmp(subj_name,'16_mariacarla'))
        eeglab_subject_swap_two_halves_electrodes(filename_pre,filename_pre);
        eeglab_subject_swap_two_halves_electrodes(filename_post,filename_post);
    end
    
    % mark good trials
    if(strcmp(project.conf_file_name,'project_structure_study_solo_visual'))
        % % Add 'visual_end' trigger after 500 ms after visual stimuli
        %pre
        eeglab_subject_events_add_event_around_other_events(filename_pre, '11', 'le', project.eeg.duet.listen.trial_End);
        eeglab_subject_events_add_event_around_other_events(filename_pre, '11', 'ls', project.eeg.duet.listen.trial_Start);
        eeglab_subject_events_rename(filename_pre, {'11'},{'99'});
        solo_subject_check_events_seq(filename_pre,{'ls','99','le'},{'visual_start','11','visual_end'});
        
        %post
        eeglab_subject_events_add_event_around_other_events(filename_post, '12', 'le', project.eeg.duet.listen.trial_End);
        eeglab_subject_events_add_event_around_other_events(filename_post, '12', 'ls', project.eeg.duet.listen.trial_Start);
        eeglab_subject_events_rename(filename_post, {'12'},{'99'});
        solo_subject_check_events_seq(filename_post,{'ls','99','le'},{'visual_start','12','visual_end'});
        
    elseif(strcmp(project.conf_file_name,'project_structure_study_solo_speech'))
        % % Add 'speech_start' trigger before 500 ms of voice onset
        
        %pre
        eeglab_subject_events_add_event_around_other_events(filename_pre, '21', 'le', project.eeg.solo.speech.trial_End);
        eeglab_subject_events_add_event_around_other_events(filename_pre, '21', 'ls', project.eeg.solo.speech.trial_Start);
        eeglab_subject_events_rename(filename_pre, {'21'},{'99'});
        solo_subject_check_events_seq(filename_pre,{'ls','99','le'},{'speech_start','21','speech_end'});
        
        %post
        eeglab_subject_events_add_event_around_other_events(filename_post, '22', 'le', project.eeg.solo.speech.trial_End);
        eeglab_subject_events_add_event_around_other_events(filename_post, '22', 'ls', project.eeg.solo.speech.trial_Start);
        eeglab_subject_events_rename(filename_post, {'22'},{'99'});
        solo_subject_check_events_seq(filename_post,{'ls','99','le'},{'speech_start','22','speech_end'});
    end
    
      
end
end
