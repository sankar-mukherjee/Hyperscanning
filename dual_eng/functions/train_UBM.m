function ubm = train_UBM(D,mfc, nmix, final_niter, ds_factor, nWorkers,project)
%% train data ALL speaker

trainSpeakerData = [];
m=1;
for g=1:length(project.subjects.group)
    idx_A = find(D(:,1)==project.subjects.group_no(g,1) &...
        D(:,2)== 1);
    subA = mfc(idx_A);
    
    idx_B = find(D(:,1)==project.subjects.group_no(g,2) &...
        D(:,2)== 1);
    subB = mfc(idx_B);
    
    for i=1:length(subA)
        subA{i,1} = subA{i,1}';
    end
    for i=1:length(subB)
        subB{i,1} = subB{i,1}';
    end
    
    trainSpeakerData{m,1} = cell2mat(subA)';m=m+1;
    trainSpeakerData{m,1} = cell2mat(subB)';m=m+1;
end

ubm = gmm_em(trainSpeakerData(:), nmix, final_niter, ds_factor, nWorkers);


end