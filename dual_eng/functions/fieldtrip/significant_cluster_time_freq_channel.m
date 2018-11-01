function [pos,neg] = significant_cluster_time_freq_channel(stat)
% find relevant clusters
pos=[];neg=[];
if (isfield(stat,'posclusters'))
    if not(isempty(stat.posclusters))
        ipos = length(stat.posclusters);
        % loop over all sig positive clusters
        time = [];
        channel = [];
        prob = [];
        for i=ipos
            % find the significant time range for this cluster
            tmp=[];
            for t = 1:length(stat.time)
                if ~isempty(find(any(stat.posclusterslabelmat(:,t)==ipos)))
                    tmp = [tmp t];
                end
            end
            time  = [time;stat.time(tmp(1)) stat.time(tmp(end))];
            
            % find the channels belonging to this cluster
            highlightchannel = [];
            for c = 1:length(stat.label)
                if ~isempty(find(any(stat.posclusterslabelmat(c,:)==ipos)))
                    highlightchannel = [highlightchannel stat.label(c)];
                end
            end
            channel = [channel;highlightchannel];
            prob = [prob;stat.posclusters(i).prob];
        end
        
        pos{1,1}.channel = channel;
        pos{1,1}.time = time;
        pos{1,1}.number = ipos;
        pos{1,1}.prob = prob;
    else
        pos = 0;
    end
else
    pos = 0;
end

%%
if(isfield(stat,'negclusters'))
    if not(isempty(stat.negclusters))
        ineg = length(stat.negclusters);
        % loop over all sig positive clusters
        time = [];
        channel = [];prob=[];
        for i=ineg
            % find the significant time range for this cluster
            tmp=[];
            for t = 1:length(stat.time)
                if ~isempty(find(any(stat.negclusterslabelmat(:,t)==ineg)))
                    tmp = [tmp t];
                end
            end
            time  = [time;stat.time(tmp(1)) stat.time(tmp(end))];
            
            % find the channels belonging to this cluster
            highlightchannel = [];
            for c = 1:length(stat.label)
                if ~isempty(find(any(stat.negclusterslabelmat(c,:)==ineg)))
                    highlightchannel = [highlightchannel stat.label(c)];
                end
            end
            channel = [channel;highlightchannel];
            prob = [prob;stat.negclusters(i).prob];
        end
        
        neg{1,1}.channel = channel;
        neg{1,1}.time = time;
        neg{1,1}.number = ineg;
        neg{1,1}.prob = prob;
    else
        neg = 0;
    end
else
    neg = 0;
end


end