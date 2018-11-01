function [pos,neg] = significant_cluster_time_freq_channel(stat,sig)
% find relevant clusters
pos=[];neg=[];
if (isfield(stat,'posclusters'))
    if not(isempty(stat.posclusters))
        ipos = 1:length(stat.posclusters);
        % loop over all sig positive clusters
        
        for i=1:length(stat.posclusters)
            if(stat.posclusters(i).prob<=sig)
                time = [];
                channel = [];frequency=[];
                prob = [];
                % find the significant time range for this cluster
                tmp=[];
                for t = 1:length(stat.time)
                    if ~isempty(find(any(stat.posclusterslabelmat(:,:,t)==i)))
                        tmp = [tmp t];
                    end
                end
                time  = [time;stat.time(tmp(1)) stat.time(tmp(end))];
                
                % find the channels belonging to this cluster
                highlightchannel = [];
                for c = 1:length(stat.label)
                    if ~isempty(find(any(stat.posclusterslabelmat(c,:,:)==i)))
                        highlightchannel = [highlightchannel stat.label(c)];
                    end
                end
                channel = [channel;highlightchannel];
                
                % find the freq belonging to this cluster
                freq = [];
                for f = 1:length(stat.freq)
                    if ~isempty(find(any(stat.posclusterslabelmat(:,f,:)==i)))
                        freq = [freq stat.freq(f)];
                    end
                end
                frequency = [frequency;freq];
                
                
                prob = [prob;stat.posclusters(i).prob];
                
                
                pos{i,1}.channel = channel;
                pos{i,1}.time = time;
                pos{i,1}.frequency = frequency;
                pos{i,1}.number = ipos;
                pos{i,1}.prob = prob;
            end
        end
        
    else
        pos = 0;
    end
else
    pos = 0;
end

%%
if(isfield(stat,'negclusters'))
    if not(isempty(stat.negclusters))
        ineg = 1:length(stat.negclusters);
        % loop over all sig positive clusters
        
        for i=1:length(stat.negclusters)
            if(stat.negclusters(i).prob<=sig)
                time = [];
                channel = [];prob=[];frequency=[];
                % find the significant time range for this cluster
                tmp=[];
                for t = 1:length(stat.time)
                    if ~isempty(find(any(stat.negclusterslabelmat(:,:,t)==i)))
                        tmp = [tmp t];
                    end
                end
                time  = [time;stat.time(tmp(1)) stat.time(tmp(end))];
                
                % find the channels belonging to this cluster
                highlightchannel = [];
                for c = 1:length(stat.label)
                    if ~isempty(find(any(stat.negclusterslabelmat(c,:,:)==i)))
                        highlightchannel = [highlightchannel stat.label(c)];
                    end
                end
                channel = [channel;highlightchannel];
                
                % find the freq belonging to this cluster
                freq = [];
                for f = 1:length(stat.freq)
                    if ~isempty(find(any(stat.negclusterslabelmat(:,f,:)==i)))
                        freq = [freq stat.freq(f)];
                    end
                end
                frequency = [frequency;freq];
                
                prob = [prob;stat.negclusters(i).prob];
                
                neg{i,1}.channel = channel;
                neg{i,1}.time = time;
                neg{i,1}.frequency = frequency;
                neg{i,1}.number = ineg;
                neg{i,1}.prob = prob;
            end
        end
        
    else
        neg = 0;
    end
else
    neg = 0;
end


end