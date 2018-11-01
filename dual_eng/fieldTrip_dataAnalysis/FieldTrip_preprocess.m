function clean_data = FieldTrip_preprocess(filename,sub,partner,project,time_window,cond,D)

eeg_data_path = 'C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eeg\MNI\sankar\spic\original_data\';
eeg_dest_path = 'C:\Users\SMukherjee\Desktop\projects\dual_eeg_eng\data\dual_eeg\MNI\sankar\spic\epochs\fieldtrip\';

dataset = [eeg_data_path filename '_duet.bdf'];

%% experiment specific change
if(strcmp(cond,'speech'))
    if(mod(sub,2))
        target_trigger = 42;
    else
        target_trigger = 41;
    end
    if(sub == 11)
        target_trigger = 41;
    elseif(sub == 12)
        target_trigger = 42;
    end
    
    %     cfg.idx = find(D(:,1)==sub & (D(:,2) == 2 | D(:,2) == 3 | D(:,2) == 4 | D(:,2) == 5));
    cfg.idx = [(sub-1)*280+41:(sub-1)*280+240]';
    
    
else
    if(mod(sub,2))
        target_trigger = 41;
    else
        target_trigger = 42;
    end
    if(sub == 11)
        target_trigger = 42;
    elseif(sub == 12)
        target_trigger = 41;
    end
    
    cfg.idx = [(partner-1)*280+41:(partner-1)*280+240]';
    
    %         cfg.idx = find(D(:,1)== partner & (D(:,2) == 2 | D(:,2) == 3 | D(:,2) == 4 | D(:,2) == 5));
end



%% automatic artifact rejection
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 40;
cfg.hpfilter        = 'yes';
cfg.hpfreq          = 1;
cfg.dftfilter       = 'yes';
cfg.headerformat       = 'biosemi_bdf';
cfg.dataformat         = 'biosemi_bdf';
cfg.trialdef.eventtype = 'STATUS';
cfg.trialdef.eventvalue     = target_trigger; % the value of the stimulus trigger for fully incongruent (FIC).
cfg.trialdef.prestim        = 1; % in seconds
cfg.trialdef.poststim       = 1; % in seconds
cfg.channelread             = {'EEG','-Status'};
cfg.badchannel    = project.subjects.data(sub).bad_ch;

cfg.time_window = time_window;


clean_data = EEG_automatic_artifact_reject(dataset,cfg);

%% swap the first half of the electrodes (eg. 1-32) witht the second half (33-64).

if(sub == 14 | sub == 16)
    temp = clean_data.trial;
    
    for t = 1:length(temp)
        a = temp{1,t};
        temp{1,t} = [a(33:end,:); a(1:32,:)];
    end
    clean_data.trial = temp;
    
end









end