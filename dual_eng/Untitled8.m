%% self fulency stat

a = [];

for i =1:16
    a = [a;project.subjects.data(i).selfRate];  
end

mean(a)
std(a)

%% no of trails in both conditions
A = [];

for i=1:16
   A = [A;size(NOCH_tf{i}.powspctrm,1)] ;
end

sum(A)
%% find rejected trials my mistake
% duet
M = [];
for i=1:16
    a = find(D(:,1)==i);
    b = D(a,2);
    c = find(ismember(b,[2 3 4 5]));
    M =[M;200-length(c)];
end
%pair average
a = [[1:2:16]' [2:2:16]'] ;
b = sum(M(a),2)
mean(b)
std(b)

% solo
M = [];
for i=1:16
    a = find(D(:,1)==i);
    b = D(a,2);
    c = find(ismember(b,[1 6]));
    M =[M;length(c)];
end
%pair average
a = [[1:2:16]' [2:2:16]'] ;
b = sum(M,2)
mean(b)
std(b)











c =  sum(A(a),2)

%% conv nochange RT
load([project.paths.processedData '/convergence/convergence_' num2str(project.gmmUBM.gmmcomp) '_10_mwv_mfc.mat']);
load([project.paths.processedData '/processed_data_word_level.mat']);

conv_idx = get_condition_index(D,convergence_data,'convergence');
conv_idx = check_reactionTime(conv_idx,D,5);
noCh_idx = get_condition_index(D,convergence_data,'noch');
noCh_idx = check_reactionTime(noCh_idx,D,5);
conv_idx = D(conv_idx,14);
noCh_idx = D(noCh_idx,14);

A = [mean(conv_idx) mean(noCh_idx)];
B = [std(conv_idx)/sqrt(length(conv_idx)) std(noCh_idx)/sqrt(length(noCh_idx))];
figure;
bar(1:length(A),A);hold on
errorbar(1:length(A),A,B,'.')
set(gca,'ylim',[0 0.5]);
set(gca,'XTickLabel',{'Convergence','NoChange'});
% title('Convergence vs NoChange');
ylabel('Reaction Time (s)');

[p,h,stats] = ranksum(conv_idx,noCh_idx)
[h,p,ci,stats] = ttest2(conv_idx,noCh_idx)

%% gmm ubm trials
a = find(D(:,2)==1);
A = [];
for i =1:length(a)
    A = [A;size(mfc{a(i)},2)];
end
sum(A)

B = [];
for i=1:16
    A = [];
    for session = 2:5
        a = find(D(:,1)==i & D(:,2)== session);
        for j =1:length(a)
            
            A = [A size(mfc{a(i)},2)];
        end
    end
    B = [B; sum(A)];
end

a = sum(B)

%% no of convergence per subject
conv_idx = get_condition_index(D,convergence_data,'convergence');

x = D(conv_idx,1);
[A,b]=hist(x,unique(x))
%pair average
a = [[1:2:16]' [2:2:16]'] ;
A =A';
b = sum(A(a),2);
b=(b/200)*100;
mean(b)
std(b)
%% male female subjectwise difference

male = A(project.subjects.male);
female = A(project.subjects.female);
[p,h,stats] = ranksum(male,female)

%% male female couple difference

b=sum(A(a),2);

male_couple = b([1 2 3 7]);
female_couple = b([4 5 6 8]);
[p,h,stats] = ranksum(male_couple,female_couple)

%% convergent words textual
sub = D(conv_idx,1);
conv_idx = conv_idx(59:end);

xx = W(conv_idx);
duet = [duet_1;duet_2];

A = zeros(200,1);
for i=1:length(xx)
    a = find(ismember(duet,xx{i}));
    A(a) = A(a)+1;
end

B = zeros(200,1);
for i=1:length(keywords)
    a = find(ismember(duet,keywords{i}));
    B(a) = A(a);
end


h1 = bar(A);hold on;h2 = bar(B);
set(h2,'FaceColor','red');
set(gca, 'xlim',[0 201]);
set(gca, 'XTick',[1:200]);
set(gca, 'XTickLabel',duet,'XTickLabelRotation',90);

% avg convergent words for keywords(pre) and others in the duet 
a=sum(B(find(B)))/(40*16);
b=A-B;
b=sum(b(find(b)))/(160*16);
bar([a b])



%% generate word combination


Oword_comb = [duet_1(1:end-1) duet_1(2:end);duet_2(1:end-1) duet_2(2:end)];


%% real exp word combition 
index = [];i=41;
for sub=1:16
    index = [index;i:i+199];
    i=i+280;    
end

c = repmat([1 2],1,50);
c = c(1:end-1)';

index_comb = [];
for i=1:2:16
    
    A = index(i,:);
    B = index(i+1,:);
    j=0;
    for s=1:4
        a = A(j+1:j+50);
        b = B(j+1:j+50);        
       
        a = repmat(a,2,1);
        a = a(:);
        b = repmat(b,2,1);
        b = b(:);
        
        if(project.subjects.data(i).position == 1)
            if(s == 1 || s == 2)
                a = a(2:end);b=b(1:end-1);
                aa = a; bb=b; cc = c;
            else
                a = a(1:end-1);b=b(2:end);
                aa = a; bb=b; cc = [c(2:end);2];
            end
        elseif(project.subjects.data(i).position == 2)
             if(s == 1 || s == 2)
                a = a(1:end-1);b=b(2:end);
                aa = a; bb=b; cc = [c(2:end);2];
            else
                a = a(2:end);b=b(1:end-1);
                aa = a; bb=b; cc = c;
            end
        end
        
        index_comb = [index_comb; aa bb cc s*ones(length(aa),1)];           
        
        j=j+50;
    end  
end

a = [];
for i=1:2:16
    a = [a;i*ones(396,1) i+1*ones(396,1)];
end
Oindex_comb = [index_comb a];





%%
load([project.paths.processedData '/convergence/convergence_' num2str(project.gmmUBM.gmmcomp) '_10_mwv_mfc.mat']);
load([project.paths.processedData '/processed_data_word_level.mat'],'D');

conv_idx = get_condition_index(D,convergence_data,'convergence');
noCh_idx = get_condition_index(D,convergence_data,'noch');

convergence_A = get_condition_index(D,convergence_data,'convergence_A');
convergence_B = get_condition_index(D,convergence_data,'convergence_B');


sub_C = D(conv_idx,1);
sub_N = D(noCh_idx,1);
sub_A = D(convergence_A,1);
sub_B = D(convergence_B,1);

[a,b]=hist(sub_A,unique(sub_A))
[a,b]=hist(sub_B,unique(sub_B))

%% new

noCh_idx = get_condition_index2(convergence_data,'noch');

convergence_A = get_condition_index2(convergence_data,'convergence_A');
convergence_B = get_condition_index2(convergence_data,'convergence_B');



index = Oindex_comb(convergence_A,5:6);
index = index(:,1);
[A,Ai]=hist(index,unique(index))

index = Oindex_comb(convergence_B,5:6);
index = index(:,2);
[B,Bi]=hist(index,unique(index))

sub = sortrows([Ai' Bi';A B]',1);


index = get_condition_index2(convergence_data,'convergence');
index = Oindex_comb(index,5:6);
index = index(:);
[a,b]=hist(index,unique(index))

sub = sortrows([b a'],1);
bar(sub(:,1),sub(:,2))

