%%  check for event cosistency and insert the trial start and end marker

%%
function EEG = solo_subject_check_events_seq(input_file_name, code_seq,replace_marker)

                                                    
    EEG = pop_loadset(input_file_name);

        all_events_type={EEG.event.type};

        numev = size(all_events_type, 2);
        for ev=1:(numev)
            if (strcmp(all_events_type{ev}, code_seq{1}))                
                if(ev+length(code_seq) < numev)
                    temp = [];
                    for cd=1:length(code_seq)
                        temp{cd} = all_events_type{ev+cd-1};
                    end
                    
                    if(sum(ismember(code_seq,temp)) == length(code_seq))
                        EEG.event(ev).type = replace_marker{1};
                        EEG.event(ev+1).type = replace_marker{2};
                        EEG.event(ev+2).type = replace_marker{3};
%                         EEG.event(ev+4).type = replace_marker{4};
%                         EEG.event(ev+cd-1).type = replace_marker{5};
                    end
                end
            end
        end
    
    
    EEG = eeg_checkset(EEG, 'eventconsistency'); % Check all events for consistency
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath',EEG.filepath);
    
    
end