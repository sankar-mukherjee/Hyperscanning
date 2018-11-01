function [event event_idx event_common_idx] = get_event_wordPair()
load('SPIC_text.mat');

for i=1:99
    event1(i,1) = duet_1(i);
    event1(i,2) = duet_1(i+1);
end

for i=1:99
    event2(i,1) = duet_2(i);
    event2(i,2) = duet_2(i+1);
end

event = [event1;event2];
event_idx = zeros(size(event));
event_common_idx = zeros(size(event));

for i=1:198
    event_idx(i,1) = find(ismember(SPIC_dict(:,1),event(i,1)));
    event_idx(i,2) = find(ismember(SPIC_dict(:,1),event(i,2)));
    a = find(ismember(keywords,event(i,1)));
    b = find(ismember(keywords,event(i,2)));
    if(isempty(a))
        a = 0;
    end
    if(isempty(b))
        b = 0;
    end
    event_common_idx(i,1) = a;
    event_common_idx(i,2) = b;
end

end