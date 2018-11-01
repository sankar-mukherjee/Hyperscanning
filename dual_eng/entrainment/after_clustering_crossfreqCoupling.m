
clear;clc;
freq_band = [0.5 2;1 4;2 6;4 8;8 12;12 18;18 24;24 36; 30 40];

for j=1:4
    
    for f=1:length(freq_band)
        
        load(['MI_conv_noch_' num2str(freq_band(f,1)) '_' num2str(freq_band(f,2)) '.mat'])
        
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
        %% subject 
        jj=0;
        for i=1:14
            if not(sum(sum(subj_stat{i, j}.mask))==0)
                A = subj_stat{i, j};
                cfg = [];
                cfg.parameter = 'stat';
                cfg.layout = 'biosemi64.lay';
                ft_clusterplot(cfg, A);
                FigHandle = gcf;
                set(FigHandle, 'Position', [100, 100, 1049, 895]);
                if(i>3)
                    jj=i+2;
                else
                    jj=i;
                end
                saveas(FigHandle,[name '_' num2str(freq_band(f,1)) '_' num2str(freq_band(f,2)) '_subj_' num2str(jj) '.png']);
                close all;
                
            end
            
        end
        
        %% group
            if not(sum(sum(group_stat{j, 1}.mask))==0)
                A = group_stat{j, 1};
                cfg = [];
                cfg.parameter = 'stat';
                cfg.layout = 'biosemi64.lay';
                ft_clusterplot(cfg, A);
                FigHandle = gcf;
                set(FigHandle, 'Position', [100, 100, 1049, 895]);
               
                saveas(FigHandle,[name '_' num2str(freq_band(f,1)) '_' num2str(freq_band(f,2)) '_group.png']);
                close all;
                
            end
        
        
    end
    
    
    
end





















