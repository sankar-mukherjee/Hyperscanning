function f=fieldtrip_topoPlot(data,freq,time,location,zlim)

cfg = [];
cfg.xlim = time;
cfg.ylim = freq;
cfg.comment = num2str(freq);
cfg.commentpos = 'title';
cfg.layout  = 'biosemi64.lay';
cfg.style            = 'straight';
cfg.marker           = 'off';
cfg.highlightchannel   = find(ismember(data.label,location));
cfg.interactive        = 'no';
cfg.highlight          =  'on';
cfg.highlightsymbol    =  '.';
cfg.highlightcolor     = [1 0 0];
cfg.shading            = 'interp' ;
cfg.gridscale          = 100;
cfg.markercolor        = [0 0 0];
cfg.highlightsize      = 10;
cfg.zlim    = zlim;

ft_topoplotER(cfg, data);
end