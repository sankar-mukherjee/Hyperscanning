%% connetivity analysis after cluster permutation test. singinfianct area, electrods and time windows are seleted. Then doing the connectivity analysis between the pre speech and listing condition

load([project.paths.processedData '\neweegdata\-1to1sec/EEG.mat']);
load([project.paths.processedData '/processed_data_word_level.mat'],'D');
load([project.paths.processedData '/convergence/convergence_32_10_mwv_mfc.mat']);
EEG = pop_loadset([project.paths.projects_data_root '/dual_eng/05_nicholas_solo_raw_mc_pre_speech.set']);
config.chanlocs = chanlocs;
config.eegrate  = 256;
baselineCorrect = 0;
reactionTime = 10;
logTransform = 0;

index = get_condition_index(D,convergence_data,'all');
conv_idx = get_condition_index(D,convergence_data,'convergence');
noCh_idx = get_condition_index(D,convergence_data,'noch');

% PreSpeech
config.times = speech_eeg_times;%listen_eeg_times speech_eeg_times
config.type = 'speech';
config.trial_time_window = [-0.5 0];   %[-0.7 0.2]
config.analysis_time_window = [-0.5 0];   %
prespeech = get_trials_fieldtrip(EEG_data,EEG,D(index,1),index,config,0,convergence_data);

% PreListen
config.times = listen_eeg_times;%listen_eeg_times speech_eeg_times
config.type = 'listen';
config.trial_time_window = [-0.5 0];
config.analysis_time_window = [-0.5 0];
prelisten = get_trials_fieldtrip(EEG_data,EEG,D(index,1),index,config,baselineCorrect,convergence_data);


% PostListen
config.times = listen_eeg_times;%listen_eeg_times speech_eeg_times
config.type = 'listen';
config.trial_time_window = [0 0.5];
config.analysis_time_window = [0 0.5];
postlisten = get_trials_fieldtrip(EEG_data,EEG,D(index,1),index,config,baselineCorrect,convergence_data);

conv = 1;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\convergence\word_pair_position_32_10_mwv_mfc.mat')
index =  [reshape(word_pair_position(:,:,2)',32,1) reshape(word_pair_position(:,:,3)',32,1) reshape(word_pair_position(:,:,1)',32,1)];
index_O = cellfun(@transpose,index,'UniformOutput',false);



group = [];
j=1;g=1;
for sub=1:2:16
    %     if not(sub==3)
    s = cell2mat(index_O(j:j+3,:));
    
    a=s;
    % check for leader folower
    for i=1:length(a)
        if(s(i,3)==2)
            a(i,:)=[s(i,2) s(i,1) s(i,3)];
        end
    end
    s=a;
    
    A = [];
    for i=1:99:396
        a = s(i:i+98,:);
%         a = a(1:2:end,:);
%         a = a(2:2:end,:);
        % individual subject for avg afterwords
        a=kron(a,ones(2,1));
        a(2:2:end,1:2) = fliplr(a(1:2:end,1:2));
        a = a(1:2:end,:);
        A = [A;a];
    end
    s=A;
    
    s(any(isnan(s), 2), :) = [];
    
%     % conv noch
%     if(conv)
%         a = s(find(ismember(s(:,1),conv_idx)),:);
%         s=a;
%     elseif(conv == 0)
%         a = s(find(ismember(s(:,1),noCh_idx)),:);
%         s=a;
%     end
    
    %% condition combination
    a = [prespeech{sub,1}.trialinfo(:,2)];
    A = ismember(s(:,1),a);
    b = [prelisten{sub+1,1}.trialinfo(:,2)];
    B = ismember(s(:,2),b);
    A = find(A.*B);
    s = s(A,:);
    
    a = find(ismember(prespeech{sub,1}.trialinfo(:,2),s(:,1)));
    b = find(ismember(prelisten{sub+1,1}.trialinfo(:,2),s(:,2)));   
    
    cfg           = [];
    cfg.trials = a;
    cfg.latency         = [-0.8 0.3];
    temp{1,1} = ft_selectdata(cfg,prespeech{sub,1});
    temp{1,1}.label = strcat('S-',temp{1,1}.label);

    cfg           = [];
    cfg.trials = b;
    cfg.latency         = [-0.8 0.3];
    temp{1,2} = ft_selectdata(cfg,prelisten{sub+1,1});
    temp{1,2}.label = strcat('L-',temp{1,2}.label);

    cfg           = [];
    group{g,1} = ft_appenddata(cfg,temp{:});
%     group{g,1} = temp{1,1};
%     group{g,2} = temp{1,2};

    j=j+4;g=g+1;
end

for i= 1:length(group)
    
    cfg           = [];
    cfg.demean                    = 'yes';
    group{i,1} = ft_preprocessing(cfg,group{i,1});
    
end

%% coherence
cfg           = [];
cfg.method    = 'mtmconvol';
cfg.taper     = 'hanning';
cfg.output    = 'powandcsd';
cfg.foi          = 1:40;
cfg.t_ftimwin    = ones(size(cfg.foi)).*0.3;   % length of time window = 0.5 sec
% cfg.t_ftimwin    =  3./cfg.foi;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.025:0;                  % time window "sli
% cfg.tapsmofrq = 14;
% cfg.foilim     = [1 40];


% % collapse time
% cfg           = [];
% cfg.method    = 'mtmfft';
% cfg.taper     = 'hanning';
% cfg.output    = 'fourier';
% cfg.foi          = 1:40;

%
[A,B] = meshgrid(1:64,65:128);
i=cat(2,A',B');
a=reshape(i,[],2);
cfg.channelcmb = [ group{1,1}.label(a(:,1)) group{1,1}.label(a(:,2))];

a = [];A=[];
for i= 1:length(group)
    a{i,1} = ft_freqanalysis(cfg, group{i,1});
%     a{i,2} = ft_freqanalysis(cfg, group{i,2});

    cfg_conn           = [];
    cfg_conn.method    = 'coh';
    cfg_conn.channelcmb = cfg.channelcmb;
    A{i,1} = ft_connectivityanalysis(cfg_conn, a{i,1});
%     A{i,2} = ft_connectivityanalysis(cfg_conn, a{i,2});
end
coh_conv_pair = A;
coh_noch_pair = A;
coh_full = A;

%plot
for g=1:8
    for i=1:64
        b = cfg_conn.channelcmb{i,1};
        b = cfg_conn.channelcmb(find(ismember(cfg_conn.channelcmb(:,1),b)),:);
        cfg           = [];
        cfg.channelcmb         = b;
        b = ft_selectdata(cfg,A{g,1});
        b.label = cellfun(@(x) x(3:end), b.labelcmb(:,2), 'un', 0);
        b = rmfield(b,'labelcmb');
        
        cfg                  = [];
        cfg.parameter        = 'cohspctrm';
        cfg.layout           = 'biosemi64.lay';
        cfg.showlabels       = 'yes';
%         cfg.colormap = jet;
        cfg.zlim = [0 1];
        figure; ft_multiplotTFR(cfg, b);
        
        title(cfg_conn.channelcmb{i,1})
    end
end

fb = strcat(coh_conv_pair{1,1}.labelcmb(:,1),coh_conv_pair{1,1}.labelcmb(:,2));

%% singnificant connection (non parametric)
Ngroup = 8;
coh_conv_pair1 = coh_conv_pair;
coh_noch_pair2 = coh_noch_pair;
for i= 1:Ngroup
    coh_conv_pair1{i}.cohspctrm = atanh(coh_conv_pair{i}.cohspctrm) - atanh(coh_noch_pair{i}.cohspctrm);
    coh_noch_pair2{i}.cohspctrm(:) = 0; %this is done for 5 subjects separately
    coh_conv_pair1{i}.label = fb;
    coh_noch_pair2{i}.label = fb;
end
% 
% cfg = [];
% cfg.method    = 'distance';
% neighbours       = ft_prepare_neighbours(cfg, prespeech{1});
cfg = [];
cfg.latency          = 'all';
cfg.frequency        = [2 4]; % this will be performed for different frequency bands
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
% cfg.neighbourdist    = 1;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.correcttail      = 'prob';  % 'prob''alpha'
cfg.numrandomization = 2500;
% specifies with which sensors other sensors can form clusters
cfg.neighbours       = neighbours;
cfg.parameter   = 'cohspctrm';
cfg.channel          = fb;

design = zeros(2,2*Ngroup);
for i = 1:Ngroup
    design(1,i) = i;
end
for i = 1:Ngroup
    design(1,Ngroup+i) = i;
end
design(2,1:Ngroup)        = 1;
design(2,Ngroup+1:2*Ngroup) = 2;

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_freqstatistics(cfg,coh_conv_pair1{:},coh_noch_pair2{:});

%% singnificant connection (full)
fb = strcat(coh_full{1,1}.labelcmb(:,1),coh_full{1,1}.labelcmb(:,2));

Ngroup = length(coh_full);
coh_full1 = coh_full;
coh_full2 = coh_full;
for i= 1:Ngroup
    coh_full1{i}.cohspctrm = atanh(coh_full1{i}.cohspctrm);
    coh_full2{i}.cohspctrm(:) = 0; %this is done for 5 subjects separately
    coh_full1{i}.label = fb;
    coh_full2{i}.label = fb;
end

cfg = [];
cfg.latency          = 'all';
cfg.frequency        = [11 15]; % this will be performed for different frequency bands
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
% cfg.neighbourdist    = 1;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.correcttail      = 'prob';  % 'prob''alpha'
cfg.numrandomization = 1000;
% specifies with which sensors other sensors can form clusters
cfg.neighbours       = neighbours;
cfg.parameter   = 'cohspctrm';
cfg.channel          = fb;

design = zeros(2,2*Ngroup);
for i = 1:Ngroup
    design(1,i) = i;
end
for i = 1:Ngroup
    design(1,Ngroup+i) = i;
end
design(2,1:Ngroup)        = 1;
design(2,Ngroup+1:2*Ngroup) = 2;

% design = design(:,1:8);

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_freqstatistics(cfg,coh_full1{:},coh_full2{:});



%%
sub = 1;
labels =  ft_channelselection({'all' '-F-*'}, coh_conv_pair{1}.label);

figure;


cfg                  = [];
cfg.parameter        = 'cohspctrm';
cfg.zlim             = [0 0.8];
cfg.layout           = 'biosemi64.lay';
cfg.comment          = 'no';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlight          = 'on';
cfg.highlightsymbol    =  '.';
cfg.interactive        = 'no';
cfg.gridscale          = 50;
cfg.outline            = 'false';
lay = ft_prepare_layout(cfg, 'biosemi64.lay');
lay.pos = lay.pos +0.5;

% ft_layoutplot(cfg);hold on;
hParentAx = axes();
[hAx hPan] = axesRelative(hParentAx,'Units','normalized', 'Position',[0.2 0.2 0.8 0.8]);
for i = 1:length(labels)
    temp = ['F-' labels{i}];    
    cfg.refchannel       = temp;
    cfg.highlightchannel   = labels{i};
    idx = find(ismember(lay.label,cfg.highlightchannel));
    [hAx1 hPan] = axesRelative(hAx,'Units','normalized', 'Position',[lay.pos(idx,1) lay.pos(idx,2) lay.width(idx) lay.height(idx)]);
%     subplot('Position',[lay.pos(idx,1) lay.pos(idx,2) lay.width(idx) lay.height(idx)]);
    hold on;
    ft_topoplotER(cfg, coh_conv_pair{sub});
    title(labels{i});
end

%%

%# automatic resize only works for normalized units
figure
% hParentAx = axes('Units','normalized');
hParentAx = axes();
[hAx hPan] = axesRelative(hParentAx,'Units','normalized', 'Position',[0.2 0.2 0.7 0.7]);
set(hAx, 'xlim',[-0.5 0.5],'ylim',[-0.5 0.5]);

[hAx1 hPan] = axesRelative(hAx,'Units','normalized', 'Position',[lay.pos(idx,1) lay.pos(idx,2) lay.width(idx) lay.height(idx)]);
set(hAx1, 'Color','r')

set(hAx1,'clipping','off')

% axis(hParentAx, 'image')

%# create a new axis positioned at normalized units with w.r.t the previous axis
%# the axis should maintain its relative position on resizing the figure
[hAx hPan] = axesRelative(hParentAx,'Units','normalized', 'Position',[lay.pos(idx,1) lay.pos(idx,2) lay.width(idx) lay.height(idx)]);
set(hAx, 'Color','r')

    im = frame2im(getframe(gcf,rec)); 
F = getframe(gcf);
[X, Map] = frame2im(F);








%# create fan-shaped coordinates
[R,PHI] = meshgrid(linspace(1,2,5), linspace(0,pi/2,10));
X = R.*cos(PHI); Y = R.*sin(PHI);
X = X(:); Y = Y(:);
num = numel(X);

%# images at each point (they don't have to be the same)
img = imread('coins.png');
img = repmat({img}, [num 1]);

%# plot scatter of images
SCALE = 0.2;             %# image size along the biggest dimension
figure
for i=1:num
    %# compute XData/YData vectors of each image
    [h w] = size(img{i});
    if h>w
        scaleY = SCALE;
        scaleX = SCALE * w/h;
    else
        scaleX = SCALE; 
        scaleY = SCALE * h/w;
    end
    xx = linspace(-scaleX/2, scaleX/2, h) + X(i);
    yy = linspace(-scaleY/2, scaleY/2, w) + Y(i);

    %# note: we are using the low-level syntax of the function
    image('XData',xx, 'YData',yy, 'CData',img{i}, 'CDataMapping','scaled')
end
axis image, axis ij
colormap gray, colorbar
set(gca, 'CLimMode','auto')








allCoords = lay.pos;
for k = 1:numel(lay.outline)
    allCoords = [allCoords; lay.outline{k}];
end
naturalWidth = (max(allCoords(:,1))-min(allCoords(:,1)));
naturalHeight = (max(allCoords(:,2))-min(allCoords(:,2)));
xScaling = 1;
yScaling = 1;
X      = lay.pos(:,1)*xScaling ;
Y      = lay.pos(:,2)*yScaling;
Width  = lay.width*xScaling;
Height = lay.height*yScaling;
Lbl    = lay.label;

figure;
plot(X,Y)






figure;
ft_plot_lay(lay, 'point', false, 'box', false, 'label', false, 'mask', true, 'outline', false);










cfg = [];
cfg.layout = 'biosemi64.lay';
cfg.latency = 'all';
cfg.avgovertime = 'no';
cfg.parameter = 'cohspctrm';
cfg.method = 'montecarlo';
cfg.statistic = 'ft_statfun_diff';

cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
% cfg.neighbourdist    = 1;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.correcttail      = 'prob';  % 'prob''alpha'
cfg.numrandomization = 2500;
% specifies with which sensors other sensors can form clusters
cfg.neighbours       = neighbours;



cfg.ivar = 2;
cfg.uvar = 1;

% design matrices
design(1,:) = [1:Ngroup, 1:Ngroup];
design(2,:) = [ones(1,Ngroup), ones(1,Ngroup) * 2];
cfg.design = design;

cfg.avgoverfreq = 'yes';
cfg.frequency = [2 4]; % this will be performed for different frequency bands
[stat] = ft_freqstatistics(cfg,coh_conv_pair1{1},coh_noch_pair2{1},coh_conv_pair1{2},coh_noch_pair2{2},coh_conv_pair1{3},coh_noch_pair2{3},coh_conv_pair1{4},coh_noch_pair2{4},...
    coh_conv_pair1{5},coh_noch_pair2{5},coh_conv_pair1{6},coh_noch_pair2{6},coh_conv_pair1{7},coh_noch_pair2{7});


cfg              = [];
for i=1:length(coh_conv_pair)
    tf_d{i} = ft_freqdescriptives(cfg, coh_conv_pair{i});
end

cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'cohspctrm';
GA_coh_conv_pair = ft_freqgrandaverage(cfg, coh_conv_pair1{:});



