%% speech plot
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\prespeech\importent_nobaseline_1sec_nolog_sepcond_oldsettings_5ms_-500-0\speech_tfr.mat',...
'GA_CONV','GA_NOCH');

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_CONV, GA_NOCH);

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
 























%% listen plot
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\perfect\postlisten\importent_nobaseline_5ms_-500-0_0-500_oldsettings_listen_5sec_sepcond\listen_0-500.mat',...
'GA_CONV','GA_NOCH');
cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_CONV, GA_NOCH);

%% cluster 27-28 hz  [0.10     0.14453]
cfg = [];
% cfg.xlim = [0:0.1:0.5];
cfg.ylim = [27 28];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(TFR_diff.label,{'F5','F7','FC5'}));
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
TextH = text(0.45, 0.65, 'PostListen (27-28 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',14);
 







% 
% %% cluster 34 hz  [0.070313     0.12109]
% cfg = [];
% cfg.xlim = [0:0.1:0.5];
% cfg.ylim = [33 35];
% cfg.comment = 'no';
% cfg.commentpos = 'title';
% cfg.layout  = 'biosemi64.lay';
% cfg.style            = 'straight';
% cfg.marker           = 'off';
% cfg.highlightchannel   = find(ismember(TFR_diff.label,{'AF8','F6','F8'}));
% cfg.interactive        = 'no';
% cfg.highlight          =  'on';
% cfg.highlightsymbol    =  '.';
% cfg.highlightcolor     = [1 0 0];
% cfg.shading            = 'interp' ;
% cfg.gridscale          = 100;
% cfg.markercolor        = [0 0 0];
% cfg.highlightsize      = 10;
% cfg.zlim    = [-0.25 0.25];
% 
% ft_topoplotER(cfg, TFR_diff);




%% prelisten
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\FiieldtripClustering\-1to1EEG_config\1secRT\listen_-500-0.mat',...
'GA_CONV','GA_NOCH');


cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_CONV, GA_NOCH);


%% 21 -24 cluster   [-0.26563     -0.21094]
cfg = [];
% cfg.xlim = [-0.5:0.1:0];
cfg.ylim = [21 24];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(TFR_diff.label,{'C4','C6','CP6','CP4'}));
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
TextH = text(0.45, 0.65, 'PreListen (21-24 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',14);


%% cluster 28-30 hz [-0.32     -0.28]

cfg = [];
% cfg.xlim = [-0.5:0.1:0];
cfg.ylim = [28 30];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(TFR_diff.label,{'POz','P2','P4','PO4'}));
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
TextH = text(0.45, 0.65, 'PreListen (28-30 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',14);



























