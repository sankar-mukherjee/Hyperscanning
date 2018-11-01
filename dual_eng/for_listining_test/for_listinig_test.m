
load([project.paths.processedData '/convergence/convergence_32_10_mwv_mfc.mat']);
load([project.paths.processedData '/processed_data_word_level.mat'],'D','fileList_name','W');
load('common_words.mat');
[index,user,stimuli,rate] = import_spic_database('C:\Users\SMukherjee\Desktop\data\dual_eng\for_listing_test\spic_database.csv');
[index,id,sex,age,school,parent,spend,teach,ip] = import_user('C:\Users\SMukherjee\Desktop\data\dual_eng\for_listing_test\user.csv');

unique_user=unique(user,'stable');
b=cellfun(@(x) sum(ismember(user,x)),unique_user,'un',0);


unique_stimuli=unique(stimuli,'stable');
b=cellfun(@(x) sum(ismember(stimuli,x)),unique_stimuli,'un',0);

b=find(ismember(id,unique_user));
mean(age(b))
std(age(b))




Final_rate = zeros(64,length(unique_user));
Final_stimuli = cell(64,1);
for i=1:length(unique_stimuli)
    A = find(ismember(stimuli,unique_stimuli{i}));
    for j=1:length(unique_user)
        B = find(ismember(user,unique_user{j}));
        a = intersect(A,B);
        Final_rate(i,j) = rate(a);
    end
    temp = strsplit(unique_stimuli{i},'-');
    Final_stimuli{i,1} = [temp{3} '-' temp{4} '.wav'];
end


A = convergence_score_diff(:,1);
A = A/norm(A);

score = zeros(size(WORDS_all));
score = [score zeros(size(WORDS_all,1),3)];
index = zeros(size(Final_stimuli,1),3);
for i=1:size(Final_stimuli,1)
    a = find(strcmp(fileList_name, Final_stimuli{i,1}));
    [r,c] = find(WORDS_all==a);
    score(r,c) = mean(Final_rate(i,:));
    score(r,3) = A(WORDS_all(r,3));
    if(c==1)
        score(r,4) = std(Final_rate(i,:));
    else
        score(r,5) = std(Final_rate(i,:));
    end
    index(i,1) = c;    index(i,2) = r; index(i,3) = D(WORDS_all(r,3),1);
    score(r,6) = D(WORDS_all(r,3),1);
end

a=find(sum(score,2)==0);
score(a,:)=[];
subjects = WORDS_all(:,3);
subjects(a) = [];
subjects = D(subjects,1);

%% subject wise mean std in ratings
bar(1:size(Final_rate,2),mean(Final_rate,1));hold on
errorbar(1:size(Final_rate,2),mean(Final_rate,1),std(Final_rate,1),'.')

%% subject wise mean std in ratings separated in pre and post
a = find(index(:,1)==1);
A = Final_rate(a,:);

figure
subplot(2,1,1)
bar(1:size(A,2),mean(A,1));hold on
errorbar(1:size(A,2),mean(A,1),std(A,1),'.')
ylim([0 120]);

a = find(index(:,1)==2);
A = Final_rate(a,:);

subplot(2,1,2)
bar(1:size(A,2),mean(A,1));hold on
errorbar(1:size(A,2),mean(A,1),std(A,1),'.')
ylim([0 120]);


%% stimuli wise mean std in ratings separated in pre and post
figure
subplot(2,1,1)
bar(1:length(score),score(:,1));hold on
errorbar(1:length(score),score(:,1),score(:,4),'.')
ylim([0 120]);
subplot(2,1,2)
bar(1:length(score),score(:,2));hold on
errorbar(1:length(score),score(:,2),score(:,5),'.')
ylim([0 120]);

bar(score(:,1:2),'DisplayName','score(:,1:2)')
hold on
errorbar(1:length(score),score(:,1),score(:,4),'.')


%% pre post separate by high low convergence(effort) score
a = [];

C = score;
a = find(ismember(C(:,6),a));
C(a,:) = [];
th = mean(C(:,3))

a = find(C(:,3)<= th);
b = find(C(:,3)> th);

A = [mean(C(a,1)) mean(C(a,2)) mean(C(b,1)) mean(C(b,2))];
B = [std(C(a,1)) std(C(a,2)) std(C(b,1)) std(C(b,2))];
figure;
bar(1:length(A),A);hold on
errorbar(1:length(A),A,B,'.')
set(gca,'XTickLabel',{'pre','post','pre','post'})
set(get(gca,'YLabel'),'String','Perceptual Ratings');
set(get(gca,'XLabel'),'String','<--low vs high-->')
title('low vs high convergence Score')


%% liner trend
pre_post_diff=(score(:,2)-score(:,1))./score(:,1);

gscatter(score(:,3),pre_post_diff,subjects);hold on;
plot( [0 0],get(gca,'ylim'),'k','LineWidth',1)
plot( get(gca,'xlim'),[0 0],'k','LineWidth',1)
set(gca,'xlim',[-0.04 0.08])
set(gca,'ylim',[-0.5 0.5])
set(get(gca,'YLabel'),'String','LLR score (pre - post)/pre');
set(get(gca,'XLabel'),'String','LLR score change from baseline')


%% pre post ratio subjectwise
A = convergence_score_diff(:,1);
A = A/norm(A);

score = cell(size(WORDS_all,1),3);
for i=1:size(Final_stimuli,1)
    a = find(strcmp(fileList_name, Final_stimuli{i,1}));
    [r,c] = find(WORDS_all==a);
    B = Final_rate(i,:);
    a = find(ismember(B,[1 50 100]));
    B(a) = NaN;
    score{r,c} = B;    
    score{r,3} = A(WORDS_all(r,3));
end
a=cellfun(@(x) isempty(x),score);
a = find(a(:,1));
score(a,:) = [];


for i=1:size(C,1)
    ksdensity(C(i,:));
    hold on;
end



ratio = [];
for i =1:size(score,1)
   a = score{i,2}./score{i,1};
   ratio =[ratio;a];    
end

% pre post separate by high low convergence(effort) score
C = ratio;
B = cell2mat(score(:,3));
th = median(B)

a = find(B<= th);
b = find(B> th);

lowconv = nanmean(C(a,:),2);   highconv = nanmean(C(b,:),2);


A = [mean(lowconv) mean(highconv)];
B = [std(lowconv) std(highconv)];

figure;
bar(1:length(A),A);hold on
errorbar(1:length(A),A,B,'.')
set(gca,'XTickLabel',{'pre','post','pre','post'})
set(get(gca,'YLabel'),'String','Perceptual Ratings');
set(get(gca,'XLabel'),'String','<--low vs high-->')
title('low vs high convergence Score')

[p,h] = ranksum(lowconv,highconv)
[h,p] = ttest2(lowconv,highconv)


%% self fulency vs nativeness

self_rating = [];
for i =1:16
    self_rating = [self_rating;project.subjects.data(i).selfRate];  
end
b = [[1:2:32]' [2:2:32]'] ;
A = sum(pre_post_diff(b),2);


[r,p]=corr(self_rating(:,4),A)

speaker_native_score=[];
for i=1:16
   a = find(index(:,3)==i); 
   b = find(index(:,1)==2);% take only Pre
   a=intersect(a,b);
   speaker_native_score = [speaker_native_score;mean(Final_rate(a,:))];
end

speaker_native_score = mean(speaker_native_score,2)
mean(speaker_native_score)
std(speaker_native_score)
[r,p]=corr(self_rating(:,4),speaker_native_score)

%% convergence points vs nativeness
conv_idx = get_condition_index(D,convergence_data,'convergence');
subjects = D(conv_idx,1);

[points,b]=hist(subjects,unique(subjects));

[r,p]=corr(points',speaker_native_score)
gscatter(points',A,1:16);

set(get(gca,'YLabel'),'String','LLR score (pre - post)/pre');
set(get(gca,'XLabel'),'String','Convergence points')



gscatter(points',speaker_native_score,1:16);
set(get(gca,'YLabel'),'String','LLR score pre');
set(get(gca,'XLabel'),'String','Convergence points')


gscatter(points',speaker_native_score,1:16);
set(get(gca,'YLabel'),'String','LLR score post');
set(get(gca,'XLabel'),'String','Convergence points')












