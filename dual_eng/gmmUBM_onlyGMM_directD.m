function [gmmScores] = gmmUBM_onlyGMM_directD(project)

load([project.paths.processedData '/processed_data_word_level.mat']);

%% mfc raw , mfc feat wrap, mfc+f0,f1,f2,intensit = 43 (raw), same with feat wrap
input_data = mfc;
feat_name = 'mfc';

feat_name = strrep(feat_name ,'_' , '');
%%
gmmScores = zeros(size(D,1),8);
gmmScores_other = cell(8,1);
%% Train UBM
ubm = train_UBM(D,input_data, project.gmmUBM.gmmcomp, project.gmmUBM.itaration, 1, 1,project);

%%
for g=1:length(project.subjects.group)
    %% get gmm to be adapt traning data
    trainSpeakerData = get_gmm_trainData([project.subjects.group_no(g,1) project.subjects.group_no(g,2)],D,input_data);
    %% Adapt Speaker
    gmm = adapt_gmm(trainSpeakerData,2,project.gmmUBM.MAP_tau,project.gmmUBM.MAPconfig,ubm);
    
    %% get gmm prediction
    for speaker =1:2
        for session=1:length(project.session.list)
            idx_A = find(D(:,1)==project.subjects.group_no(g,speaker) & D(:,2)== session);
            subA = input_data(idx_A);
            
            trials = zeros(size(subA,1), 2);
            trials(:,2) = 1:size(subA,1);
            gmmScores(idx_A,g) = score_gmm_trials_onlyGMM(gmm, subA, trials);
        end
    end    
    
    %% geneate fake combination
    fake_group_combination = generate_fakeduets([project.subjects.group_no(g,1) project.subjects.group_no(g,2)],1,project);
    
    gmmScores_o = zeros(size(D,1),size(fake_group_combination,1));
    for fake = 1:length(fake_group_combination)
        trainSpeakerData = get_gmm_trainData(fake_group_combination(fake,:),D,input_data);
        gmm = adapt_gmm(trainSpeakerData,2,project.gmmUBM.MAP_tau,project.gmmUBM.MAPconfig,ubm);        
        
        for speaker =1:2
            for session=1:length(project.session.list)
                idx_A = find(D(:,1)==fake_group_combination(fake,speaker) & D(:,2)== session);
                subA = input_data(idx_A);
                
                trials = zeros(size(subA,1), 2);
                trials(:,2) = 1:size(subA,1);
                gmmScores_o(idx_A,fake) = score_gmm_trials_onlyGMM(gmm, subA, trials);
            end
        end        
    end
    
    gmmScores_other{g} = gmmScores_o;
    disp(['done--> ' num2str(g)]);
end

% original rows x model (each group)
save([project.paths.processedData '/GMM_configs/GMM_scores_' num2str(project.gmmUBM.gmmcomp) '_' num2str(project.gmmUBM.MAP_tau) '_' project.gmmUBM.MAPconfig '_' feat_name  '.mat'],'gmmScores','gmmScores_other');

end