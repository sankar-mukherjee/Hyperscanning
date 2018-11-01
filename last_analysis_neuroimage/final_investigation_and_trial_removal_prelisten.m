clear;clc;close all;



%% prespeech
load('prelisten_tf.mat')

%%


GA_CONV=[];GA_NOCH=[];k=1;
for i=[1:15]
    C =    CONV_tf{i};
    N =  NOCH_tf{i};
    if(i==12)
%         C.powspctrm(6,:,:,:) = 0;
%         N.powspctrm(6,:,:,:) = 0;
    elseif(i==6)
%         C.powspctrm(2,:,:,:) = 0;
%         N.powspctrm(2,:,:,:) = 0;
    elseif(i==7 || i==2)
        
    end
   
    
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





load('neighbours.mat')


% 
% within_subj_stat = within_subj_tf_cluster(GA_CONV1,GA_NOCH1,neighbours,[6 40],15, [-0.5 0]);
% [pos,neg] = significant_cluster_time_freq_channel(within_subj_stat,0.05);


neg{1}.channel = { 'C4' 'CP4' 'CP6' 'C6'};
neg{1}.frequency = [21 25];
neg{1}.time = [-0.3 -0.2];


cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_CONV1, GA_NOCH1);



TFR_diff.mask = zeros(64,20,31);
TFR_diff.mask([50 51 54 55],11:12,15:16) = 1;
TFR_diff.mask([50 51 54 55],13,16) = 1;
TFR_diff.mask([50 51 54 55],12,15) = 0;
TFR_diff.mask([50 51 54 55],11,15) = 1;
% TFR_diff.mask([50 51 54 55],10,15) = 1;

cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = neg{1}.channel;%{'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5', 'T7'};
cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot
cfg.title          ='';
cfg.maskparameter      = 'mask';
cfg.maskalpha      = 0.55;
ft_singleplotTFR2(cfg, TFR_diff);
ylabel('Frequency (Hz)', 'FontSize', 14);
set(gca,'ylim',[8 40]);
set(gca, 'YTick', 0:4:40, 'YTickLabel', 0:4:40);
xlabel('Time (s)', 'FontSize', 14);
ylabel(colorbar,'Power Difference (%)', 'FontSize', 14);
% title({'Convergence vs NoChange', ['mean(F3,F5,F7,FT7,FC5,C5,T7)' ]}, 'FontSize', 12);
box on;


% power
cfg=[];
cfg.frequency     = [neg{1}.frequency(1) neg{1}.frequency(end)];
cfg.channel = neg{1}.channel;
cfg.avgoverfreq = 'yes';
cfg.avgoverchan = 'yes';
a = ft_selectdata(cfg,GA_CONV1);
a = squeeze(a.powspctrm);
b = ft_selectdata(cfg,GA_NOCH1);
b = squeeze(b.powspctrm);
time=GA_NOCH1.time;
figure;hold on;
shadedErrorBar(time,mean(a),std(a)/15,{'-b','LineWidth',1,'markerfacecolor','b'});
shadedErrorBar(time,mean(b),std(b)/15,{'-r','LineWidth',1,'markerfacecolor','r'},0.9);
set(gca,'xlim',[-0.5 0]);
ylabel('Power (\muV^{2})', 'FontSize', 14);
xlabel('Time (s)', 'FontSize', 14);
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,1);
alpha(h2,0.9);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',12);
h1 = area([neg{1}.time(1) neg{1}.time(2)],[0.65 0.65],0.7-0.1);
set(h1,'Facecolor',[0.5 0.5 0.5]);
alpha(h1,0.7);set(h1,'EdgeColor','None');
set(gca,'ylim',[0.6 1.8]);
box on;
grid on;

%%

GA_CONV=[];GA_NOCH=[];k=1;
for i=[1:15]
    C =    CONV_tf{i};
    N =  NOCH_tf{i};
    if(i==12)
        C.powspctrm(6,:,:,:) = 0;
        N.powspctrm(6,:,:,:) = 0;
    elseif(i==6)
        C.powspctrm(2,:,:,:) = 0;
        N.powspctrm(2,:,:,:) = 0;
    elseif(i==7 || i==2)
        
    end
   
    
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



cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_CONV1, GA_NOCH1);



neg{1}.channel = { 'C4' 'CP4' 'CP6' 'C6'};
neg{1}.frequency = [21 25];
neg{1}.time = [-0.3 -0.2];

X = TFR_diff;

% cluster
cfg = [];
cfg.ylim = [neg{1}.frequency(1) neg{1}.frequency(end)];%[9 17]
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(X.label,neg{1}.channel));
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

a = [-0.5:0.1:0];
h = figure('Position',[1950 160 1100 930]);
for k = 1:5;
    if(k==2|| k== 3)
        cfg.highlight          =  'on';
        
    else
        cfg.highlight          =  'off';
        
    end
    
    subplot(1,5,k);
    cfg.xlim = [a(k) a(k+1)];
    ft_topoplotER(cfg, X);hold on;
    TextH = text(-0.25, -0.7, ['[' num2str(cfg.xlim(1)) 's ' num2str(cfg.xlim(2)) 's]'],  'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom','FontSize',12);
    
end
c = colorbar('southoutside','Position',[0.17 0.35 0.65 0.03]);
c.Label.String = 'Power Difference (%)';
c.Ticks = [-0.25,-0.15,0,0.15,0.25];
c.FontSize = 15;

AxesH = axes('Parent', h,   'Units', 'normalized', 'Position', [0, 0, 1, 1],   'Visible', 'off','XLim', [0, 1], 'YLim', [0, 1],   'NextPlot', 'add');
TextH = text(0.40, 0.65, 'PreListen (21-25 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',20);




