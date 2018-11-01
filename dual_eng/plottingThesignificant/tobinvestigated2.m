load('F:\WORK\25ms\-1-1 left hand exclude\EEG__32_10_mwv_mfc_convVSnoch_25ms_10.mat')
load('F:\WORK\25ms\-1-1\EEG__32_10_mwv_mfc_convVSnoch_25ms_10.mat')

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_tf_CONV, GA_tf_NOCH);


%% PreSpeech
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F5','F7','FT7','FC5'};
% cfg.zlim = [-0.2 0.2]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange','mean(FT7,FC5,F5,F7)'});
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power Difference (%)');



% power
time_w = [1:21];
freq = [12:14];
th=0.005;ylimV = [1 3];
[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
title({'FT7,FC5,F5,F7 (12-14 Hz)'});
ylabel('Power (\muV^{2})');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([-0.27  -0.19],[ylimV(1) ylimV(1)],ylimV(1)-0.2);
set(h1,'Facecolor',[0.5 0.5 0.5]);
alpha(h1,0.5);set(h1,'EdgeColor','None');
set(gca,'xlim',[-0.5 0]);
set(gca,'ylim',[ylimV(1)-0.1 ylimV(2)]);
title([cell2mat(cfg.channelname) ' - ' num2str(freq) ' Hz Power']);



% cluster
cfg = [];
% cfg.xlim = [-0.5:0.5:0];
cfg.ylim = [12 14];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(TFR_diff.label,{'F5','F7','FT7','FC5'}));
cfg.interactive        = 'no';
cfg.highlight          =  'on';
cfg.highlightsymbol    =  '.';
cfg.highlightcolor     = [1 0 0];
cfg.shading            = 'interp' ;
cfg.gridscale          = 100;
cfg.markercolor        = [0 0 0];
cfg.highlightsize      = 10;
cfg.zlim    = [-0.25 0.25];

a = [-0.5:0.1:0];
h = figure('Position',[1950 160 1100 930]);
for k = 1:5;
     subplot(1,5,k);
     cfg.xlim = [a(k) a(k+1)];
     ft_topoplotER(cfg, TFR_diff);hold on;
     TextH = text(-0.25, -0.7, ['[' num2str(cfg.xlim(1)) 's ' num2str(cfg.xlim(2)) 's]'],  'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom','FontSize',10);

end
c = colorbar('southoutside','Position',[0.17 0.35 0.65 0.03]);
c.Label.String = 'Power Difference (%)';
c.Ticks = [-0.25,-0.15,0,0.15,0.25];

AxesH = axes('Parent', h,   'Units', 'normalized', 'Position', [0, 0, 1, 1],   'Visible', 'off','XLim', [0, 1], 'YLim', [0, 1],   'NextPlot', 'add');
TextH = text(0.45, 0.65, 'PreSpeech (12-14 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',14);
 










%% PostListen
% load('F:\WORK\25ms\-1-1 left hand exclude\EEG__32_10_mwv_mfc_convVSnoch_listen_25ms_10.mat')
load('F:\WORK\25ms\-1-1\EEG__32_10_mwv_mfc_convVSnoch_listen_25ms_10.mat')


cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_tf_CONV, GA_tf_NOCH);

% 24 29
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F3','F5','F7','FC5','FC3','C3','C5'};
cfg.zlim = [-0.3 0.32]; % Specify the time range to plot
cfg.xlim = [0 0.5]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange', ['mean(' cell2mat(cfg.channelname) ')' ]});
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power Change (%)');


time_w = [21:41];
freq = [24:29];
th=0.005;ylimV = [0.5 1];
[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
title([cell2mat(cfg.channelname) ' - ' num2str(freq) ' Hz Power']);
ylabel('Power (\muV^{2})');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([0.05     0.10],[ylimV(1) ylimV(1)],ylimV(1)-0.01);
set(h1,'Facecolor',[0.5 0.5 0.5]);
alpha(h1,0.5);set(h1,'EdgeColor','None');
set(gca,'xlim',[0 0.5]);
set(gca,'ylim',[ylimV(1)-0.01 ylimV(2)]);
title([cell2mat(cfg.channelname) ' - ' num2str(freq) ' Hz Power']);





% cluster
cfg = [];
% cfg.xlim = [-0.5:0.5:0];
cfg.ylim = [24 29];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(TFR_diff.label, {'F3','F5','F7','FC5','FC3','C3','C5'}));
cfg.interactive        = 'no';
cfg.highlight          =  'on';
cfg.highlightsymbol    =  '.';
cfg.highlightcolor     = [1 0 0];
cfg.shading            = 'interp' ;
cfg.gridscale          = 100;
cfg.markercolor        = [0 0 0];
cfg.highlightsize      = 10;
cfg.zlim    = [-0.25 0.25];

a = [0:0.1:0.5];
h = figure('Position',[1950 160 1100 930]);
for k = 1:5;
     subplot(1,5,k);
     cfg.xlim = [a(k) a(k+1)];
     ft_topoplotER(cfg, TFR_diff);hold on;
     TextH = text(-0.25, -0.7, ['[' num2str(cfg.xlim(1)) 's ' num2str(cfg.xlim(2)) 's]'],  'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom','FontSize',10);

end
c = colorbar('southoutside','Position',[0.17 0.35 0.65 0.03]);
c.Label.String = 'Power Difference (%)';
c.Ticks = [-0.25,-0.15,0,0.15,0.25];

AxesH = axes('Parent', h,   'Units', 'normalized', 'Position', [0, 0, 1, 1],   'Visible', 'off','XLim', [0, 1], 'YLim', [0, 1],   'NextPlot', 'add');
TextH = text(0.45, 0.65, 'PostListen (24-29 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',14);
 







% 32  34 hz
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'AF8','F6','F8','FT8','FC6'};
cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [0 0.5]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange', ['mean(' cell2mat(cfg.channelname) ')' ]});
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power Change (%)');



time_w = [21:41];
freq = [32:34];
th=0.005;ylimV = [0.6 1.3];
[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
title([cell2mat(cfg.channelname) ' - ' num2str(freq) ' Hz Power']);
ylabel('Power (\muV^{2})');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([0.07     0.125],[ylimV(1) ylimV(1)],ylimV(1)-0.01);
set(h1,'Facecolor',[0.5 0.5 0.5]);
alpha(h1,0.5);set(h1,'EdgeColor','None');
set(gca,'xlim',[0 0.5]);
set(gca,'ylim',[ylimV(1)-0.01 ylimV(2)]);
title([cell2mat(cfg.channelname) ' - ' num2str(freq) ' Hz Power']);




% cluster
cfg = [];
% cfg.xlim = [-0.5:0.5:0];
cfg.ylim = [32 34];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(TFR_diff.label, {'AF8','F6','F8','FT8','FC6'}));
cfg.interactive        = 'no';
cfg.highlight          =  'on';
cfg.highlightsymbol    =  '.';
cfg.highlightcolor     = [1 0 0];
cfg.shading            = 'interp' ;
cfg.gridscale          = 100;
cfg.markercolor        = [0 0 0];
cfg.highlightsize      = 10;
cfg.zlim    = [-0.25 0.25];

a = [0:0.1:0.5];
h = figure('Position',[1950 160 1100 930]);
for k = 1:5;
     subplot(1,5,k);
     cfg.xlim = [a(k) a(k+1)];
     ft_topoplotER(cfg, TFR_diff);hold on;
     TextH = text(-0.25, -0.7, ['[' num2str(cfg.xlim(1)) 's ' num2str(cfg.xlim(2)) 's]'],  'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom','FontSize',10);

end
c = colorbar('southoutside','Position',[0.17 0.35 0.65 0.03]);
c.Label.String = 'Power Difference (%)';
c.Ticks = [-0.25,-0.15,0,0.15,0.25];

AxesH = axes('Parent', h,   'Units', 'normalized', 'Position', [0, 0, 1, 1],   'Visible', 'off','XLim', [0, 1], 'YLim', [0, 1],   'NextPlot', 'add');
TextH = text(0.45, 0.65, 'PostListen (32-34 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',14);
 



%% PretListen



% 22  24 hz
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'C4','C6','CP6','CP4'};
cfg.zlim = [-0.3 0.3]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange', ['mean(' cell2mat(cfg.channelname) ')' ]});
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power Change (%)');

time_w = [1:21];
freq = [22:24];
th=0.005;ylimV = [0.45 0.9];
[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
title([cell2mat(cfg.channelname) ' - ' num2str(freq) ' Hz Power']);
ylabel('Power (\muV^{2})');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([-0.26     -0.19],[ylimV(1) ylimV(1)],ylimV(1)-0.01);
set(h1,'Facecolor',[0.5 0.5 0.5]);
alpha(h1,0.5);set(h1,'EdgeColor','None');
set(gca,'xlim',[-0.5 0]);
set(gca,'ylim',[ylimV(1)-0.01 ylimV(2)]);
title([cell2mat(cfg.channelname) ' - ' num2str(freq) ' Hz Power']);


% cluster
cfg = [];
cfg.ylim = [22 24];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(TFR_diff.label, {'C4','C6','CP6','CP4'}));     
cfg.interactive        = 'no';
cfg.highlight          =  'on';
cfg.highlightsymbol    =  '.';
cfg.highlightcolor     = [1 0 0];
cfg.shading            = 'interp' ;
cfg.gridscale          = 100;
cfg.markercolor        = [0 0 0];
cfg.highlightsize      = 10;
cfg.zlim    = [-0.25 0.25];

a = [-0.5:0.1:0];
h = figure('Position',[1950 160 1100 930]);
for k = 1:5;
     subplot(1,5,k);
     cfg.xlim = [a(k) a(k+1)];
     ft_topoplotER(cfg, TFR_diff);hold on;
     TextH = text(-0.25, -0.7, ['[' num2str(cfg.xlim(1)) 's ' num2str(cfg.xlim(2)) 's]'],  'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom','FontSize',10);

end
c = colorbar('southoutside','Position',[0.17 0.35 0.65 0.03]);
c.Label.String = 'Power Difference (%)';
c.Ticks = [-0.25,-0.15,0,0.15,0.25];

AxesH = axes('Parent', h,   'Units', 'normalized', 'Position', [0, 0, 1, 1],   'Visible', 'off','XLim', [0, 1], 'YLim', [0, 1],   'NextPlot', 'add');
TextH = text(0.45, 0.65, 'PreListen (22-24 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',14);
 






% 22  24 hz
cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'POz','P2','P4','PO4'};
cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange', ['mean(' cell2mat(cfg.channelname) ')' ]});
ylabel('Frequency (Hz)');
xlabel('Time (s)');
ylabel(colorbar,'Power Change (%)');

time_w = [1:21];
freq = [28:30];
th=0.005;ylimV = [0.45 0.9];
[C_mean,CI] = confidence_interval(CONV_tf,freq,time_w,cfg.channelname,th,1);
figure;
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'-b',0.5);hold on;
[C_mean,CI] = confidence_interval(NOCH_tf,freq,time_w,cfg.channelname,th,1);
shadedErrorBar(CONV_tf{1}.time(time_w),C_mean,CI,'r',0.25);
title([cell2mat(cfg.channelname) ' - ' num2str(freq) ' Hz Power']);
ylabel('Power (\muV^{2})');
xlabel('Time (s)');
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,0.5);
alpha(h2,0.25);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',9);
h1 = area([-0.26     -0.19],[ylimV(1) ylimV(1)],ylimV(1)-0.01);
set(h1,'Facecolor',[0.5 0.5 0.5]);
alpha(h1,0.5);set(h1,'EdgeColor','None');
set(gca,'xlim',[-0.5 0]);
set(gca,'ylim',[ylimV(1)-0.01 ylimV(2)]);
title([cell2mat(cfg.channelname) ' - ' num2str(freq) ' Hz Power']);


% cluster
cfg = [];
cfg.ylim = [28 30];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(TFR_diff.label, {'POz','P2','P4','PO4'}));     
cfg.interactive        = 'no';
cfg.highlight          =  'on';
cfg.highlightsymbol    =  '.';
cfg.highlightcolor     = [1 0 0];
cfg.shading            = 'interp' ;
cfg.gridscale          = 100;
cfg.markercolor        = [0 0 0];
cfg.highlightsize      = 10;
% cfg.zlim    = [-0.25 0.25];

a = [-0.5:0.1:0];
h = figure('Position',[1950 160 1100 930]);
for k = 1:5;
     subplot(1,5,k);
     cfg.xlim = [a(k) a(k+1)];
     ft_topoplotER(cfg, TFR_diff);hold on;
     TextH = text(-0.25, -0.7, ['[' num2str(cfg.xlim(1)) 's ' num2str(cfg.xlim(2)) 's]'],  'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom','FontSize',10);

end
c = colorbar('southoutside','Position',[0.17 0.35 0.65 0.03]);
c.Label.String = 'Power Difference (%)';
c.Ticks = [-0.25,-0.15,0,0.15,0.25];

AxesH = axes('Parent', h,   'Units', 'normalized', 'Position', [0, 0, 1, 1],   'Visible', 'off','XLim', [0, 1], 'YLim', [0, 1],   'NextPlot', 'add');
TextH = text(0.45, 0.65, 'PreListen (22-24 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',14);