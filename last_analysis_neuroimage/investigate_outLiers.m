%% investigate outliers
clear;clc;



%% prespeech
load('postlisten_tf.mat')




GA_CONV=[];GA_NOCH=[];k=1;
for i=[1:16]
    C =    CONV_tf{i};
    
    if(i==10)
        C.powspctrm = C.powspctrm([2:end],:,:,:);
    elseif(i==14)
        C.powspctrm(:,15,:,:) = 0;
        N.powspctrm(:,15,:,:) = 0;
    end
    
    C = ft_freqdescriptives([], C);
    N =  NOCH_tf{i};
    N = ft_freqdescriptives([], N);
    
    GA_CONV{k} = C;
    GA_NOCH{k}  = N;
    
    k=k+1;
end




AA = [1:7 9 11:13 15:16];
AA = [1:13 15:16];
AA=1:16;
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






within_subj_stat = within_subj_tf_cluster(GA_CONV1,GA_NOCH1,neighbours,[8 40],16, [-0.5 0]);
[pos,neg] = significant_cluster_time_freq_channel(within_subj_stat,0.05);



























GA_CONV=[];GA_NOCH=[];k=1;
for i=[1:16]
    GA_CONV{k}= ft_math(cfg, CONV_tf{i});
    GA_CONV{k} = ft_freqdescriptives([],GA_CONV{k});
    
    GA_NOCH{k}= ft_math(cfg, NOCH_tf{i});
    GA_NOCH{k}  = ft_freqdescriptives([],GA_NOCH{k});
    k=k+1;
end

figure;

A=[];
for i=1:15
    C =    CONV_tf{i};
    %     C = z_score_transformation(C);
    C = ft_freqdescriptives([], C);
    N =  NOCH_tf{i};
    %     N = z_score_transformation(N);
    N = ft_freqdescriptives([], N);
    
    cfg = [];
    cfg.channel   = 'all';
    cfg.latency   = 'all';
    cfg.parameter = 'powspctrm';
    C = ft_freqgrandaverage(cfg, C);
    N = ft_freqgrandaverage(cfg, N);
    
    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = '(x1-x2)./x2';
    TFR_diff     = ft_math(cfg, C, N);
    
    cfg=[];
    cfg.channelname = {'FC6'};
    cfg.avgoverchan ='yes';
    cfg.latency = [0.3 0.4]; % Specify the time range to plot
    cfg.avgovertime ='yes';
    cfg.frequency = [25 29]; % Specify the time range to plot
    cfg.avgoverfreq = 'yes';
    %         a = ft_selectdata(cfg, TFR_diff);
    %     A=[A;a.powspctrm];
    
    a = ft_selectdata(cfg, C);b = ft_selectdata(cfg, N);
    
    A=[A;a.powspctrm b.powspctrm];
    
    %     cfg = [];
    %     cfg.marker  = 'on';
    %     cfg.layout  = 'biosemi64.lay';
    %     cfg.channelname   = {'P3'};
    %     cfg.zlim = [-0.3 0.3]; % Specify the time range to plot
    %     cfg.xlim = [0.2 0.3]; % Specify the time range to plot
    %     cfg.ylim = [25 29]; % Specify the time range to plot
    %     %     cfg.marker           = 'labels';
    %     cfg.style            = 'straight';
    %     cfg.comment = 'no';
    %
    %     %     figure;
    %     subplot(4,4,i)
    %     ft_topoplotER(cfg, TFR_diff);
    %     ft_singleplotTFR(cfg, TFR_diff);
    %     ylabel('Frequency (Hz)', 'FontSize', 14);
    %     set(gca,'ylim',[9 17]);
    %     set(gca, 'YTick', 0:4:40, 'YTickLabel', 0:4:40);
end

    figure; ft_singleplotTFR(cfg, C);
    figure; ft_singleplotTFR(cfg, N);
    
    
    cfg = [];
    cfg.marker  = 'on';
    cfg.layout  = 'biosemi64.lay';
    cfg.xlim = [-0.5 0]; % Specify the time range to plot
    cfg.ylim = [8 40]; % Specify the time range to plot
    figure; ft_multiplotTFR(cfg, C);
    
    cfg=[];
    cfg.channelname = {'P3'};
    cfg.avgoverchan ='yes';
    cfg.latency = [-0.5 -0.4]; % Specify the time range to plot
    cfg.avgovertime ='yes';
    cfg.frequency = [9 17]; % Specify the time range to plot
    cfg.avgoverfreq = 'yes';
    A = ft_selectdata(cfg, NOCH_tf{7});


A = [];
for i=1:15
    A = [A;size(CONV_tf{1, i}.powspctrm) 0 size(NOCH_tf{1, i}.powspctrm)];
end
A = A(:,[1 6]);





%% topo


h=figure;
A=[];
for i=1:15
    C =    CONV_tf{i};
    N =  NOCH_tf{i};
     if(i==12)
        C = avg_with_neighbour(C,'FC6','FC4',neighbours);
        N = avg_with_neighbour(N,'FC6','FC4',neighbours);
    end
    
    C = ft_freqdescriptives([], C);
    N = ft_freqdescriptives([], N);
    
    cfg = [];
    cfg.channel   = 'all';
    cfg.latency   = 'all';
    cfg.parameter = 'powspctrm';
    C = ft_freqgrandaverage(cfg, C);
    N = ft_freqgrandaverage(cfg, N);
    
    cfg = [];
    cfg.parameter = 'powspctrm';
    cfg.operation = '(x1-x2)./x2';
    TFR_diff     = ft_math(cfg, C, N);
    
    cfg = [];
    cfg.marker  = 'on';
    cfg.layout  = 'biosemi64.lay';
%     cfg.zlim = [-0.4 0.5]; % Specify the time range to plot
    cfg.xlim = [0.3 0.4]; % Specify the time range to plot
    cfg.ylim = [25 29]; % Specify the time range to plot
        cfg.marker           = 'labels';
    cfg.style            = 'straight';
    cfg.comment = 'no';
    subplot(4,4,i)
    ft_topoplotER(cfg, TFR_diff);
    title(i)
end

subplots = get(h,'Children'); % Get each subplot in the figure
for i=1:length(subplots) % for each subplot
    caxis(subplots(i),[-2 2]); % set the clim
end







