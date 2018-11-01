function [convergence_score,divergence,convergence_A,convergence_B,rare_event,scoreAB,th] = convergence_condition3(g,session_data,fake_event_dist_diff,D,gmmScores,project,ztransform)

fA = gmmScores(session_data(:,1));
fB = gmmScores(session_data(:,2));

%% pretest threshold
% set convergence threshold for each group
tempA = find(D(:,1)== project.subjects.group_no(g,1) &  D(:,2) == 1);
tempB = find(D(:,1)== project.subjects.group_no(g,2) &  D(:,2) == 1);
%
ScoreA = gmmScores(tempA);
ScoreB = gmmScores(tempB);

% % zscore transform
if(ztransform)
    ScoreA = [ScoreA;fA];
    ScoreB = [ScoreB;fB];
    ScoreA = zscore(ScoreA(~isnan(ScoreA)));
    ScoreB = zscore(ScoreB(~isnan(ScoreB)));
end

% compute the upper and lower of the pretest distribution
subB_conv_threshold = nanmean(ScoreB)+project.convergence.fakestd*nanstd(ScoreB);
subB_div_threshold = nanmean(ScoreB)-project.convergence.fakestd*nanstd(ScoreB);

subA_div_threshold = nanmean(ScoreA)+project.convergence.fakestd*nanstd(ScoreA);
subA_conv_threshold = nanmean(ScoreA)-project.convergence.fakestd*nanstd(ScoreA);

Pre_th = [subA_conv_threshold subA_div_threshold subB_conv_threshold subB_div_threshold];

%% fake distribution
fake_diff_score = [];
for i=1:length(fA)
    event_fake_dist = fake_event_dist_diff{i};

% dont combine male female
    if(project.subjects.gender{g}=='m')
        tempA = D(event_fake_dist,1);
        a = find(ismember(tempA,project.subjects.female));
        event_fake_dist(a) = 0;
        a = find(event_fake_dist(:,1) .* event_fake_dist(:,2));
        event_fake_dist = event_fake_dist(a,:);
    else
        tempA = D(event_fake_dist,1);
        a = find(ismember(tempA,project.subjects.male));
        event_fake_dist(a) = 0;
        a = find(event_fake_dist(:,1) .* event_fake_dist(:,2));
        event_fake_dist = event_fake_dist(a,:);
    end
    
    a = event_fake_dist(randperm(length(event_fake_dist)),:);
    
    ScoreA = gmmScores(a(:,1));
    ScoreB = gmmScores(a(:,2));
    fake_diff_score{i,1} = (ScoreA - ScoreB);
end

%%
convergence_score = nan(length(fA),2);
divergence = convergence_score;
convergence_A = convergence_score;
convergence_B = convergence_score;
rare_event = convergence_score;
scoreAB = convergence_score;
%% condition 1 (if they are in defind boundary)
for i=1:length(fA)
    mean_win_A = fA(i);
    mean_win_B = fB(i);
    
    if(mean_win_A <= subA_conv_threshold && mean_win_B >= subB_conv_threshold)
        convergence_score(i,:) = [subA_conv_threshold-mean_win_A  mean_win_B-subB_conv_threshold];
        
    elseif(mean_win_A >= subA_div_threshold && mean_win_B <= subB_div_threshold)
        %         divergence(i,:) = [mean_win_A-subA_div_threshold  subB_div_threshold-mean_win_B];
        divergence(i,:) = [mean_win_A-subA_conv_threshold  subB_conv_threshold-mean_win_B];
        
    elseif(mean_win_A <= subA_conv_threshold && mean_win_B > subB_div_threshold && mean_win_B < subB_conv_threshold)
        convergence_A(i,:) = [subA_conv_threshold-mean_win_A mean_win_B-subB_conv_threshold];
        
    elseif(mean_win_A > subA_conv_threshold && mean_win_A < subA_div_threshold && mean_win_B >= subB_conv_threshold)
        convergence_B(i,:) = [mean_win_A-subA_conv_threshold mean_win_B-subB_conv_threshold];
    end
    
    scoreAB(i,:) = [subA_conv_threshold-mean_win_A  mean_win_B-subB_conv_threshold];
end

%% condition 2 (if they are not noise but actual phenomenon)
for i=1:length(fA)
    diff_score = (fA(i) - fB(i));
    event_fake_dist = (fake_diff_score{i});
    % z transform
    if(ztransform)
        event_fake_dist = [event_fake_dist;diff_score];
        event_fake_dist = zscore(event_fake_dist(~isnan(event_fake_dist)));
    end
    
    UP = nanmean(event_fake_dist)+project.convergence.fakestd*nanstd(event_fake_dist);
    LW = nanmean(event_fake_dist)-project.convergence.fakestd*nanstd(event_fake_dist);
    
    if(diff_score <= LW)
        rare_event(i,1) = diff_score - LW;        rare_event(i,2) = -100;
    elseif(diff_score >= UP)
        rare_event(i,1) = UP - diff_score;        rare_event(i,2) = -100;
    else
        rare_event(i,1) = abs(LW - diff_score);
        rare_event(i,2) = abs(UP - diff_score);
    end
end

%% posttest threshold
% set convergence threshold for each group
tempA = find(D(:,1)== project.subjects.group_no(g,1) &  D(:,2) == 6);
tempB = find(D(:,1)== project.subjects.group_no(g,2) &  D(:,2) == 6);
%
ScoreA = gmmScores(tempA);
ScoreB = gmmScores(tempB);

% % zscore transform
if(ztransform)
    ScoreA = [ScoreA;fA];
    ScoreB = [ScoreB;fB];
    ScoreA = zscore(ScoreA(~isnan(ScoreA)));
    ScoreB = zscore(ScoreB(~isnan(ScoreB)));
end

% compute the upper and lower of the pretest distribution
subB_conv_threshold = nanmean(ScoreB)+project.convergence.fakestd*nanstd(ScoreB);
subB_div_threshold = nanmean(ScoreB)-project.convergence.fakestd*nanstd(ScoreB);

subA_div_threshold = nanmean(ScoreA)+project.convergence.fakestd*nanstd(ScoreA);
subA_conv_threshold = nanmean(ScoreA)-project.convergence.fakestd*nanstd(ScoreA);

Post_th = [subA_conv_threshold subA_div_threshold subB_conv_threshold subB_div_threshold];


%%
th = [Pre_th Post_th];

end