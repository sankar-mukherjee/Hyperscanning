
clear;clc;
freq_band = [0.5 2;1 4;2 6;4 8;8 12;12 18;18 24;24 36; 30 40];
dd = 41;


target_channels = 'all';

MI = zeros(length(freq_band),4,dd);
MI_std = zeros(length(freq_band),4,dd);


for f=1:length(freq_band)
    load(['MI_conv_noch_' num2str(freq_band(f,1)) '_' num2str(freq_band(f,2)) '.mat'])
    
    for j=1:4
        if(j==4)
            name = 'phase_phase';            A = MI_phase_phase;
        elseif(j==3)
            name = 'phase_amp';            A = MI_phase_amp;
        elseif(j==2)
            name = 'amp_phase';            A = MI_amp_phase;
        elseif(j==1)
            name = 'amp_amp';            A = MI_amp_amp;
        end
        
        all=[];
        for subj= 1:length(A)
            all{subj,1} = ft_appenddata([], A{subj,1}, A{subj,2});
        end
        cfg = [];
        cfg.channles = 1:64;
        GA_avg=[];
        for subj=1:length(A)
            GA_avg{subj,1}  = ft_timelockanalysis(cfg,   all{subj,1});
        end
        
        cfg=[];
        GA = ft_timelockgrandaverage(cfg,GA_avg{:});
        %%
        for d=1:dd            
            cfg=[];
            cfg.channel = target_channels;
            cfg.avgoverchan = 'yes';
            cfg.latency     = d;
            a = ft_selectdata(cfg,GA);
            
            MI(f,j,d) = a.avg;
            MI_std(f,j,d) = a.var;
        end
        
        
    end
end

save('delay_MI.mat','MI','MI_std');
%%
for d=1:dd    
    for cond=1:4
        A = squeeze(MI(:,cond,d));
        AA = squeeze(MI_std(:,cond,d));
        errorbar(1:length(freq_band),A,AA,'-o');
        hold on;        
    end
    legend('amp-amp', 'amp-phase', 'phase-amp', 'phase-phase');
    xlabel(gca,'freq');
    ylabel(gca,'MI')    
%     set(gca,'Xticklabel',[0;freq_band(:,1)])
    xlim([6 10])

    set(gca,'xlim',[4 end])
    saveas(gcf,['delay ' num2str(d) '.png']);close all;
end













