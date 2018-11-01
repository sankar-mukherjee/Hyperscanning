
load([project.paths.processedData '/processed_data_word_level.mat'],'D','W');
load([project.paths.processedData '/GMM_configs/GMM_scores_' num2str(project.gmmUBM.gmmcomp) '_10_mwv_mfc.mat']);
load('SPIC_text.mat', 'Oindex_comb');
load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\surrogate_trial.mat','s_comb')

gmmScores = sum(gmmScores,2);
ztransform = 0;
A = [];TH = [];
for g=1:length(project.subjects.group)
    sub = project.subjects.group_no(g,1);
    partner = project.subjects.group_no(g,2);
    fake_event_dist_diff = reshape(s_comb,99,4);
    
    ALL = [];
    for session= 1:4
        a = find(Oindex_comb(:,4)==session & Oindex_comb(:,5)==sub & Oindex_comb(:,6)==partner);
        session_data = Oindex_comb(a,1:2);
        [convergence_score,divergence,convergence_A,convergence_B,rare_event,scoreAB,th] = convergence_condition3(g,session_data,fake_event_dist_diff(:,session),D,gmmScores,project,ztransform);
        
        ALL{session,1} = convergence_score;
        ALL{session,2} = divergence;
        ALL{session,3} = convergence_A;
        ALL{session,4} = convergence_B;
        ALL{session,5} = rare_event;
        ALL{session,6} = scoreAB;

    end
    A{g,1} = [cell2mat(ALL(:,1)) cell2mat(ALL(:,2)) cell2mat(ALL(:,3)) cell2mat(ALL(:,4)) cell2mat(ALL(:,5)) cell2mat(ALL(:,6))];
    TH{g,1} = th;
end
convergence_data = cell2mat(A);     TH = cell2mat(TH);

save([project.paths.processedData '/convergence/convergence_' num2str(project.gmmUBM.gmmcomp) '_new_versioncode.mat'],'convergence_data','TH');

















