clear;clc;close all;



load('postlisten_tf.mat')
load('neighbours.mat')


cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_tf_CONV, GA_tf_NOCH);



% topo plot timeline fix (make high value to 0 for good figure)
X = TFR_diff;
X.powspctrm([3 6 7 12 13],:,[13:15],[15:21]) = 0;
GA_tf_CONV.powspctrm([3 6 7 12 13],:,[13:15],[15:21]) = 0;
GA_tf_NOCH.powspctrm([3 6 7 12 13],:,[13:15],[15:21]) = 0;

neg{1}.channel = {'F5' 'F7' 'FC5'};
neg{1}.frequency = [25 29];
neg{1}.time = [0.05 0.15];


cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = neg{1}.channel;
cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [0 0.5]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, TFR_diff);
title({'Convergence vs NoChange', ['mean(F5,F7,FC5)' ]}, 'FontSize', 12);
ylabel('Frequency (Hz)', 'FontSize', 14);
xlabel('Time (s)', 'FontSize', 14);
ylabel(colorbar,'Power Difference (%)', 'FontSize', 14);
set(gca,'ylim',[8 40]);
set(gca, 'YTick', 0:4:40, 'YTickLabel', 0:4:40);





% power
cfg=[];
cfg.frequency     = [neg{1}.frequency(1) neg{1}.frequency(end)];%[9 17]
cfg.channel = neg{1}.channel;%{'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5', 'T7'};
cfg.avgoverfreq = 'yes';
cfg.avgoverchan = 'yes';
a = ft_selectdata(cfg,GA_tf_CONV);
a = squeeze(a.powspctrm);
b = ft_selectdata(cfg,GA_tf_NOCH);
b = squeeze(b.powspctrm);
time=GA_tf_CONV.time;
figure;hold on;
shadedErrorBar(time,mean(a),std(a)/15,{'-b','LineWidth',1,'markerfacecolor','b'});
shadedErrorBar(time,mean(b),std(b)/15,{'-r','LineWidth',1,'markerfacecolor','r'},0.9);
cfg.latency     = [0 0.5];
ylabel('Power (\muV^{2})', 'FontSize', 14);
xlabel('Time (s)', 'FontSize', 14);
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,1);
alpha(h2,0.9);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',12);
h1 = area([neg{1}.time(1) neg{1}.time(2)],[1.2 1.2],1.2-0.1);
set(h1,'Facecolor',[0.5 0.5 0.5]);
alpha(h1,0.5);set(h1,'EdgeColor','None');
set(gca,'ylim',[1.1 3]);
set(gca,'xlim',[0 0.5]);
box on;
grid on;


cfg = [];
cfg.ylim = [25 29];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(X.label,neg{1}.channel));
cfg.interactive        = 'no';
cfg.highlight          =  'off';
cfg.highlightsymbol    =  '.';
cfg.highlightcolor     = [1 0 0];
cfg.shading            = 'interp' ;
cfg.gridscale          = 100;
cfg.markercolor        = [0 0 0];
cfg.highlightsize      = 8;
cfg.zlim    = [-0.25 0.25];
cfg.markersymbol       = '.';


a = [0:0.1:0.5];
h = figure('Position',[1950 160 1100 930]);
for k = 1:5;
     if(k==1|| k== 2)
       cfg.highlight          =  'on';
 
    else
        cfg.highlight          =  'off';

    end
     subplot(1,5,k);
     cfg.xlim = [a(k) a(k+1)];
     ft_topoplotER(cfg, X);hold on;
     TextH = text(-0.25, -0.7, ['[' num2str(cfg.xlim(1)) 's ' num2str(cfg.xlim(2)) 's]'],  'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom','FontSize',10);

end
c = colorbar('southoutside','Position',[0.17 0.35 0.65 0.03]);
c.Label.String = 'Power Difference (%)';
c.Ticks = [-0.25,-0.15,0,0.15,0.25];

AxesH = axes('Parent', h,   'Units', 'normalized', 'Position', [0, 0, 1, 1],   'Visible', 'off','XLim', [0, 1], 'YLim', [0, 1],   'NextPlot', 'add');
TextH = text(0.45, 0.65, 'Listen (25-29 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',14);
 
