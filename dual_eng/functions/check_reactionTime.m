function idx = check_reactionTime(target_idx,D,reactionTime)
%% remove outliers according to reaction time (1 sec max)
RT = D(target_idx,14);
A = find(RT<=reactionTime);           % 1.5 sec max reaction time
B = find(RT>0.1);           % 1.5 sec max reaction time
RT = intersect(A,B);
idx = target_idx(RT);

end