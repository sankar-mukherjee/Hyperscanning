function f=plot_cluster(stat,TFR_diff,clusterlabel,time)

figure;
neg = stat.negclusterslabelmat == clusterlabel;

sample_count = length(stat.time);
% number of temporal samples in the statistics object
j = time;   % Temporal endpoints (in seconds) of the ERP average computed in each subplot
m = [1:sample_count];  % temporal endpoints in MEEG samples
for k = 1:length(stat.time)-1;
    subplot(3,4,k);
    cfg = [];
    cfg.xlim=[j(k) j(k+1)];   % time interval of the subplot
    %      cfg.zlim = [-2.5e-13 2.5e-13];
    % If a channel reaches this significance, then
    % the element of pos_int with an index equal to that channel
    % number will be set to 1 (otherwise 0).
    
    % Next, check which channels are significant over the
    % entire time interval of interest.
    neg_int = sum(sum(neg(:, :,m(k):m(k+1)), 3),2);
    cfg.highlight = 'on';
    cfg.highlightcolor        = [1 1 1];
    cfg.marker             = 'off';
    cfg.highlightchannel = find(neg_int);
    cfg.comment = 'xlim';
    cfg.commentpos = 'title';
    cfg.layout = 'biosemi64.lay';
    cfg.interactive = 'no';
    ft_topoplotER(cfg, TFR_diff);
end


end