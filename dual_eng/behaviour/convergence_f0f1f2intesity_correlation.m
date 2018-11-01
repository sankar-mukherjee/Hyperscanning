load([project.paths.processedData '/GMM_configs/GMM_scores_32_10_mwv_mfc.mat'],'gmmScores');
gmmScores = sum(gmmScores,2);

load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\surrogate_trial.mat','index_comb');
load([project.paths.processedData '/processed_data_word_level.mat'],'D');
load([project.paths.processedData '/convergence/convergence_' num2str(project.gmmUBM.gmmcomp) '_new_versioncode.mat'],'convergence_data','TH');
load('C:\Users\SMukherjee\Desktop\behaviourPlatform\MNI\sankar\spic\dual_eng\SPIC_text.mat', 'Oindex_comb');

index_comb=Oindex_comb;
load([project.paths.processedData '/processed_data_word_level.mat'],'W');
word_comb = [W(index_comb(:,1),1) W(index_comb(:,2),1)];
b = find(cellfun('isempty',word_comb(:,1)));
word_comb(b,:)=[];index_comb(b,:)=[];convergence_data(b,:)=[];
b = find(cellfun('isempty',word_comb(:,2)));
word_comb(b,:)=[];index_comb(b,:) = [];convergence_data(b,:)=[];
Oindex_comb=index_comb;


%% all pull together check
A = unique([Oindex_comb(:,1) convergence_data(:,11)],'rows'); 
B = unique([Oindex_comb(:,2) convergence_data(:,12)],'rows');
effort = sortrows([A;B],1);
Feat = [effort D(effort(:,1),[1 2 4 5 6 10 14])];
a = find(Feat(:,3)==0);
Feat(a,:) = [];

corealtion = [];
corealtion_std = [];
for sub=1:16
    for s = 2:5
        A = find(Feat(:,3)==sub & Feat(:,4)==s);
        temp = Feat(A,:);
        [a,b] = corr(temp(:,5),temp(:,2));
        [c,d] = corr(temp(:,6),temp(:,2));
        [e,f] = corr(temp(:,7),temp(:,2));
        [g,h] = corr(temp(:,8),temp(:,2));
        [i,j] = corr(temp(:,9),temp(:,2));
        
        corealtion = [corealtion;   a c e g j];
        corealtion_std = [corealtion_std;   b d f h i];
    end
end

%% subjectwise
figure;
for f=1:5
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
for f=1:5
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


%% joint task 
%%CC vs LLRDiff   all together

corealtion = [];corealtion_std=[];
for sub=1:2:16
    i = Oindex_comb(find(Oindex_comb(:,5)==sub),:);
    for s=1:4
        A = i(find(i(:,4)==s),:);        
        %
        j = [A(find(A(:,3)==1),:); A(find(A(:,3)==2),:)];
        
        [a,b] = corr(D(j(:,1),4), D(j(:,2),4));
        [c,d] = corr(D(j(:,1),5), D(j(:,2),5));
        [e,f] = corr(D(j(:,1),6), D(j(:,2),6));
        [g,h] = corr(D(j(:,1),10), D(j(:,2),10));
        [k,l] = corr(D(j(:,1),11), D(j(:,2),11));

        [ii,jj] = corr(D(j(:,1),14), D(j(:,2),14));
        
        LLR = mean([gmmScores(A(:,1)) - gmmScores(A(:,2))]);
        LLR1 = std([gmmScores(A(:,1)) - gmmScores(A(:,2))]);
        
        corealtion = [corealtion;   LLR a c e g k ii];
        corealtion_std = [corealtion_std; LLR1  b d f h l jj];       
        
    end
end
kkk={'s','o','p','>','d','v','*','<'};
AA = {'F0 vs LLR diff','f1 vs LLR diff','f2 vs LLR diff','intensity vs LLR diff','RT vs LLR diff'};

R = [];
for i=2:6
    %     figure;
    %
    %     scatter(corealtion(:,1),corealtion(:,i),kkk{2},'filled')
    %     %     hold on;
    %     xlabel(gca,'LLR DIff')
    %     ylabel(gca,'Session average CC')
    %     title(AA{i-1})
    
    [r,p] = corr(corealtion(:,1),corealtion(:,i));
    R = [R; r p];
end



%% subject wise

%%CC vs LLRDiff

corealtion = [];
for sub=1:2:16
    i = Oindex_comb(find(Oindex_comb(:,5)==sub),:);
    A = i;
    
    %
    j = [A(find(A(:,3)==1),:); A(find(A(:,3)==2),:)];
    
    temp = [corr(D(j(:,1),4), D(j(:,2),4))
        corr(D(j(:,1),5), D(j(:,2),5))
        corr(D(j(:,1),6), D(j(:,2),6))
        corr(D(j(:,1),10), D(j(:,2),10))
        corr(D(j(:,1),14), D(j(:,2),14))];
    LLR = mean([gmmScores(A(:,1)) - gmmScores(A(:,2))]);
    
    corealtion = [corealtion;  LLR temp'];
    
end
kkk={'s','o','p','>','d','v','*','<'};

for i=2:6
    figure;
    
    scatter(corealtion(:,1),corealtion(:,i),kkk{2},'filled')
    %     hold on;    
    xlabel(gca,'LLR DIff')
    ylabel(gca,'session average CC')
    [h,p] = ttest2(corealtion(:,1),corealtion(:,i))
end
title('CC F0 vs LLR diff')

%%









%%
figure;
for f=1:5
    A = reshape(corealtion(:,f),4,16);
    subplot(3,2,f)
    for i=1:16
%         plot(1:4,A(:,i),'LineStyle',kk{i},'Marker',kkk{i},'Color',[0 0 0],'MarkerFaceColor','k');
        plot(1:4,A(:,i));
        hold on;
    end
    title(num2str(f))
end




i=41;
for sub=1:16
    Feat{sub,1} = [gmmScores(i:i+199) D(i:i+199,[4 5 6 10 14])];
    i = i + 199+81;
end


i=find(corealtion_std<0.05);
j=find(corealtion>=0.5);
a = intersect(i,j);

A = zeros(32,6);
A(i) = 1;

i=find(corealtion_std<0.05);
j=find(corealtion<=-0.5);
a = intersect(i,j);

B = zeros(16,5);
B(a) = 1;





a = reshape(A(:,5),4,8);
bar(a','DisplayName','a')
































k=1;    corealtion = [];corealtion_std = [];

for sub=1:2:16
    i = Oindex_comb(find(Oindex_comb(:,5)==sub),:);
    for s=1:4
        T = convergence_data(k:k+98,:);
        
        A = i(find(i(:,4)==s),:);
        
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
        
        temp = [ a b c d  gmmScores(A(:,1)) - gmmScores(A(:,2)) T(:,[11 12])];
        %         LLR = mean([gmmScores(A(:,1)) - gmmScores(A(:,2))]);
        
        [a,b] = corr(temp(:,1),temp(:,5));
        [c,d] = corr(temp(:,2),temp(:,5));
        [e,f] = corr(temp(:,3),temp(:,5));
        [g,h] = corr(temp(:,4),temp(:,5));
        
        [aa,bb] = corr(temp(:,1),temp(:,6));
        [cc,dd] = corr(temp(:,2),temp(:,6));
        [ee,ff] = corr(temp(:,3),temp(:,6));
        [gg,hh] = corr(temp(:,4),temp(:,6));
        
        [aaa,bbb] = corr(temp(:,1),temp(:,7));
        [ccc,ddd] = corr(temp(:,2),temp(:,7));
        [eee,fff] = corr(temp(:,3),temp(:,7));
        [ggg,hhh] = corr(temp(:,4),temp(:,7));
        %
     
        corealtion = [corealtion;   a c e g aa cc ee gg aaa ccc eee ggg];
        corealtion_std = [corealtion_std;   b d f h bb dd ff hh bbb ddd fff hhh];
        
        
        k=k+99;
    end
    
    
end

figure;

for f=1:12
    A = reshape(corealtion(:,f),4,8);
    subplot(3,4,f)
    for i=1:8
%         plot(1:4,A(:,i),'LineStyle',kk{i},'Marker',kkk{i},'Color',[0 0 0],'MarkerFaceColor','k');
        plot(1:4,A(:,i));

        hold on;
    end
    title(num2str(f))
end


A = reshape(corealtion(:,1),4,8);
B = reshape(corealtion(:,2),4,8);
C = reshape(corealtion(:,3),4,8);
D = reshape(corealtion(:,4),4,8);

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


