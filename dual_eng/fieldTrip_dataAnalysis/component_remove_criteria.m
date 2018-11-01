function [comp_r] = component_remove_criteria(comp,time_window)
% with in subject
% calculate the grand average for each condition
cfg            = [];
cfg.output     = 'pow';
cfg.method     = 'mtmfft';
cfg.foi          = 1:40;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.t_ftimwin    = ones(size(cfg.foi)).*0.5;   % length of time window = 0.5 sec
cfg.toi          = time_window(1):0.05:time_window(2);                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
cfg.tapsmofrq  = 1;
cfg.keeptrials = 'yes';
tf = ft_freqanalysis(cfg, comp);
cfg.keeptrials = 'no';
fd            = ft_freqdescriptives(cfg, tf);

%% bss cca criteria
% EMG
ratio = 7;
fr = 15;
tolerance = 0.1;

frequencyL = find(fd.freq<fr);
frequencyH = find(fd.freq>fr);

avg_pow_L = mean(tf.powspctrm(:,:,frequencyL),3);
avg_pow_H = mean(tf.powspctrm(:,:,frequencyH),3);

trial_power = zeros(size(avg_pow_L));
for trial=1:size(avg_pow_L,1)
    temp = avg_pow_L(trial,:)/ratio - avg_pow_H(trial,:);
    temp1 = find(tolerance < temp);
    trial_power(trial,temp1) = 1;
end

deiv_freq = fd.freq(frequencyL(end));

%% plot component activity power spectrum

cfg = [];
cfg.layout    = 'biosemi64.lay'; % specify the layout file that should be used for plotting
cfg.comment   = 'no';

mean_power = fd.powspctrm(:,1);
mean_power = mean(mean_power)+2*std(mean_power);
h=figure;
for isub = 1:size(tf.powspctrm,2)
    subplot(8,8,isub);
    hold on;
    cfg.component = isub;       % specify the component(s) that should be plotted
    ft_topoplotIC(cfg, comp);
    ax1 = gca;

    ax2(isub) = axes('Position',ax1.Position,'XAxisLocation','bottom',  'YAxisLocation','left',  'Color','none');
    
    A = fd.powspctrm(isub,:);
    if(A(1)>mean_power)
        line(fd.freq,fd.powspctrm(isub,:),'Parent',ax2(isub),'Color','b');
    else
        line(fd.freq,fd.powspctrm(isub,:),'Parent',ax2(isub),'Color','r');
    end    
    line([deiv_freq deiv_freq],get(gca,'ylim'),'Parent',ax2(isub),'Color','k');
    set(ax2(isub),'tag',num2str(isub));
    disp(['plotting component..' num2str(isub)]);
end
% linkaxes(ax2,'y');


AxesH = axes('Parent', h,   'Units', 'normalized', 'Position', [0, 0, 1, 1],   'Visible', 'off','XLim', [0, 1], 'YLim', [0, 1],   'NextPlot', 'add','tag','XXX');
TextH = text(0,1, 'close',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','tag','XXX');
 
 
 
 
 
comp_r = clicksubplot(h);
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
end