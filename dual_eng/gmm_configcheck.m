%%
load([project.paths.processedData '/processed_data_word_level.mat'],'D');

filelist = dir([project.paths.processedData '/GMM_configs/GMM_scores_*.mat']);

pre = zeros(16,length(filelist));
post = zeros(16,length(filelist));

for i=1:length(filelist)
    gmm = load([project.paths.processedData '/GMM_configs/' filelist(i).name],'gmmScores');
    gmm = sum(gmm.gmmScores,2);
    
    for s=1:16
        a = find(D(:,1)==s & D(:,2) == 1);
        pre(s,i) = mean(gmm(a));
        a = find(D(:,1)==s & D(:,2) == 6);
        post(s,i) = mean(gmm(a));
    end
end