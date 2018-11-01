
clear;clc;
freq_band = [0.5 2;1 4;2 6;4 8;8 12;12 18;18 24;24 36; 30 40];dd=41;

load('beta_coeff_MI.mat')
load('listen_entrainment.mat');

ALL.stat = zeros(length(freq_band),4,64,dd);
ALL.mask = ALL.stat;

for d=1:dd
    
    for j=1:4
        close all;
        
        if(j==4)
            name = 'phase_phase';
        elseif(j==3)
            name = 'phase_amp';
        elseif(j==2)
            name = 'amp_phase';
        elseif(j==1)
            name = 'amp_amp';
        end
        for f=1:length(freq_band)
            %% group
            a=squeeze(MI_betaCoeff_group_stat(f,j,d));
            
            %             a=squeeze(MI_group_stat(f,j,d));
            a=a{1,1};
            ALL.stat(f,j,:,d) = a.stat;
            ALL.mask(f,j,:,d) = a.mask;
        end
        
        a = squeeze(ALL.stat(:,j,:,d));
        b = squeeze(ALL.mask(:,j,:,d));
        
        if not(sum(b(:))==0)
            FigHandle = figure('Position',[1950 160 1100 930]);
            
            for freq=1:length(freq_band)
                % cluster
                cfg = [];
                cfg.comment = 'no';
                cfg.commentpos = 'title';
                cfg.layout  = 'biosemi64.lay';
                cfg.style            = 'straight';
                cfg.marker           = 'off';
                cfg.highlightchannel   = find(b(freq,:));
                cfg.interactive        = 'no';
                cfg.highlight          =  'on';
                cfg.highlightsymbol    =  '.';
                cfg.highlightcolor     = [1 0 0];
                cfg.shading            = 'interp' ;
                cfg.gridscale          = 100;
                cfg.markercolor        = [0 0 0];
                cfg.highlightsize      = 10;
                cfg.zlim    = [-4 4];
                cfg.parameter          = 'mi';
                %                 cfg.maskparameter      = 'mask';
                cfg.colorbar           = 'yes';
                cfg.xlim = [0 1];
                
                
                A=[];
                A.label = data{1,1}.label(1:64)';
                A.mi = a(freq,:)';
                A.mask = b(freq,:)';
                A.time = 1:41;
                A.dimord = 'subj_chan_time';
                
                subplot(3,3,freq);
                ft_topoplotER(cfg, A);
                hold on;
                title(num2str(freq_band(freq,:)))
            end
            
            %             saveas(FigHandle,[name '_delay_' num2str(d) '_group_mi_convNoch_topoplot.png']);
            saveas(FigHandle,[name '_delay_' num2str(d) '_group_miRegression_topoplot.png']);
            close all;
        end
    end
end





























