
load([project.paths.processedData '/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');
gmmScores = sum(gmmScores,2);

load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\surrogate_trial.mat','index_comb');
load([project.paths.processedData '/processed_data_word_level.mat'],'D');
load([project.paths.processedData '/convergence/convergence_' num2str(project.gmmUBM.gmmcomp) '_10_mwv_mfc.mat']);

%% all pull together check
Feat = [];
i=41;
for sub=1:16
    Feat{sub,1} = [gmmScores(i:i+199) D(i:i+199,[4 5 6 10 14]) convergence_score_diff(i:i+199,1) D(i:i+199,2)];
    i = i + 199+81;
end

corealtion = [];
corealtion_std = [];
for sub=1:16
    B = Feat{sub};
    for s = 2:5
        temp = B(find(B(:,8)==s),:);
        [a,b] = corr(temp(:,2),temp(:,1));
        [c,d] = corr(temp(:,3),temp(:,1));
        [e,f] = corr(temp(:,4),temp(:,1));
        [g,h] = corr(temp(:,5),temp(:,1));
        [i,j] = corr(temp(:,6),temp(:,1));
        
        [ccc,ddd] = corr(temp(:,2),temp(:,7));
        [eee,fff] = corr(temp(:,3),temp(:,7));
        [ggg,hhh] = corr(temp(:,4),temp(:,7));
        [aaa,bbb] = corr(temp(:,5),temp(:,7));
        [iii,jjj] = corr(temp(:,6),temp(:,7));
        
        corealtion = [corealtion;   a c e g i ccc eee ggg aaa iii ];
        corealtion_std = [corealtion_std;   b d f h j ddd fff hhh bbb jjj];
    end
end

%% subjectwise
figure;
for f=6:10
    A = reshape(corealtion(:,f),4,16);
    hold on;
    
    a = mean(A)
    b = std(A)
    e = errorbar(a,b)
    e.Marker = 's';
    e.LineWidth = 3;
    %         e.MarkerSize = 4;
    %         e.MarkerFaceColor= 'k'
    %         e.Color = 'k';
    xlabel(gca,'Subjects No')
    ylabel(gca,'Session average CC')
    set(gca,'XTick',[1:16])
%     title('F0 vs effort')
    set(gca,'xlim',[0 17])
end
title('correlation (F0 f1 f2 intensity RT) vs effort')
legend('F0','f1','f2','intensity','RT');


%% session
figure;
for f=6:10
    A = reshape(corealtion(:,f),4,16);
    hold on;
    
    a = mean(A')
    b = std(A')
    e = errorbar(a,b)
    e.Marker = 's';
    e.LineWidth = 2;
    %         e.MarkerSize = 4;
    %         e.MarkerFaceColor= 'k'
    %         e.Color = 'k';
    xlabel(gca,'session No')
    ylabel(gca,'subject average CC')
    set(gca,'XTick',[1:4])
%     title('F0 vs effort')
    set(gca,'xlim',[0 5])
end
title('correlation (F0 f1 f2 intensity RT) vs effort')
legend('F0','f1','f2','intensity','RT');


%% subjectwise seperate
AA = {'F0 vs effort','f1 vs effort','f2 vs effort','intensity vs effort','RT vs effort'};
for f=6:10
figure;

    A = reshape(corealtion(:,f),4,16);
    hold on;
    
    a = mean(A)
    b = std(A)
    e = errorbar(a,b)
    e.Marker = 's';
%     e.LineWidth = 3;
            e.MarkerSize = 4;
            e.MarkerFaceColor= 'k'
            e.Color = 'k';
    xlabel(gca,'Subjects No')
    ylabel(gca,'Session average CC')
    set(gca,'XTick',[1:16])
    title(AA{f-5})
    set(gca,'xlim',[0 17])
end

%%





load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\convergence\GMM_speech_conv_spy_32_10_mwv_mfc.mat')


% convergence
a = GMM_conv.convergence .* GMM_conv.rare_event;


FigHandle1 = figure('Position', [100, 100, 800, 700]);
pcolor(a);
imagesc(flipud(a))
hold on;
plot( [99 99],get(gca,'ylim'),'w','LineWidth',1)
plot( [198 198],get(gca,'ylim'),'w','LineWidth',1)
plot( [297 297],get(gca,'ylim'),'w','LineWidth',1)
set(get(gca,'YLabel'),'String','Groups');
set(get(gca,'XLabel'),'String','Duet (Word Pairs)')
set(gca,'YTickLabel',fliplr(project.subjects.gender_comb));
set(gca,'XTick',[1 50 100 150 200 250 300 350 396]);
set(gca,'XTickLabel',{'0','Session 1','100','Session 2','200','Session 3','300','Session 4','396'},'FontSize',30);
h2 = area(NaN,NaN,'Facecolor','w');
h3 = area(NaN,NaN,'Facecolor','k');
hL = legend([h2 h3],{'Convergence', 'No change'},'Orientation','horizontal','FontSize',25);
set(hL,'Position', [0.5 0.025 0.005 0.0009]);
title('Whole Duet Task');



%%
load('C:\Users\SMukherjee\Desktop\data\dual_eng\mat\convergence\GMM_speech_conv_spy_32_10_mwv_mfc.mat')
% convergence
a = GMM_conv.convergence .* GMM_conv.rare_event;

A = [];

for s=1:8
j=1;

    for i=1:4
        A = [A; length(find(a(s,j:j+98)))];
        j=j+98;
    end
end





AA = {'F0 vs No of Convergence','f1 vs LLR diff','f2 vs LLR diff','intensity vs LLR diff','RT vs LLR diff'};

R = [];
for i=1:6
%         figure;
%     
%         scatter(A(:,1),corealtion(:,i),kkk{2},'filled')
%         %     hold on;
%         xlabel(gca,'LLR DIff')
%         ylabel(gca,'Session average CC')
%         title(AA{i})
    
    [r,p] = corr(A(:,1),corealtion(:,i));
    R = [R; r p];
end


% i=find(corealtion_std<0.05);
% B = zeros(32,6);
% B(i) = corealtion(i);

R = [];
for i=1:7
    [r,p] = corr(A(:,1),corealtion(:,i),'rows','complete');
    R = [R; r p];
end



figure;

scatter(A(:,1),corealtion(:,2),'filled')
xlabel(gca,'No of Convergence')
ylabel(gca,'CC')
set(gca,'xlim',[-3 20])
set(gca,'ylim',[-0.7 0.7])

title('F0 vs No of Convergence')


figure;

scatter(A(:,1),corealtion(:,5),'filled')
xlabel(gca,'No of Convergence')
ylabel(gca,'CC')
set(gca,'xlim',[-3 20])
set(gca,'ylim',[-0.4 0.7])
title('Intensity vs No of Convergence')






















