clear;clc;close all;



load('postlisten_tf.mat')
load('neighbours.mat')


GA_CONV=[];GA_NOCH=[];k=1;
for i=[1:15]
    C =    CONV_tf{i};
    N =  NOCH_tf{i};
    if(i==13)
        a = C;
        a.powspctrm = C.powspctrm;
        a = avg_with_neighbour(a,'F1','F3',neighbours);
        C.powspctrm(:,4,:,:) = a.powspctrm(:,4,:,:);
        
        C.powspctrm(:,[3],:,:) = 0;
        N.powspctrm(:,[3],:,:) = 0;
        
    elseif(i==12)
        
        a = C;
        a.powspctrm = C.powspctrm;
        a = avg_with_neighbour(a,{'FC4'},'FC6',neighbours);
        C.powspctrm(:,45,:,:) = a.powspctrm(:,45,:,:);
        a = C;
        a.powspctrm = C.powspctrm;
        a = avg_with_neighbour(a,{'FC6'},'FC4',neighbours);
        C.powspctrm(:,44,:,:) = a.powspctrm(:,44,:,:);
        
        
        a = N;
        a.powspctrm = N.powspctrm;
        a = avg_with_neighbour(a,{'FC4'},'',neighbours);
        N.powspctrm(:,45,:,:) = a.powspctrm(:,45,:,:);
        
        a = C;
        a.powspctrm = C.powspctrm;
        a = avg_with_neighbour(a,{'F3'},'',neighbours);
        C.powspctrm(:,5,:,:) = a.powspctrm(:,5,:,:);
        a = C;
        
        
    elseif(i==7)
        a = C;
        a.powspctrm = C.powspctrm(3,:,:,:);
        a = avg_with_neighbour(a,'FC3','',neighbours);
        C.powspctrm(3,10,:,:) = a.powspctrm(:,10,:,:);
    end
    C.powspctrm(:,[28 62 64],:,:) = 0; 
    N.powspctrm(:,[28 62 64],:,:) = 0;
    
    C = ft_freqdescriptives([], C);
    N = ft_freqdescriptives([], N);
    
    GA_CONV{k} = C;
    GA_NOCH{k}  = N;
    
    k=k+1;
end



AA=1:15;
cfg = [];
cfg.channel   = 'all';
cfg.latency   = 'all';
cfg.keepindividual = 'yes';
cfg.parameter = 'powspctrm';
GA_CONV1 = ft_freqgrandaverage(cfg, GA_CONV{AA});
GA_NOCH1 = ft_freqgrandaverage(cfg, GA_NOCH{AA});



within_subj_stat = within_subj_tf_cluster(GA_CONV1,GA_NOCH1,neighbours,[8 40],15, [0 0.5]);
[pos,neg] = significant_cluster_time_freq_channel(within_subj_stat,0.08);


cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_CONV1, GA_NOCH1);

TFR_diff.powspctrm(13,3,:,:) = 0;
TFR_diff.powspctrm(:,[28 62 64],:,:) = 0;

% 
% neg{1}.channel = {'F5' 'F7' 'FC5'};
% neg{1}.frequency = [21 29];
% neg{1}.time = [0.05 0.15];

cfg=[];
cfg.latency     =[within_subj_stat.time(1) within_subj_stat.time(end)];
cfg.frequency   = [within_subj_stat.freq(1) within_subj_stat.freq(end)];
TFR_diff= ft_selectdata(cfg,TFR_diff);
TFR_diff.mask = within_subj_stat.negclusterslabelmat;

a,b = find(TFR_diff.mask(:)==1);
TFR_diff.mask(:) = 0;
TFR_diff.mask(b) = 1;


cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = neg{1}.channel;
cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [0 0.5]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot
cfg.maskparameter      = 'mask';
cfg.maskalpha      = 0.55;
ft_singleplotTFR2(cfg, TFR_diff);

ylabel('Frequency (Hz)', 'FontSize', 14);
xlabel('Time (s)', 'FontSize', 14);
ylabel(colorbar,'Power Difference (%)', 'FontSize', 14);
set(gca,'ylim',[8 40]);
set(gca, 'YTick', 0:4:40, 'YTickLabel', 0:4:40);
box on;



neg{1}.time = [0.05 0.12];
% power
cfg=[];
cfg.frequency     = [neg{1}.frequency(1) neg{1}.frequency(end)];%[9 17]
cfg.channel = neg{1}.channel;%{'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5', 'T7'};
cfg.avgoverfreq = 'yes';
cfg.avgoverchan = 'yes';
a = ft_selectdata(cfg,GA_CONV1);
a = squeeze(a.powspctrm);
b = ft_selectdata(cfg,GA_NOCH1);
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
set(gca,'ylim',[1.15 2]);
set(gca,'xlim',[0 0.5]);
box on;
grid on;


cfg = [];
cfg.ylim = [neg{1}.frequency(1) neg{1}.frequency(end)];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(TFR_diff.label,neg{1}.channel));
cfg.interactive        = 'no';
cfg.highlight          =  'off';
cfg.highlightsymbol    =  '.';
cfg.highlightcolor     = [1 1 1];
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
    ft_topoplotER(cfg, TFR_diff);hold on;
    TextH = text(-0.25, -0.7, ['[' num2str(cfg.xlim(1)) 's ' num2str(cfg.xlim(2)) 's]'],  'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom','FontSize',12);
    
end
c = colorbar('southoutside','Position',[0.17 0.35 0.65 0.03]);
c.Label.String = 'Power Difference (%)';
c.Ticks = [-0.25,-0.15,0,0.15,0.25];
c.FontSize = 15;

AxesH = axes('Parent', h,   'Units', 'normalized', 'Position', [0, 0, 1, 1],   'Visible', 'off','XLim', [0, 1], 'YLim', [0, 1],   'NextPlot', 'add');
TextH = text(0.40, 0.65, 'Listen (21-29 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',20);





X = TFR_diff;
cfg = [];
cfg.ylim = [neg{1}.frequency(1) neg{1}.frequency(end)];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(TFR_diff.label,neg{1}.channel));
cfg.interactive        = 'no';
cfg.highlight          =  'off';
cfg.highlightsymbol    =  '.';
cfg.highlightcolor     = [1 0 0];
cfg.shading            = 'interp' ;
cfg.gridscale          = 100;
cfg.markercolor        = [0 0 0];
cfg.highlightsize      = 25;
cfg.zlim    = [-0.25 0.25];
cfg.markersymbol       = '.';
cfg.highlight          =  'on';
ft_topoplotER(cfg, X);
colormap(white)








cfg = [];
cfg.ylim = neg{1}.frequency;
cfg.layout  = 'biosemi64.lay';
cfg.marker           = 'labels';
cfg.interpolatenan     ='no';
cfg.style            = 'straight';
cfg.xlim = [0.2 0.3];
figure;ft_topoplotER(cfg, X);

% cfg=[];
% cfg.channel = {'O2'};
% cfg.avgoverchan ='yes';
% cfg.latency = [0.2 0.3];
% cfg.avgovertime ='yes';
% cfg.frequency = neg{1}.frequency;
% cfg.avgoverfreq = 'yes';
% c = ft_selectdata(cfg, X);
% 
% a = ft_selectdata(cfg, GA_CONV1);
% b = ft_selectdata(cfg, GA_NOCH1);
% 
% a = ft_selectdata(cfg, CONV_tf{12});
% b = ft_selectdata(cfg, NOCH_tf{12});
% 
% 
% CONV_tf1=CONV_tf;NOCH_tf1=NOCH_tf;
% 
% CONV_tf1{3}.powspctrm(3,:,:,:) = 0;
% NOCH_tf1{3}.powspctrm(22,:,:,:) = 0;
% 
% [GA_CONV1,GA_NOCH1,TFR_diff] = recompute_conv_tf(CONV_tf1,NOCH_tf1);
% 
% 






















































