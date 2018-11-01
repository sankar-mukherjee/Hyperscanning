%%
function trl = mytrialfun(cfg)

% this function requires the following fields to be specified
% cfg.dataset
% cfg.trialdef.eventtype
% cfg.trialdef.eventvalue
% cfg.trialdef.prestim
% cfg.trialdef.poststim

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for "trigger" events
value  = [event(find(ismember({event.type}, cfg.trialdef.eventtype))).value]';
sample = [event(find(ismember({event.type}, cfg.trialdef.eventtype))).sample]';

% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.prestim  * hdr.Fs);
posttrig =  round(cfg.trialdef.poststim * hdr.Fs);

% look for the combination of a trigger "7" followed by a trigger "64" 
% for each trigger except the last one
trl = [];
for j = 2:(length(value)-1)
    trg1 = value(j);
    trg2 = value(j-1);
    if trg1==41 || trg1==42
        trlbegin = sample(j) + pretrig;
        trlend   = sample(j) + posttrig;
        offset   = pretrig;
        if trg2==31 || trg2==32
            newtrl   = [trlbegin trlend offset trg1 (sample(j) - sample(j-1))];
            trl      = [trl; newtrl];
        end
    end
end
end
