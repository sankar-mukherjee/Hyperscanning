
load([project.paths.processedData '/original_fake_convergence.mat']);
gmm = load([project.paths.processedData '/GMM_scores.mat']);
load([project.paths.processedData '/processed_data_word_level.mat']);

% project.paths.figures = 'C:/Users/SMukherjee/Desktop/data/figures/convergence';

%% merge into only event distribution
ALL=[];
for g=1:length(project.subjects.group)
    
     % fake
    fake_event_dist_diff = fake_conversaion{g,1};
    temp =[];
    for i=1:size(fake_event_dist_diff,1)
        temp = [temp; fake_event_dist_diff(i,1:2);fake_event_dist_diff(i,3:4)];
    end
    fake_event_dist_diff = cell2mat(temp);
    
    
    % original    
    temp = orginal_conversation(g,:);
    orginal_event_dist_diff = cell(1,4);
    for i=1:length(orginal_event_dist_diff)
        orginal_event_dist_diff{i} = abs(temp{1,i}(:,1) - temp{1,i}(:,2))';
    end
    
    
    orginal_event_dist = orginal_conversation(g,:);
    
    for session= 1:4
        session_data = orginal_event_dist{session};
        [convergence_score,divergence,convergence_A,convergence_B,rare_event] = convergence_condition2(session_data(:,1),session_data(:,2),fake_event_dist_diff,D,gmm.gmmScores(:,g),...
            session,project,g,project.convergence.use_both_cond);
        ALL{g,session,1} = convergence_score';
        ALL{g,session,2} = divergence';
        ALL{g,session,3} = convergence_A';
        ALL{g,session,4} = convergence_B';
        ALL{g,session,5} = rare_event';
    end
end
GMM_conv.convergence = cell2mat(ALL(:,:,1));
GMM_conv.divergence = cell2mat(ALL(:,:,2));
GMM_conv.convergence_A = cell2mat(ALL(:,:,3));
GMM_conv.convergence_B = cell2mat(ALL(:,:,4));
GMM_conv.rare_event = cell2mat(ALL(:,:,5));
save([project.paths.processedData '/GMM_speech_conv_spy.mat'],'GMM_conv');

%%
% show=1;
% b = [51 102 153 204];
% a=0;
% for i=1:4
% a = a+(cell2mat(ALL(:,:,i))*b(i));
% end
% % a= cell2mat(ALL(:,:,show));

% ALL
a = GMM_conv.convergence + 2*GMM_conv.convergence_A + 3*GMM_conv.convergence_B + 4*GMM_conv.divergence;
a = a .* GMM_conv.rare_event;

% convergence
a = GMM_conv.convergence .* GMM_conv.rare_event;

a = [a;zeros(1,396)];

FigHandle1 = figure('Position', [100, 100, 800, 700]);
pcolor(a);
hold on;
plot( [99 99],get(gca,'ylim'),'w','LineWidth',1)
plot( [198 198],get(gca,'ylim'),'w','LineWidth',1)
plot( [297 297],get(gca,'ylim'),'w','LineWidth',1)
set(get(gca,'YLabel'),'String','Groups');
set(get(gca,'XLabel'),'String','Sessions')
set(gca,'YTick',[1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5]);
set(gca,'YTickLabel',[project.subjects.group]);
set(gca,'XTick',[50 150 250 350]);
set(gca,'XTickLabel',[1:4]);

h1 = area(NaN,NaN,'Facecolor','k');
h2 = area(NaN,NaN,'Facecolor','g');
h3 = area(NaN,NaN,'Facecolor','b');
h4 = area(NaN,NaN,'Facecolor','r');
h5 = area(NaN,NaN,'Facecolor','w');

hL = legend([h2 h1 h3 h4 h5],{'Convergence','divergence','convergence_A', 'convergence_B', 'No change'},'Orientation','horizontal','FontSize',9);
hL = legend([h2 h3],{'Convergence', 'No change'},'Orientation','horizontal','FontSize',9);
set(hL,'Position', [0.5 0.025 0.005 0.0009]);

saveas(FigHandle1,[project.paths.figures '/convergence_points.fig']);
saveas(FigHandle1,[project.paths.figures '/convergence_points.tif']);

%% an example pair
group = 8;session=3;diff_flag=0;
plot_session_convergence(D,orginal_conversation,gmm.gmmScores(:,group),ALL,group,session,project,diff_flag);


%%

[event event_idx event_common_idx] = get_event_wordPair();

temp =[];
for i=1:size(ALL,1)
    temp = [temp; ALL(i,1:2);ALL(i,3:4)];
end

a = cell2mat(temp);
b = sum(a);
idx = find(b > 0);
words = event(idx,:);

%%
convergence_data = convert2originalDataStruct(ALL,D,project);

%% get gmm score diff
convergence_score_diff = zeros(size(D,1),1);
gmmScores = sum(gmm.gmmScores,2);
for sub=1:length(project.subjects.list)
    temp = find(D(:,1)== sub &  D(:,2) == 1);
    Score = gmmScores(temp);
    % compute the upper and lower of the pretest distribution
    UP = nanmean(Score)+project.convergence.fakestd*nanstd(Score);
    LW = nanmean(Score)-project.convergence.fakestd*nanstd(Score);
    %
    for session= 2:5
        idx = find(D(:,1)== sub &  D(:,2) == session);
        session_data = gmmScores(idx);
        if (mod(sub,2))
            convergence_score_diff(idx) = LW - session_data;
        else
            convergence_score_diff(idx) = session_data - UP;
        end
    end
end

save([project.paths.processedData '/convergence.mat'],'convergence_data', 'convergence_score_diff');
