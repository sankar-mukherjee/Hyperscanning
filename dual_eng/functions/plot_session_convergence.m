function f = plot_session_convergence(D,orginal_conversation,gmmScores,ALL,group,session,project,diff_flag)
%%
a = orginal_conversation{group, session};
tempA = find(D(:,1)== project.subjects.group_no(group,1) &  D(:,2) == 1);
tempB = find(D(:,1)== project.subjects.group_no(group,2) &  D(:,2) == 1);
ScoreA = gmmScores(tempA);
ScoreB = gmmScores(tempB);
% compute the upper and lower of the pretest distribution
UP_B = nanmean(ScoreB)+project.convergence.fakestd*nanstd(ScoreB);
LW_B = nanmean(ScoreB)-project.convergence.fakestd*nanstd(ScoreB);
UP_A = nanmean(ScoreA)+project.convergence.fakestd*nanstd(ScoreA);
LW_A = nanmean(ScoreA)-project.convergence.fakestd*nanstd(ScoreA);
project.convergence.subA_conv_threshold = LW_A;
project.convergence.subB_conv_threshold = UP_B;
project.convergence.subA_div_threshold = UP_A;
project.convergence.subB_div_threshold = LW_B;

diff_a = abs(a(:,1)- a(:,2));

FigHandle1 = figure('Position', [100, 100, 800, 700]);
if(diff_flag)
    plot(diff_a,'.-k');hold on;
    legend('abs(A-B)');
    set(get(gca,'YLabel'),'String','LLR Score difference');
else
    plot(a(:,1),'.-b','MarkerSize',10);hold on;
    plot(a(:,2),'.-r','MarkerSize',10);
    
    legend('A','B');
    set(get(gca,'YLabel'),'String','LLR Score');
    plot(get(gca,'xlim'), [project.convergence.subA_conv_threshold project.convergence.subA_conv_threshold],':b');
    plot(get(gca,'xlim'), [project.convergence.subB_conv_threshold project.convergence.subB_conv_threshold],':r');
    plot(get(gca,'xlim'), [project.convergence.subA_div_threshold project.convergence.subA_div_threshold],':b');
    plot(get(gca,'xlim'), [project.convergence.subB_div_threshold project.convergence.subB_div_threshold],':r');
    plot(get(gca,'xlim'), [0 0],'k');
    set(gca,'ylim',[-5 5]);
    set(gca,'xlim',[0 99]);

end

set(get(gca,'XLabel'),'String','Word Pairs')


% shade areas
rare = cell2mat(ALL(group,session,5));

convergence_score = cell2mat(ALL(group,session,1)) .* rare;
divergence = cell2mat(ALL(group,session,2)).* rare;
convergence_A = cell2mat(ALL(group,session,3)).* rare;
convergence_B = cell2mat(ALL(group,session,4)).* rare;

yLimits = get(gca,'YLim');
mar = 0.5;
for s=1:length(convergence_score)
    if(convergence_score(s))
        h1 = area([s-mar s+mar],[yLimits(1) yLimits(1)]);
        h2 = area([s-mar s+mar],[yLimits(2) yLimits(2)]);
        set(h1,'Facecolor','b')
        set(h2,'Facecolor','b')
        alpha(0.15);
    end
    if(divergence(s))
        h1 = area([s-mar s+mar],[yLimits(1) yLimits(1)]);
        h2 = area([s-mar s+mar],[yLimits(2) yLimits(2)]);
        set(h1,'Facecolor','r')
        set(h2,'Facecolor','r')
        alpha(0.15);
    end
    if(convergence_A(s))
        h1 = area([s-mar s+mar],[yLimits(1) yLimits(1)]);
        h2 = area([s-mar s+mar],[yLimits(2) yLimits(2)]);
        set(h1,'Facecolor','r')
        set(h2,'Facecolor','r')
        alpha(0.15);
    end
    if(convergence_B(s))
        h1 = area([s-mar s+mar],[yLimits(1) yLimits(1)]);
        h2 = area([s-mar s+mar],[yLimits(2) yLimits(2)]);
        set(h1,'Facecolor','g')
        set(h2,'Facecolor','g')
        alpha(0.15);
    end
end

title(['Group ' project.subjects.group{group} ' Session ' num2str(session)]);
h1 = area(NaN,NaN,'Facecolor','b');
h2 = area(NaN,NaN,'Facecolor','r');
h3 = area(NaN,NaN,'Facecolor','g');
h4 = area(NaN,NaN,'Facecolor','w');
        alpha(0.15);

h5 = plot(NaN,NaN,'.-b','MarkerSize',10);
h6 = plot(NaN,NaN,'.-r','MarkerSize',10);

hL = legend([h1 h2 h3 h4 h5 h6],{'Convergence','Convergence A', 'Convergence B','NoChange','Speaker A','Speaker B'},'Orientation','vertical','FontSize',10);
set(hL,'Position', [0.5 0.025 0.005 0.0009]);

saveas(FigHandle1,[project.paths.figures '\session_conv_' [project.subjects.group{group} '_Session_' num2str(session)] '.fig']);
saveas(FigHandle1,[project.paths.figures '\session_conv_' [project.subjects.group{group} '_Session_' num2str(session)] '.tif']);

end