function C = avg_with_neighbour(C,name,remove,neighbours)

idx1 = find(ismember(C.label,name));
idx = neighbours(idx1).neighblabel;

idx=setdiff(idx,remove);

A = [];
for i=1:length(idx)
    a = find(ismember(C.label,idx{i}));

    A=[A a];
end

avg = mean(C.powspctrm(:,A,:,:),2);

C.powspctrm(:,idx1,:,:) = avg;
end