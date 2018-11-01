function [GA_CONV1,GA_NOCH1,TFR_diff] = recompute_conv_tf(CONV_tf,NOCH_tf)


GA_CONV=[];GA_NOCH=[];k=1;
for i=[1:15]
    C =    CONV_tf{i};   
    
    C = ft_freqdescriptives([], C);
    N =  NOCH_tf{i};
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

end