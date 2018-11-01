function target_data = EEG_automatic_artifact_reject(dataset,config)
%% automatic artifact rejection

cfg                    = [];
cfg.dataset            = dataset;
cfg.lpfilter        = config.lpfilter;
cfg.lpfreq          = config.lpfreq;
cfg.hpfilter        = config.hpfilter;
cfg.hpfreq          = config.hpfreq;
cfg.dftfilter       = config.dftfilter;
cfg.headerformat       = config.headerformat;
cfg.dataformat         = config.dataformat;
cfg.trialdef.eventtype = config.trialdef.eventtype;
cfg.trialdef.eventvalue     = config.trialdef.eventvalue; % the value of the stimulus trigger for fully incongruent (FIC).
cfg.trialdef.prestim        = config.trialdef.prestim; % in seconds
cfg.trialdef.poststim       = config.trialdef.poststim; % in seconds
cfg.trialfun = 'mytrialfun';

cfg                    = ft_definetrial(cfg);
% cfg.trialdef.eventtype = '?';

cfg.continuous = 'yes';
cfg.channel    = config.channelread;
% cfg.padding  = 0.2;
target_data = ft_preprocessing(cfg);

orginal_channel = target_data.hdr.label;

id = 1:200;
id = reshape([id;id],400,1);
id = [id [1:400]']; 
target_data.trialinfo(:,3:4) = id;

%% remove other trigger
id = find(ismember(target_data.trialinfo(:,1),config.trialdef.eventvalue));

cfgtriger                    = [];
cfgtriger.trials             = id;
target_data = ft_selectdata(cfgtriger, target_data);
target_data.trialinfo(:,5) = config.idx;

%% channel reapair [1 knonw bad channels]
chRep_cfg = [];
chRep_cfg.badchannel    = config.badchannel;
chRep_cfg.layout               = 'biosemi64.lay';
chRep_cfg.method               = 'distance';
chRep_cfg.neighbours           = ft_prepare_neighbours(chRep_cfg,target_data);
chRep_cfg.method               = 'weighted';
target_data       = ft_channelrepair(chRep_cfg,target_data);

%% [Step 1:] manual artifact rejection [first reject unsusal trials and channels]

cfg_man          = [];
cfg_man.method   = 'summary'; % channel summary
cfg_man.layout   = 'biosemi64.lay';   % this allows for plotting individual trials
target_data      = ft_rejectvisual(cfg_man,target_data);


%% channel reapair [2 unknonw bad channels]
orginal_channel(find(ismember(orginal_channel,'Status')))=[];
badchannel = orginal_channel(find(ismember(orginal_channel,target_data.label)==0));
chRep_cfg.badchannel    = badchannel;
target_data       = ft_channelrepair(chRep_cfg,target_data);

% cfg=[];
% cfg.viewmode   = 'vertical';
% artf=ft_databrowser(cfg,target_data);

%% [Step 2:]
arti_jump = 1;
arti_mus = 0;
arti_eog = 0;

if(arti_jump)
    %% Jump artifact
%     jump_cfg = cfg;
    % channel selection, cutoff and padding
    jump_cfg.artfctdef.zvalue.channel    = 'EEG';
    jump_cfg.artfctdef.zvalue.cutoff     = 20;
    jump_cfg.artfctdef.zvalue.trlpadding = 0;
    jump_cfg.artfctdef.zvalue.artpadding = 0;
    jump_cfg.artfctdef.zvalue.fltpadding = 0;
    
    % algorithmic parameters
    jump_cfg.artfctdef.zvalue.cumulative    = 'yes';
    jump_cfg.artfctdef.zvalue.medianfilter  = 'yes';
    jump_cfg.artfctdef.zvalue.medianfiltord = 9;
    jump_cfg.artfctdef.zvalue.absdiff       = 'yes';
    
    % make the process interactive
    jump_cfg.artfctdef.zvalue.interactive = 'yes';
    
    [jump_cfg, artifact_jump] = ft_artifact_zvalue(jump_cfg,target_data);
    comb_cfg.artfctdef.jump.artifact = artifact_jump;
end

if(arti_mus)
    %% muscle artifact
%     musl_cfg = cfg;
    % channel selection, cutoff and padding
    musl_cfg.artfctdef.zvalue.channel = 'EEG';
    musl_cfg.artfctdef.zvalue.cutoff      = 4;
    musl_cfg.artfctdef.zvalue.trlpadding  = 0;
    musl_cfg.artfctdef.zvalue.fltpadding  = 0;
    musl_cfg.artfctdef.zvalue.artpadding  = 0.1;
    
    % algorithmic parameters
    musl_cfg.artfctdef.zvalue.bpfilter    = 'yes';
    musl_cfg.artfctdef.zvalue.bpfreq      = [20 30];
    musl_cfg.artfctdef.zvalue.bpfiltord   = 9;
    musl_cfg.artfctdef.zvalue.bpfilttype  = 'but';
    musl_cfg.artfctdef.zvalue.hilbert     = 'yes';
    musl_cfg.artfctdef.zvalue.boxcar      = 0.2;
    
    % make the process interactive
    musl_cfg.artfctdef.zvalue.interactive = 'yes';
    
    [musl_cfg, artifact_muscle] = ft_artifact_zvalue(musl_cfg,target_data);
    comb_cfg.artfctdef.muscle.artifact = artifact_muscle;
end

if(arti_eog)
    %% EOG
%     eog_cfg = cfg;
    % channel selection, cutoff and padding
    eog_cfg.artfctdef.zvalue.channel     = 'EEG';
    eog_cfg.artfctdef.zvalue.cutoff      = 4;
    eog_cfg.artfctdef.zvalue.trlpadding  = 0;
    eog_cfg.artfctdef.zvalue.artpadding  = 0.1;
    eog_cfg.artfctdef.zvalue.fltpadding  = 0;
    
    % algorithmic parameters
    eog_cfg.artfctdef.zvalue.bpfilter   = 'yes';
    eog_cfg.artfctdef.zvalue.bpfilttype = 'but';
    eog_cfg.artfctdef.zvalue.bpfreq     = [1 15];
    eog_cfg.artfctdef.zvalue.bpfiltord  = 4;
    eog_cfg.artfctdef.zvalue.hilbert    = 'yes';
    
    % feedback
    eog_cfg.artfctdef.zvalue.interactive = 'yes';
    
    [eog_cfg, artifact_EOG] = ft_artifact_zvalue(eog_cfg,target_data);
    comb_cfg.artfctdef.eog.artifact = artifact_EOG; 
end

% % combine all
comb_cfg.artfctdef.reject = 'complete'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
target_data = ft_rejectartifact(comb_cfg,target_data);

%% [Step 3:] ICA and BSS-CCA two times
b = strcat('-',badchannel);
b{length(b)+1} = 'all';

[comp,comp_r] = filedtrip_BSS(b,target_data,config,0);

original_data = target_data;

%%
trial_by_trial = 0;
if(trial_by_trial)
    % remove the bad components and backproject the data
    temp = [];
    for c =1:size(comp_r,1)
        cfg = [];
        cfg.component = find(comp_r(c,:)); % to be removed component(s)
        cfg.trials       = c;
        dummy = ft_redefinetrial(cfg, target_data);
        x = ft_rejectcomponent(cfg, comp, dummy);
        x.cfg = [];
        temp{c} = x;
    end
    cfg=[];
    target_data = ft_appenddata(cfg,temp{:});
else
    cfg = [];
    %     cfg.component = input('type component number [] -->');
    cfg.component = comp_r;    
    target_data = ft_rejectcomponent(cfg, comp, target_data);
end
%% check
% cfg          = [];
% cfg.method   = 'trial'; % channel summary
% cfg.layout   = 'biosemi64.lay';   % this allows for plotting individual trials
% % cfg.alim     = 1e-12;
% data_no_artifacts        = ft_rejectvisual(cfg,target_data);

%%
cfg = [];
cfg.layout   = 'biosemi64.lay';   % this allows for plotting individual trials
figure;ft_multiplotER(cfg, original_data, target_data); 


tr = randsample(length(target_data.trial),1);
ch = randsample(length(target_data.label),1);
figure;
plot(original_data.time{1}, original_data.trial{tr}(ch,:));hold on;
plot(target_data.time{1}, target_data.trial{tr}(ch,:),'r');
title(['trial ' num2str(tr) ' channel ' target_data.label{ch}])
set(gca,'xlim',config.time_window);
hold off;




end