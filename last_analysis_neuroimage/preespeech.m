

clear;clc;

load('prespeech.mat')


data_conv2 = data_conv;
data_noCh2 = data_noCh;

Nsub = length(data_conv2);

% trial no in both cond
a=[];b=[];
for i=1:Nsub
    a = [a size(data_conv2{i,1}.trial,2)];
    b = [b size(data_noCh2{i,1}.trial,2)];
end
sum(a)
sum(b)


cfg.method    = 'distance';
neighbours       = ft_prepare_neighbours(cfg, data_conv2{1});


 %% rereference
 cfg = [];
 cfg.reref       = 'yes';
 cfg.channel = {'all'};
 cfg.refchannel = {'all'};
 
 for i = 1: length(data_conv2)
     
     data_conv2{i}        = ft_preprocessing(cfg,data_conv2{i});
     
     data_noCh2{i}        = ft_preprocessing(cfg,data_noCh2{i});
     
     cfgg = [];
     cfgg.latency = [-0.5 0];
     data_conv2{i}        = ft_selectdata(cfgg,data_conv2{i});
     data_noCh2{i}        = ft_selectdata(cfgg,data_noCh2{i});
 end
 
 
 A =  -1:0.0039:-0.5;
 B = 0:0.0039:0.5;
 nsamples = 129;
 for i = 1: length(data_conv2)
     for j = 1: length(data_conv2{i}.trial)
         data_conv2{i}.trial{j} = ft_preproc_padding(data_conv2{i}.trial{j}, 'zero', nsamples, nsamples);
         data_conv2{i}.time{j} = [A data_conv2{i}.time{j} B];
     end
     for j = 1: length(data_noCh2{i}.trial)
         data_noCh2{i}.trial{j} = ft_preproc_padding(data_noCh2{i}.trial{j}, 'zero', nsamples, nsamples);
         data_noCh2{i}.time{j} = [A data_noCh2{i}.time{j} B];
     end
 end
 
 
 
A = [];
for s=1:16
    A{s} = ft_appenddata([],data_conv2{s},data_noCh2{s}); 
    
end
[tf,~,GA_tf] = compute_ERSP(A,[-1 0.5],50/1e3,0);


 
%
[CONV_tf,~,GA_tf_CONV] = compute_ERSP(data_conv2,[-1 0.5],50/1e3,0);
[NOCH_tf,~,GA_tf_NOCH] = compute_ERSP(data_noCh2,[-1 0.5],50/1e3,0);





within_subj_stat = within_subj_tf_cluster(GA_tf_CONV,GA_tf_NOCH,neighbours,[8 40],16, [-0.5 0]);

[pos,neg] = significant_cluster_time_freq_channel(within_subj_stat,0.05);

plot_cluster(within_subj_stat,TFR_diff,1,[-0.5:0.05:0])







cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)./x2';
TFR_diff     = ft_math(cfg, GA_tf_CONV, GA_tf_NOCH);




cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5', 'T7'};
cfg.zlim = [-0.25 0.25]; % Specify the time range to plot
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [8 40]; % Specify the time range to plot
cfg.title          ='';
figure; ft_singleplotTFR(cfg, TFR_diff);
ylabel('Frequency (Hz)', 'FontSize', 14);
set(gca,'ylim',[8 40]);
set(gca, 'YTick', 0:4:40, 'YTickLabel', 0:4:40);
xlabel('Time (s)', 'FontSize', 14);
ylabel(colorbar,'Power Difference (%)', 'FontSize', 14);
title({'Convergence vs NoChange', ['mean(F3,F5,F7,FT7,FC5,C5,T7)' ]}, 'FontSize', 12);

% power
cfg=[];
cfg.frequency     = [9 17];
cfg.channel = {'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5', 'T7'};
cfg.latency     = [-0.5 0];
cfg.avgoverchan = 'yes';
cfg.avgoverfreq = 'yes';
a = ft_selectdata(cfg,GA_tf_CONV);  
a = squeeze(a.powspctrm);
b = ft_selectdata(cfg,GA_tf_NOCH);
b = squeeze(b.powspctrm);
figure;hold on;
shadedErrorBar(1:size(a,2),mean(a),std(a)/16,{'-b','LineWidth',1,'markerfacecolor','b'});
shadedErrorBar(1:size(b,2),mean(b),std(b)/16,{'-r','LineWidth',1,'markerfacecolor','r'},0.9);
ylabel('Power (\muV^{2})', 'FontSize', 14);
xlabel('Time (s)', 'FontSize', 14);
set(gca, 'XTick', 1:size(a,2), 'XTickLabel', [-0.5:0.05:0]);
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
alpha(h1,1);
alpha(h2,0.9);
legend([h1 h2],{'Convergence','NoChange'},'Orientation','verticle','FontSize',12);
h1 = area([3 7],[1.2 1.2],1.2-0.2);
set(h1,'Facecolor',[0.5 0.5 0.5]);
alpha(h1,0.5);set(h1,'EdgeColor','None');
set(gca,'ylim',[1.1 4.5]);
set(gca,'xlim',[1 11]);
% title({'mean(F3,F5,F7,FT7,FC5,C5,T7) Power', 'in (9-17 Hz) Frequency'});
box on;
grid on;

% topo plot timeline fix (make high value to 0 for good figure)
X = TFR_diff;
X.powspctrm(:,21,[5:9],[11:13 19:21]) = 0;
X.powspctrm(:,49,[5:9],[19:21]) = 0;
X.powspctrm(:,[1 2 3 33],:,:) = 0;

% X = GA_tf;


% TFR_diff.powspctrm(:)=0;
% cluster
cfg = [];
% cfg.xlim = [-0.5:0.5:0];
cfg.ylim = [9 17];
cfg.comment = 'no';
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(X.label,{'F3', 'F5', 'F7', 'FT7', 'FC5', 'C5', 'T7'}));
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
     TextH = text(-0.25, -0.7, ['[' num2str(cfg.xlim(1)) 's ' num2str(cfg.xlim(2)) 's]'],  'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom','FontSize',10);

end
c = colorbar('southoutside','Position',[0.17 0.35 0.65 0.03]);
c.Label.String = 'Power Difference (%)';
c.Ticks = [-0.25,-0.15,0,0.15,0.25];

AxesH = axes('Parent', h,   'Units', 'normalized', 'Position', [0, 0, 1, 1],   'Visible', 'off','XLim', [0, 1], 'YLim', [0, 1],   'NextPlot', 'add');
TextH = text(0.45, 0.65, 'PreSpeech (9-17 Hz)',  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','FontSize',14);
 

























cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
ft_multiplotTFR(cfg, TFR_diff);











for i=1:16
A = TFR_diff;
A.powspctrm = TFR_diff.powspctrm(i,:,:,:);

cfg = [];
cfg.marker  = 'on';
cfg.layout  = 'biosemi64.lay';
cfg.channelname   = {'F8' 'FT8' 'FC6' 'C6' 'TP8' 'CP6' 'CP4' 'CP2' 'P4' 'P6'};
cfg.xlim = [-0.5 0]; % Specify the time range to plot
cfg.ylim = [5 40]; % Specify the time range to plot
figure; ft_singleplotTFR(cfg, A);
title(num2str(i))
end

cfg = [];
cfg.layout  = 'biosemi64.lay';
cfg.ylim = [8 30]; % Specify the time range to plot
cfg.xlim = [0 0.5]; % Specify the time range to plot

figure;ft_multiplotTFR(cfg,TFR_diff);

























