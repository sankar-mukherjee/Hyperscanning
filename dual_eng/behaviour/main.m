
load([project.paths.processedData '/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');
gmmScores = sum(gmmScores,2);

load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\surrogate_trial.mat','index_comb');
load([project.paths.processedData '/processed_data_word_level.mat'],'D');
load([project.paths.processedData '/convergence/convergence_' num2str(project.gmmUBM.gmmcomp) '_10_mwv_mfc.mat']);

%%
Feat = [];
i=41;
for sub=1:16
    Feat{sub,1} = [gmmScores(i:i+199) D(i:i+199,[4 5 6 10 14])];
    i = i + 199+81;
end

corealtion = [];
corealtion_std = [];
for sub=1:16
    temp = Feat{sub};
    [a,b] = corr(temp(:,2),temp(:,1));
    [c,d] = corr(temp(:,3),temp(:,1));
    [e,f] = corr(temp(:,4),temp(:,1));
    [g,h] = corr(temp(:,5),temp(:,1));
    [i,j] = corr(temp(:,6),temp(:,1));
    
    corealtion = [corealtion;   a c e g j];
    corealtion_std = [corealtion_std;   b d f h i];
end

i=find(corealtion_std<0.05);
j=find(corealtion>=0.5);
a = intersect(i,j);

A = zeros(16,5);
A(a) = 1;

i=find(corealtion_std<0.05);
j=find(corealtion<=-0.5);
a = intersect(i,j);

B = zeros(16,5);
B(a) = 1;





%%
feature_idx = [4 5 6 10 14];        % 'f0';'f1';'f2';'intensity';'reaction Time'

f0 = [D(index_comb(:,1),4) D(index_comb(:,2),4)];
f1 = [D(index_comb(:,1),5) D(index_comb(:,2),5)];
f2 = [D(index_comb(:,1),6) D(index_comb(:,2),6)];
intensity = [D(index_comb(:,1),10) D(index_comb(:,2),10)];

LLR = [gmmScores(index_comb(:,1)) gmmScores(index_comb(:,2))];


D_LLR = LLR(:,1) - LLR(:,2);
D_f0 = intensity(:,1) - intensity(:,2);


scatter(D_LLR,D_f0)

corealtion = [];
for sub=1:2:16
    i = index_comb(find(index_comb(:,5)==sub),:);
    for s=1:4
        A = index_comb(find(i(:,4)==s),:);
        
        %
        j = [A(find(A(:,3)==1),:); A(find(A(:,3)==2),:)];
        
        temp = [corr(D(j(:,1),4), D(j(:,2),4))
            corr(D(j(:,1),5), D(j(:,2),5))
            corr(D(j(:,1),6), D(j(:,2),6))
            corr(D(j(:,1),10), D(j(:,2),10))];
        LLR = mean([gmmScores(A(:,1)) - gmmScores(A(:,2))]);
        
        corealtion = [corealtion;  LLR temp'];
        
        
    end
end

scatter(corealtion(:,1),corealtion(:,2))
[h,p] = ttest2(corealtion(:,1),corealtion(:,3))

corealtion_sub = [];
for sub=1:2:16
    j = index_comb(find(index_comb(:,5)==sub),:);
    
    temp = [corr(D(j(:,1),4), D(j(:,2),4))
        corr(D(j(:,1),5), D(j(:,2),5))
        corr(D(j(:,1),6), D(j(:,2),6))
        corr(D(j(:,1),10), D(j(:,2),10))];
    LLR = mean([gmmScores(j(:,1)) - gmmScores(j(:,2))]);
    
    corealtion_sub = [corealtion_sub;  LLR temp'];
    
end
scatter(corealtion_sub(:,1),corealtion_sub(:,3))


[h,p] = ttest2(corealtion_sub(:,1),corealtion_sub(:,3))


% plot

A = reshape(corealtion(:,1),4,8);
B = reshape(corealtion(:,2),4,8);
C = reshape(corealtion(:,3),4,8);
D = reshape(corealtion(:,4),4,8);
E = reshape(corealtion(:,5),4,8);

a = mean(A')
b = std(A')
e = errorbar(a,b)
e.Marker = 's';
e.MarkerSize = 4;
e.MarkerFaceColor= 'k'
e.Color = 'k';
xlabel(gca,'Session No')
ylabel(gca,'LLR Score Difference')
set(gca,'XTick',[1:4])
title('Session average LLR score difference of all pairs')




a = mean(B')
b = std(B')
e = errorbar(a,b)
e.Marker = 's';
e.MarkerSize = 4;
e.MarkerFaceColor= 'k'
e.Color = 'k';
xlabel(gca,'Session No')
set(gca,'XTick',[1:4])
title('Session average F0 of all pairs')

hold on

a = mean(C')
b = std(C')
e = errorbar(a,b)
e.Marker = 'o';
e.MarkerSize = 4;
e.Color = 'k';
e.LineStyle = '--'

a = mean(D')
b = std(D')
e = errorbar(a,b)
e.Marker = 's';
e.MarkerSize = 4;
e.MarkerFaceColor= 'k'
e.Color = 'k';
e.LineStyle = ':'

a = mean(E')
b = std(E')
e = errorbar(a,b)
e.Marker = '^';
e.MarkerSize = 4;
e.MarkerFaceColor= 'k'
e.Color = 'k';
e.LineStyle = '-.'

ylabel(gca,'Session average features')
legend(gca,{'F0','F1','F2','Intensity'})




ylabel(gca,'F1')
title('Subject average F1')



ylabel(gca,'F2')
title('Subject average F2')


ylabel(gca,'Intensity')
title('Subject average Intensity')



x = corealtion(:,1);y=corealtion(:,2);
scatter(x,y,'MarkerEdgeColor',[0 .5 .5],...
    'MarkerFaceColor',[0 .7 .7],...
    'LineWidth',1.5)
xlabel(gca,'LLR Score Difference')
ylabel(gca,'Corealtion Coefficient')
title('F0 ')


x = corealtion(:,1);y=corealtion(:,3);
scatter(x,y,'MarkerEdgeColor',[0 .5 .5],...
    'MarkerFaceColor',[0 .7 .7],...
    'LineWidth',1.5)
xlabel(gca,'LLR Score Difference')
ylabel(gca,'Corealtion Coefficient')
title('F1')


x = corealtion(:,1);y=corealtion(:,4);
scatter(x,y,'MarkerEdgeColor',[0 .5 .5],...
    'MarkerFaceColor',[0 .7 .7],...
    'LineWidth',1.5)
xlabel(gca,'LLR Score Difference')
ylabel(gca,'Corealtion Coefficient')
title('F2')

x = corealtion(:,1);y=corealtion(:,5);
scatter(x,y,'MarkerEdgeColor',[0 .5 .5],...
    'MarkerFaceColor',[0 .7 .7],...
    'LineWidth',1.5)
xlabel(gca,'LLR Score Difference')
ylabel(gca,'Corealtion Coefficient')
title('Intensity')
%%
h = figure;l=1;P=0.5;
corealtion = [];corealtion_std = [];
for sub=1:2:16
    i = index_comb(find(index_comb(:,5)==sub),:);
    TEMP =[];

    for s=1:4
        A = index_comb(find(i(:,4)==s),:);
        
        j=A;
        for m=1:length(A)
            if(A(m,3)==2)
                j(m,:) = [j(m,2) j(m,1) j(m,3:end)];
            end
        end
        a = D(j(:,1),4)-D(j(:,2),4);
        b = D(j(:,1),5)-D(j(:,2),5);
        c = D(j(:,1),6)-D(j(:,2),6);
        d = D(j(:,1),10)-D(j(:,2),10);
        e = D(j(:,1),14)-D(j(:,2),14);

        temp = [ a b c d  gmmScores(A(:,1)) - gmmScores(A(:,2)) e];
        %         LLR = mean([gmmScores(A(:,1)) - gmmScores(A(:,2))]);
        
        [a,b] = corr(temp(:,1),temp(:,5));
        [c,d] = corr(temp(:,2),temp(:,5));
        [e,f] = corr(temp(:,3),temp(:,5));
        [g,h] = corr(temp(:,4),temp(:,5));
                [gg,hh] = corr(temp(:,6),temp(:,5));

        corealtion = [corealtion;   a c e g gg ];
        corealtion_std = [corealtion_std;   b d f h hh];

%         TEMP{s} = temp;
        
    end
%     TEMP = cell2mat(TEMP');
%     [a,b] = corr(TEMP(:,1),TEMP(:,5));
%     [c,d] = corr(TEMP(:,2),TEMP(:,5));
%     [e,f] = corr(TEMP(:,3),TEMP(:,5));
%     [g,h] = corr(TEMP(:,4),TEMP(:,5));
%     corealtion = [   b d f h a b c d];
% % corealtion = [corealtion;   a c e g];
% %         corealtion_std = [corealtion_std;   b d f h];
%     for k=1:4
%         subplot(8,4,l)
%         
%         if(corealtion(k)<=P)
%             scatter(TEMP(:,5),TEMP(:,k),1,[0 0 0]);
% 
%         else
%             scatter(TEMP(:,5),TEMP(:,k),1,[0.5 0.5 0.5]);
% 
%         end
%         l=l+1;
%     end
end

A = reshape(corealtion(:,1),4,8);
B = reshape(corealtion(:,2),4,8);
C = reshape(corealtion(:,3),4,8);
D = reshape(corealtion(:,4),4,8);
E = reshape(corealtion(:,5),4,8);

kkk={'s','o','*','>','<','p','v','d'};
kk={'-','-','-','--','--','--','-','--'};

figure;
for i=1:8
   plot(1:4,A(:,i),'LineStyle',kk{i},'Marker',kkk{i},'Color',[0 0 0],'MarkerFaceColor','k');
   hold on;
end
set(gca,'xlim',[0.5 4.5])

ylabel(gca,'Corealtion Coefficient')
xlabel(gca,'Session No')
set(gca,'XTick',[1:4])
title(['Coreation between word-pair' char(10) 'F0 difference and LLR score difference'])
legend(project.subjects.group)
set(gca,'FontSize',8);


figure;
for i=1:8
   plot(1:4,B(:,i),'LineStyle',kk{i},'Marker',kkk{i},'Color',[0 0 0],'MarkerFaceColor','k');
   hold on;
end
set(gca,'xlim',[0.7 4.9])
ylabel(gca,'Corealtion Coefficient')
xlabel(gca,'Session No')
set(gca,'XTick',[1:4])
title(['Coreation between word-pair' char(10) 'F1 difference and LLR score difference'])
legend(project.subjects.group)
set(gca,'FontSize',8);


figure;
for i=1:8
   plot(1:4,C(:,i),'LineStyle',kk{i},'Marker',kkk{i},'Color',[0 0 0],'MarkerFaceColor','k');
   hold on;
end
set(gca,'xlim',[0.7 4.9])
ylabel(gca,'Corealtion Coefficient')
xlabel(gca,'Session No')
set(gca,'XTick',[1:4])
title(['Coreation between word-pair' char(10) 'F2 difference and LLR score difference'])
legend(project.subjects.group)
set(gca,'FontSize',8);



figure;
for i=1:8
   plot(1:4,D(:,i),'LineStyle',kk{i},'Marker',kkk{i},'Color',[0 0 0],'MarkerFaceColor','k');
   hold on;
end
set(gca,'xlim',[0.7 4.2])
ylabel(gca,'Corealtion Coefficient')
xlabel(gca,'Session No')
set(gca,'XTick',[1:4])
title(['Coreation between word-pair' char(10) 'Intensity difference and LLR score difference'])
legend(project.subjects.group)
set(gca,'FontSize',8);


figure;
for i=1:8
   plot(1:4,E(:,i),'LineStyle',kk{i},'Marker',kkk{i},'Color',[0 0 0],'MarkerFaceColor','k');
   hold on;
end
set(gca,'xlim',[0.7 4.2])
ylabel(gca,'Corealtion Coefficient')
xlabel(gca,'Session No')
set(gca,'XTick',[1:4])
title(['Coreation between word-pair' char(10) 'RT difference and LLR score difference'])
legend(project.subjects.group)
set(gca,'FontSize',8);






a = [A' B' C' D'];

a = mean(A)
b = std(A)
e = errorbar(a,b)
e.Marker = 's';
e.MarkerSize = 4;
e.MarkerFaceColor= 'k'
e.Color = 'k';
xlabel(gca,'Session No')
ylabel(gca,'Corelation coefficient')
set(gca,'XTick',[1:4])
title(['Subject average of Corelation coefficient between' char(10) 'F0 and LLR score difference'])

a = mean(B)
b = std(B)
e = errorbar(a,b)
e.Marker = 's';
e.MarkerSize = 4;
e.MarkerFaceColor= 'k'
e.Color = 'k';
xlabel(gca,'Session No')
ylabel(gca,'Corelation coefficient')
set(gca,'XTick',[1:4])
set(gca,'ylim',[-0.06 0.15])

title(['Subject average of Corelation coefficient between' char(10) 'F1 and LLR score difference'])



a = mean(C)
b = std(C)
e = errorbar(a,b)
e.Marker = 's';
e.MarkerSize = 4;
e.MarkerFaceColor= 'k'
e.Color = 'k';
xlabel(gca,'Session No')
ylabel(gca,'Corelation coefficient')
set(gca,'XTick',[1:4])
title(['Subject average of Corelation coefficient between' char(10) 'F2 and LLR score difference'])







a = mean(D)
b = std(D)
e = errorbar(a,b)
e.Marker = 's';
e.MarkerSize = 4;
e.MarkerFaceColor= 'k'
e.Color = 'k';
xlabel(gca,'Session No')
ylabel(gca,'Corelation coefficient')
set(gca,'XTick',[1:4])
title(['Subject average of Corelation coefficient between' char(10) 'intensity and LLR score difference'])



























%%
load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\coherence_analysis\idx.mat');







%% plot whole experiment
load([project.paths.processedData '/convergence/GMM_speech_conv_spy_32_10_mwv_mfc.mat'],'GMM_conv');
% convergence
a = GMM_conv.convergence .* GMM_conv.rare_event;

% a = [a;zeros(1,396)];

FigHandle1 = figure('Position', [100, 100, 800, 700]);
pcolor(a);
imagesc(flipud(a))
hold on;
plot( [99 99],get(gca,'ylim'),'k','LineWidth',1)
plot( [198 198],get(gca,'ylim'),'k','LineWidth',1)
plot( [297 297],get(gca,'ylim'),'k','LineWidth',1)
set(get(gca,'YLabel'),'String','Groups');
set(get(gca,'XLabel'),'String','Duet (Word Pairs)')
% set(gca,'YTick',[1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5]);
set(gca,'YTickLabel',[fliplr(project.subjects.group)]);
set(gca,'XTick',[1 50 100 150 200 250 300 350 396]);
set(gca,'XTickLabel',{'0','Session 1','100','Session 2','200','Session 3','300','Session 4','396'});

h1 = area(NaN,NaN,'Facecolor','k');
h2 = area(NaN,NaN,'Facecolor','r');
h3 = area(NaN,NaN,'Facecolor','g');
h4 = area(NaN,NaN,'Facecolor','w');
h5 = area(NaN,NaN,'Facecolor','w');

% hL = legend([h1 h2 h3 h4 h5],{'Convergence','convergence A', 'convergence B', 'NoChange'},'Orientation','horizontal','FontSize',12);
        hL = legend([h1 h4],{'Convergence', 'No change'},'Orientation','horizontal','FontSize',9);
set(hL,'Position', [0.5 0.025 0.005 0.0009]);
title('Whole Duet Task');


%%
sub = 5;
session =2;
a = find(D(:,1) == sub & D(:,2) == session);
b = find(D(:,1) == sub+1 & D(:,2) == session);

LLR = [gmmScores(a) gmmScores(b)];

plot(LLR,'.-')





B=reshape(A,4,8);
sum(B)
%%




















