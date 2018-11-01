function trainSpeakerData = get_gmm_trainData(group,D,mfc)

 %% train data two speaker
    trainSpeakerData = [];
    idx_A = find(D(:,1)==group(1) & D(:,2)== 1);
    
    subA = mfc(idx_A);
    
    idx_B = find(D(:,1)==group(2) & D(:,2)== 1);
    
    subB = mfc(idx_B);
    
    
    for i=1:length(subA)
        subA{i,1} = subA{i,1}';
    end
    for i=1:length(subB)
        subB{i,1} = subB{i,1}';
    end
    trainSpeakerData{1,1} = cell2mat(subA)';
    trainSpeakerData{2,1} = cell2mat(subB)';
end