function [convergence_score,divergence,convergence_A,convergence_B,rare_event] = convergence_condition2(fA,fB,fake_data, D,gmmScores,session, project,group,use_both_cond)
%% convergence condition
convergence_score = zeros(size(fA));
divergence = zeros(size(convergence_score));
convergence_A = zeros(size(convergence_score));
convergence_B = zeros(size(convergence_score));

rare_event = zeros(size(convergence_score));

%% set convergence threshold for each group
tempA = find(D(:,1)== project.subjects.group_no(group,1) &  D(:,2) == 1);
tempB = find(D(:,1)== project.subjects.group_no(group,2) &  D(:,2) == 1);
%
ScoreA = gmmScores(tempA);
ScoreB = gmmScores(tempB);

% % zscore transform
% ScoreA = [ScoreA;fA];
% ScoreB = [ScoreB;fB];
% ScoreA = zscore(ScoreA(~isnan(ScoreA)));
% ScoreB = zscore(ScoreB(~isnan(ScoreB)));

% compute the upper and lower of the pretest distribution
UP_B = nanmean(ScoreB)+project.convergence.fakestd*nanstd(ScoreB);
LW_B = nanmean(ScoreB)-project.convergence.fakestd*nanstd(ScoreB);

UP_A = nanmean(ScoreA)+project.convergence.fakestd*nanstd(ScoreA);
LW_A = nanmean(ScoreA)-project.convergence.fakestd*nanstd(ScoreA);


% kstest(ScoreA)
% adtest(ScoreB)
% lillietest(ScoreB)
% [f,x_values] = ecdf(ScoreB);
% F = plot(x_values,f);
% set(F,'LineWidth',2);
% hold on;
% G = plot(x_values,normcdf(x_values,0,1),'r--');
% set(G,'LineWidth',2);
% legend([F G],'Empirical CDF','Standard Normal CDF','Location','SE');
% hold off;
% aa=normcdf(x_values,0,1);
% [p,h,stat] = ranksum(ScoreA,mean_win_A,'tail','left')

project.convergence.subA_conv_threshold = LW_A;
project.convergence.subB_conv_threshold = UP_B;
project.convergence.subA_div_threshold = UP_A;
project.convergence.subB_div_threshold = LW_B;
%% condition 1 (if they are in definde boundary)
for i=1:length(fA)
    mean_win_A = fA(i);
    mean_win_B = fB(i);
    
    if(mean_win_A <= project.convergence.subA_conv_threshold && mean_win_B >= project.convergence.subB_conv_threshold)
        convergence_score(i) = 1;
    elseif(mean_win_A >= project.convergence.subA_div_threshold && mean_win_B <= project.convergence.subB_div_threshold)
        divergence(i) = 1;
    elseif(mean_win_A <= project.convergence.subA_conv_threshold && mean_win_B > project.convergence.subB_div_threshold && mean_win_B < project.convergence.subB_conv_threshold)
        convergence_A(i) = 1;
        %     elseif(mean_win_A <= project.convergence.subB_conv_threshold && mean_win_B <= project.convergence.subB_conv_threshold)
        %         convergence_A(i) = 1;
    elseif(mean_win_A > project.convergence.subA_conv_threshold && mean_win_A < project.convergence.subA_div_threshold && mean_win_B >= project.convergence.subB_conv_threshold)
        convergence_B(i) = 1;
        %     elseif(mean_win_A >= project.convergence.subA_conv_threshold && mean_win_B >= project.convergence.subA_conv_threshold)
        %         convergence_B(i) = 1;
    end
end

%% condition 2 (if they are not noise but actual phenomenon)
% fake_data(isnan(fake_data))=0;
if(session == 1 || session == 3)
    usable_fake_data = fake_data(:,1:99);
else
    usable_fake_data = fake_data(:,100:end);
end

for i=1:length(fA)
    diff_score = abs(fA(i) - fB(i));
    
    event_fake_dist = usable_fake_data(:,i);
    
%     % z transform
%     event_fake_dist = [event_fake_dist;diff_score];
%     event_fake_dist = zscore(event_fake_dist(~isnan(event_fake_dist)));
    
    UP = nanmean(event_fake_dist)+project.convergence.fakestd*nanstd(event_fake_dist);
    LW = nanmean(event_fake_dist)-project.convergence.fakestd*nanstd(event_fake_dist);
    
    if(diff_score <= LW || diff_score >= UP)
%     if(diff_score <= LW)        
        rare_event(i) = 1;
    end
end

%% use both condition
if(use_both_cond)
    convergence_score = convergence_score.*rare_event;
    divergence = divergence.*rare_event;
    convergence_A = convergence_A.*rare_event;
    convergence_B = convergence_B.*rare_event;
end

end