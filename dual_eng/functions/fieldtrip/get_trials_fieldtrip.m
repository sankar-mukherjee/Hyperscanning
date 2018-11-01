function data_conv = get_trials_fieldtrip(EEG_data,EEG,sub_idx,conv_idx,config,baseline,convergence_data)
%%
if(strcmp(config.type,'speech'))
    no = 1;
elseif(strcmp(config.type,'listen'))
    no = 2;
end


u_sub_idx = unique(sub_idx);

data_conv = [];
for i = 1:length(u_sub_idx)
    index = find(sub_idx==u_sub_idx(i));
    target_trials = EEG_data(conv_idx(index),no);
    remove_index = find(cellfun('isempty',target_trials));
    index(remove_index) = [];
    target_trials = target_trials(~cellfun('isempty',target_trials),1);
    
    if not(isempty(target_trials))
        temp = [];
        for ii=1:length(target_trials)
            if(baseline)
                temp{ii,1} = target_trials{ii}(:,:,1) - target_trials{ii}(:,:,2);   %baseline corrected
            else
                temp{ii,1} = target_trials{ii}(:,:,1);
            end
        end
        EEG.data = cat(3,temp{:});
        
        %% trial to filedtrip creation
        EEG.chanlocs = config.chanlocs;
        EEG.srate    = config.eegrate;
        EEG.xmin = config.times(1)/1e3;
        EEG.xmax = config.times(end)/1e3;
        EEG.times = config.times/1e3;
        if(exist('convergence_data','var'))
            EEG.trialinfo = [index conv_idx(index) convergence_data(conv_idx(index),1)];
        else
            EEG.trialinfo = [index conv_idx(index) ];
        end
        
        data_conv{u_sub_idx(i),1} = create_fieldtrip_trials(EEG);
    end
end