
path = 'C:/Users/SMukherjee/Desktop/data/dual_eng/mat/fieldtrip_clustering';
[filename,type,prob,freq,time,location] = import_fieldtripCluster([path '/convVSnoch_listen_filedtrip_clustering_result.csv']);
[filename,type,prob,freq,time,location] = import_fieldtripCluster([path '/convVSnoch_filedtrip_clustering_result.csv']);

load('fake_topo.mat');

speech_time_window = [-0.7 -0.2];
listen_time_window = [0 0.8];

%%
time_window = listen_time_window;
file_name222 = 'listen';
time_window = speech_time_window;
file_name222 = 'speech';

cfg= [];
cfg.layout    = 'biosemi64.lay';
cfg.comment          = 'no';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlight          = 'labels';
cfg.highlightsymbol    =  '.';
cfg.interactive        = 'no';
cfg.colorbar           = 'yes';
cfg.zlim = [-0.05 0.05];

for i =1:30
    idx = find(freq==i);
    k=1;
    A = length(idx)*2;
    
    if(~isempty(idx))
        FigHandle1 = figure('Position', [100, 100, 1920, 1200]);        
        for j=1:length(idx)
            data = fake_topo;
            data.powspctrm = data.powspctrm + -0.05;
            cfg.highlightchannel   =  strsplit(location{idx(j)},' ');
            T = strsplit(time{idx(j)},' ');
            
            idx1 = find(ismember(data.label,cfg.highlightchannel));
            data.powspctrm(:,idx1,:,:) = prob(idx(j));
            
            subplot(A,1,k);k=k+1;
            ft_topoplotER(cfg,data);
            subplot(A,1,k);k=k+1;
            ha = area([str2num(T{1}) str2num(T{2})], [1 1]);hold on;
            set(gca,'xlim',[time_window(1) time_window(2)]);
            set(gca,'xtick',time_window(1):0.05:time_window(2));
            set(get(gca,'XLabel'),'String',[num2str(prob(idx(j))) ' - ' filename{idx(j)}]);
        end
        saveas(FigHandle1,[project.paths.figures '/Filedtrip_cluster_Freq_' num2str(i) '_' file_name222 '.fig']);
        saveas(FigHandle1,[project.paths.figures '/Filedtrip_cluster_Freq_' num2str(i) '_' file_name222 '.tif']);
        close all;
    end
end