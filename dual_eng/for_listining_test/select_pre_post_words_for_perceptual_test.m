%% select words for listining test
% 1) using the difference between the pre and post gmmscore

%%
load([project.paths.processedData '/processed_data_word_level.mat'],'D','fileList_name','W');
load([project.paths.processedData '/EEG.mat']);

filelist = dir([project.paths.processedData '/GMM_configs/GMM_scores_32_10_mwv_mfc.mat']);

for ff = 1:length(filelist)
    AAAA = strrep([project.paths.processedData '/GMM_configs/' filelist(ff).name],[project.paths.processedData '/GMM_configs/GMM_scores'],'');
    AAAA = strrep(AAAA,'.mat','');
    
    load([project.paths.processedData '/convergence/convergence' AAAA '.mat']);
    gmm = load([project.paths.processedData '/GMM_configs/GMM_scores' AAAA '.mat'],'gmmScores');
    
    %% compare pre duet post words
    root_pre_word_index = find(D(:,1)== 16 &  D(:,2) == 1);
    root_pre_word_name = W(root_pre_word_index,1);
    
    index = [];
    for ss = 1:length(project.subjects.list)       
        [idx,words]= findCommonWords_pre_duet_post(ss,D,W);
        [a,b] = ismember(words,root_pre_word_name);
        index{ss,1} = idx;
        index{ss,2} = b;
    end
    
    %%
    gmm = sum(gmm.gmmScores,2);
    
    R = [];
    R.GMMscore = [];
    R.RT = [];
    R.baselineDiff = [];
    R.filename = [];
    R.index = [];
    
    for ss = 1:length(project.subjects.list)
        temp = zeros(40,3);
        temp1 = zeros(40,3);
        temp2 = zeros(40,1);
        temp3 = cell(40,3);
        temp4 = zeros(40,3);
        
        for i = 1:size(index{ss,2},1)
            if not(index{ss,2}(i) == 0)
                if not(length(EEG_data{index{ss,1}(i,1),1}) == 0 && length(EEG_data{index{ss,1}(i,2),1}) == 0 && length(EEG_data{index{ss,1}(i,3),1}) == 0)  %% present in eeg
                    temp(index{ss,2}(i),:) = [gmm(index{ss,1}(i,1)) gmm(index{ss,1}(i,2)) gmm(index{ss,1}(i,3))];
                    temp1(index{ss,2}(i),:) = [D(index{ss,1}(i,1),14) D(index{ss,1}(i,2),14) D(index{ss,1}(i,3),14)];
                    temp2(index{ss,2}(i),:) = convergence_score_diff(index{ss,1}(i,2));
                    temp3{index{ss,2}(i),1} = fileList_name(index{ss,1}(i,1));
                    temp3{index{ss,2}(i),2} = fileList_name(index{ss,1}(i,2));
                    temp3{index{ss,2}(i),3} = fileList_name(index{ss,1}(i,3));
                    temp4(index{ss,2}(i),1:3) = index{ss,1}(i,:);
                end
            end
        end
        R.GMMscore{ss,1} = temp;     R.RT{ss,1} = temp1;    R.baselineDiff{ss,1} = temp2;   R.filename{ss,1} = temp3;   R.index{ss,1} = temp4;
    end
    
    %% remove outliers according to reaction time
    for ss = 1:length(project.subjects.list)
        A = cell2mat(R.RT(ss));
        a=find(A>1.5); %1sec max
        A = R.index{ss};
        A(a)=0;
        a = A(:,1) .* A(:,2) .* A(:,3);
        a = find(a==0);
        A(a,:) = 0;
        R.index_C{ss,1} = A;
    end
    
    % arrange the data
    A = cell2mat(R.index_C);
    a = A(:,1) .* A(:,2) .* A(:,3);
    a = find(a==0);
    A(a,:) = [];
    
    pre = A(:,1);
    duet = A(:,2);
    post = A(:,3);
    Score = convergence_score_diff(duet,1);
    Score = Score/norm(Score);
    A = convergence_score_diff(duet,2);
    A = A/norm(A);
    Score = [Score A];
    pre_post_diff = abs(gmm(pre)) - abs(gmm(post));
    pre_post_diff = pre_post_diff/norm(pre_post_diff);
    
    %% selecting criteria of the pre post words
    % 1) select the convergent, divergence, convergence A, convergence B words
    % 2) select the words for which one is divergent (other dont care)
    
    % 1) convergence, divergence, convergence A, convergence B
    WORDS = [];effort_idx = [];
    
    for cc = 1:4
        conv_idx = convergence_data(:,cc) .* convergence_data(:,5);
        conv_idx = find(conv_idx ~= 0);
        [A,a,b] = intersect(duet,conv_idx);
        WORDS = [WORDS;pre(a) post(a) duet(a)];
        effort_idx = [effort_idx;conv_idx];
    end
    % 2)
    conv_idx = find(Score(:,2)<=0);
    WORDS = [WORDS;pre(conv_idx) post(conv_idx) duet(conv_idx)];
    
    WORDS = unique(WORDS,'rows');
    WORDS_all = WORDS;
    WORDS = WORDS(:,1:2);
    
    WORDS_all = [pre post duet];
    %% sort    by effort score
    B = convergence_score_diff(:,1)/norm(convergence_score_diff(:,1));
    A = B(WORDS_all(:,3),1);
    WORDS_all_sort = [WORDS_all A];
    
    [a,b] = sort(WORDS_all_sort(:,4),'descend');
    WORDS_all_sort = WORDS_all_sort(b,:);
    WORDS = WORDS_all_sort(:,1:2);
    
    %     duet(a) = [];Score(a) = [];pre_post_diff(a) = [];
    %     ss = D(A,1);
    %%
    source_path  = 'C:/Users/SMukherjee/Desktop/data/label_creation/wav/';
    destination_path2 = ['C:/Users/SMukherjee/Desktop/data/dual_eng/for_listing_test/'  AAAA '/'];
    mkdir(['C:/Users/SMukherjee/Desktop/data/dual_eng/for_listing_test/'  AAAA]);
    
    A = D(WORDS,1);
    for i = 1:size(WORDS,1)
        for j=1:2
            a = [source_path fileList_name{WORDS(i,j)}];
            b = [destination_path2 num2str(A(i)) '-' num2str(i) '-' fileList_name{WORDS(i,j)}];
            copyfile(a,b);
        end
    end
    
    %% write to text file
    word_txt = [fileList_name(WORDS,1) W(WORDS,1)];
    fileID = fopen([destination_path2 'filenames.txt'],'w');
    formatSpec = '%s , %s\n';
    [nrows,ncols] = size(word_txt);
    for row = 1:nrows
        fprintf(fileID,formatSpec,word_txt{row,:});
    end
    fclose(fileID);
    
end

% get some other subjects who are no present in here
A = D(duet,1);
B = [1 2 3 4 13 14]';
[a,b] = ismember(A,B);
a = find(b);
otherfiles = [pre(a) post(a) duet(a)];

%% sort    by eefort score
B = convergence_score_diff(:,1)/norm(convergence_score_diff(:,1));
A = B(otherfiles(:,3),1);
otherfiles_sort = [otherfiles A];

[a,b] = sort(otherfiles_sort(:,4),'descend');
otherfiles_sort = otherfiles_sort(b,:);
otherfiles = otherfiles_sort(:,1:2);

destination_path2 = ['C:/Users/SMukherjee/Desktop/data/dual_eng/for_listing_test/'  AAAA '/other/'];
mkdir(destination_path2);

A = D(otherfiles,1);
for i = 1:size(otherfiles,1)
    for j=1:2
        a = [source_path fileList_name{otherfiles(i,j)}];
        b = [destination_path2 num2str(A(i)) '-' num2str(i) '-' fileList_name{otherfiles(i,j)}];
        copyfile(a,b);
    end
end

%% write to text file
word_txt_other = [fileList_name(otherfiles,1) W(otherfiles,1)];
fileID = fopen([destination_path2 'filenames.txt'],'w');
formatSpec = '%s , %s\n';
[nrows,ncols] = size(word_txt_other);
for row = 1:nrows
    fprintf(fileID,formatSpec,word_txt_other{row,:});
end
fclose(fileID);

%%
path = 'C:\Users\SMukherjee\Documents\NetBeansProjects\spic_listen\web\sound\stimuli\wav\';
filelist = dir(path);
file_name = {filelist.name};
file_name = file_name(3:end)';
word = [word_txt ; word_txt_other];

files = [];
for i=1:size(file_name,1)
A = strsplit(file_name{i},'-');
files{i,1} = [A{3} '-' A{4}];
end

[a,b] = ismember(files,word(:,1));
a=find(b);
b=b(a);
txt_other = [file_name word(b,2)];

fileID = fopen([path 'filenames.txt'],'w');
formatSpec = '%s , %s\n';
[nrows,ncols] = size(txt_other);
for row = 1:nrows
    fprintf(fileID,formatSpec,txt_other{row,:});
end
fclose(fileID);
% 
% 
% UP = nanmean(Score(:,1))+1.5*nanstd(Score(:,1));
% LW = nanmean(Score(:,1))-1.5*nanstd(Score(:,1));
% 
% A = find(Score(:,1)>=UP);
% B = find(Score(:,1)<=LW);
% a = [A;B];
% dist_words = [pre(a) post(a)];
% dist_words = unique(dist_words,'rows');
% 
% A = D(dist_words,1);



% %% copy the sound files
% source_path  = 'C:/Users/SMukherjee/Desktop/data/label_creation/wav/';
% destination_path2 = 'C:/Users/SMukherjee/Desktop/data/dual_eng/for_listing_test/';
%
% Score = [];
% for ss = 1:length(project.subjects.list)
%     A = R.index_C{ss};
%     for i = 1:size(A,1)
%         for j=1:2:3
%             if not(A(i,j)==0)
%                 a = [source_path fileList_name{A(i,j)}];
%                 b = [destination_path2 num2str(ss) '-' num2str(i) '-' fileList_name{A(i,j)}];
%                 copyfile(a,b);
%                 Score = [Score; convergence_score_diff(A(i,j))];
%             end
%         end
%     end
% end
%
%
%
%
%
%
%
% A = D(A,1);

A = D(duet,1);
A = D(WORDS_all(:,3),1);

[a,b] = ismember(duet,WORDS_all(:,3));
b = find(b);

X = Score(b,1);
Y = pre_post_diff(b);
%
% X = Score(:,1);
% Y = pre_post_diff;
%
% %
figure;
gscatter(X,Y,A);hold on;
plot( [0 0],get(gca,'ylim'),'k','LineWidth',1)
plot( get(gca,'xlim'),[0 0],'k','LineWidth',1)
set(gca,'xlim',[-0.2 0.15])
set(gca,'ylim',[-0.1 0.25])
set(get(gca,'YLabel'),'String','LLR score [pre - post]');
set(get(gca,'XLabel'),'String','LLR score change from baseline')
%
%
% convergence no change
% figure;
effort_idx = unique(effort_idx);
[A,a,b] = intersect(duet,effort_idx);

for i=1:length(duet)
    if(ismember(duet(i),A))
        plot(Score(i,1),pre_post_diff(i),'o','LineWidth',2,'MarkerEdgeColor','b','MarkerFaceColor','b');
        hold on;
    else
        plot(Score(i,1),pre_post_diff(i),'^','LineWidth',2,'MarkerEdgeColor','r','MarkerFaceColor','r');
        hold on;
    end
end
set(get(gca,'YLabel'),'String','LLR score [pre - post]');
set(get(gca,'XLabel'),'String','LLR score change from baseline')
%
% % by subject mean
% Score_Mean_sub = accumarray(A,Score,[],@mean);
% pre_post_diff_Mean_sub = accumarray(A,pre_post_diff,[],@mean);
% figure;
% gscatter(Score_Mean_sub,pre_post_diff_Mean_sub,1:16);hold on;
% plot( [0 0],get(gca,'ylim'),'k','LineWidth',1)
% plot( get(gca,'xlim'),[0 0],'k','LineWidth',1)
% set(get(gca,'YLabel'),'String','LLR score [pre - post]');
% set(get(gca,'XLabel'),'String','LLR score change from baseline')
%
%
% %% subject by subject
% for ss = 1:length(project.subjects.list)
%     A = cell2mat(R.GMMscore_C(ss));
%     B = A(:,1);
%     C = A(:,3);
%     a = B .* C;
%     a = find(a==0);
%     B(a) = NaN;    C(a) = NaN;
%     pre_post_diff = abs(B) - abs(C);
%
%
%     if(ss == 1 || ss == 2 ||ss == 3 ||ss == 4)
%         [B,C] = max(pre_post_diff);
%         index1 = C;
%         [B,C] = min(pre_post_diff);
%         index2 = C;
%     else
%         UP = nanmean(pre_post_diff)+project.convergence.fakestd*nanstd(pre_post_diff);
%         LW = nanmean(pre_post_diff)-project.convergence.fakestd*nanstd(pre_post_diff);
%         index1 = [find(pre_post_diff>=UP)'];
%         index2 = [find(pre_post_diff<=LW)'];
%     end
%
%     A = R.filename{ss};
%
%     for fb = 1:length(index1)
%         for i=1:2:3
%             a = [source_path cell2mat(A{index1(fb),i})];
%             b = [destination_path2 num2str(ss) '-' num2str(index1(fb)) '-' cell2mat(A{index1(fb),i})];
%             copyfile(a,b);
%         end
%     end
%
%     for fb = 1:length(index2)
%         for i=1:2:3
%             a = [source_path cell2mat(A{index2(fb),i})];
%             b = [destination_path2 num2str(ss) '-' num2str(index2(fb)) '-' cell2mat(A{index2(fb),i})];
%             copyfile(a,b);
%         end
%     end
% end
%
%
% %% merge all the subjects
% A = cell2mat(R.GMMscore_C);
% B = A(:,1);
% C = A(:,3);
% a = B .* C;
% a = find(a==0);
% B(a) = NaN;    C(a) = NaN;
% pre_post_diff = abs(B) - abs(C);
%
% UP = nanmean(pre_post_diff)+project.convergence.fakestd*nanstd(pre_post_diff);
% LW = nanmean(pre_post_diff)-project.convergence.fakestd*nanstd(pre_post_diff);
%
% index1 = [find(pre_post_diff>=UP)'];
% index2 = [find(pre_post_diff<=LW)'];
% A = [];
% for ss = 1:length(project.subjects.list)
%     A = [A;R.filename{ss}];
% end
%
% destination_path = 'C:/Users/SMukherjee/Desktop/data/for_listing_test/max/';
%
% for ss = 1:length(index1)
%     for i=1:2:3
%         a = [source_path cell2mat(A{index1(ss),i})];
%         b = [destination_path num2str(index1(ss)) '-' cell2mat(A{index1(ss),i})];
%         copyfile(a,b);
%     end
% end
% destination_path = 'C:/Users/SMukherjee/Desktop/data/for_listing_test/min/';
%
% for ss = 1:length(index2)
%     for i=1:2:3
%         a = [source_path cell2mat(A{index2(ss),i})];
%         b = [destination_path num2str(index2(ss)) '-' cell2mat(A{index2(ss),i})];
%         copyfile(a,b);
%     end
% end
%
%
% %% see if the change are signnificant or not
% stat.p = [];stat.z=[];stat.h=[];stat.len=[];
% for ss = 1:length(project.subjects.list)
%     A = cell2mat(R.GMMscore_C(ss));
%     % original
%     B = A(:,1);
%     C = A(:,3);
%     a = B .* C;
%     a = find(a==0);
%     B(a) = NaN;    C(a) = NaN;
%     pre_post_diff = abs(B) - abs(C);
%
%     [x,y] = ksdensity(pre_post_diff);
%     figure;
%     plot(y,x,'r');hold on;
%     % fake
%     sub = ss;
%     if (mod(sub,2))
%         partner = ss+1;
%     else
%         partner = ss-1;
%     end
%     fake_group_combination = generate_fakeduets([sub partner],0,project);
%     temp = [];
%     for fake = 1:length(fake_group_combination)
%         A = cell2mat(R.GMMscore_C(fake_group_combination(fake,1)));
%         A = A(:,1);
%         B = cell2mat(R.GMMscore_C(fake_group_combination(fake,2)));
%         B = B(:,1);
%
%         a = A .* B;
%         a = find(a==0);
%         A(a) = NaN;    B(a) = NaN;
%         temp = [temp;abs(A) - abs(B)];
%     end
%
%     A = pre_post_diff;A(isnan(A))=[];A=length(A);
%     B = temp;B(isnan(B))=[];B=length(B);
%     stat.len = [stat.len;[A B]];
%
%     [A,B,C] = ranksum(pre_post_diff , temp);
%
%     stat.p = [stat.p;A];
%     stat.z = [stat.z;C.zval];
%     stat.h = [stat.h;B];
%
%     ksdensity(temp);
% %     pause;
% end
% close all;
%
%
% %% convergence score vs pre-post score for each subject
% conv_idx = find(convergence_data(:,1) .* convergence_data(:,5));
% gmm_score = gmm(conv_idx);
% id = D(conv_idx,1);
% % id = D(:,1);
% % gmm_score = gmm;
%
% figure;
% for ss = 1:length(project.subjects.list)
%     A = cell2mat(R.GMMscore_C(ss));
%     % original
%     B = A(:,1);
%     C = A(:,3);
%     a = B .* C;
%     a = find(a==0);
%     B(a) = NaN;    C(a) = NaN;
%     pre_post_diff = abs(B) - abs(C);
%     a = find(id==ss);
% %     a = abs(gmm_score(a));
%     a = abs(A(:,2));
%
%     a(a==0)=[];
%     plot(nanmean(a),nanmean(pre_post_diff),project.util.marker{ss});hold on;
%
% end
%
% %%
% for g = 1:length(project.subjects.group)
%     A = project.subjects.group_no(g,1);
%     B = project.subjects.group_no(g,2);
%
%     A = cell2mat(R.GMMscore(A));
%     B = cell2mat(R.GMMscore(B));
%
%     A_diff = abs(A(:,1)) - abs(A(:,3));
%     B_diff = abs(B(:,1)) - abs(B(:,3));
%     a = A_diff .* B_diff;
%     a = find(a==0);
%     A_diff(a) = [];    B_diff(a) = [];
%
%     scatter(A_diff,B_diff);hold on;
% end
%
% figure;
% for sub = 1:length(project.subjects.list)
%     A = cell2mat(R.GMMscore(sub));
%     A_diff = abs(A(:,1)) - abs(A(:,3));
%
%     B = cell2mat(R.RT(sub));
%     B_diff = abs(B(:,1)) - abs(B(:,3));
%     %     B_diff = abs(B(:,2));
%
%     C = cell2mat(R.baselineDiff(sub));
%
%
%
%     a = A_diff .* B_diff .* C;
%     a = find(a==0);
%     A_diff(a) = [];    B_diff(a) = []; C(a)=[];
%     plot(C,A_diff,'.');
%     %     scatter3(B_diff,A_diff,C,'filled');
%     hold on;
% end
% xlabel('RT_diff')
% ylabel('GMMScore_diff')
% zlabel('baseline_diff')
%
%
% figure;
% for sub = 1:length(project.subjects.list)
%     A = cell2mat(R.GMMscore(sub));
%
%     B = A(:,1);
%     C = A(:,3);
%
%     a = B .* C;
%     a = find(a==0);
%     B(a) = [];    C(a) = [];
%     A_diff = abs(B) - abs(C);
%
%     [x,y] = ksdensity(A_diff);
%     plot(y,x,project.util.marker{sub});
%     hold on;
% end







