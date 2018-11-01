%% preprocessing of creation of surrogate data

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
index_comb = [index_comb a];

load([project.paths.processedData '/processed_data_word_level.mat']);

word_comb = [W(index_comb(:,1),1) W(index_comb(:,2),1)];
b = find(cellfun('isempty',word_comb(:,1)));
word_comb(b,:)=[];index_comb(b,:)=[];
b = find(cellfun('isempty',word_comb(:,2)));
word_comb(b,:)=[];index_comb(b,:) = [];

%% surrogate creation

% original word combination
load('SPIC_text.mat', 'Oword_comb')
a = [c;c];
for i=1:198
    if(a(i)==2)
        A = Oword_comb(i,:);
        Oword_comb{i,1} = A{1,2};
        Oword_comb{i,2} = A{1,1};
    end
end
Oword_comb = [Oword_comb;Oword_comb(:,2) Oword_comb(:,1)];

% surrogate combination creation (did not acctial require i figured it out after the complete code)
fake_group_combination = nchoosek(1:16,2);
[~,a,~] = intersect(fake_group_combination,project.subjects.group_no,'rows');
fake_group_combination(a,:) = [];

a = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16;
    1 2 1 2 2 1 2 1 2 1 1 2 2 1 2 1];

for i=1:length(fake_group_combination)
    fake_group_combination(i,3) = a(2,find(ismember(a(1,:),fake_group_combination(i,1))));
    fake_group_combination(i,4) = a(2,find(ismember(a(1,:),fake_group_combination(i,2))));
end
fake_group_combination(find((fake_group_combination(:,3) - fake_group_combination(:,4)) == 0),:)=[];
for i=1:length(fake_group_combination)
    if(fake_group_combination(i,3)==2)
        fake_group_combination(i,:) = [fake_group_combination(i,2) fake_group_combination(i,1) fake_group_combination(i,4) fake_group_combination(i,3)];
    end
end

% surrogate trials distribution for each original word combination
s_comb = [];
for i=1:length(Oword_comb)
    a = index_comb(find(ismember(word_comb(:,1),Oword_comb{i,1}) & ismember(word_comb(:,2),Oword_comb{i,2})),:);
    b = index_comb(find(ismember(word_comb(:,1),Oword_comb{i,2}) & ismember(word_comb(:,2),Oword_comb{i,1})),:);
    
    if(a(1,3)==2)
        c = [a(:,[2 1 4 5]) ; b(:,[1 2 5 4])];
    elseif(a(1,3)==1)
        c = [a(:,[1 2 4 5]) ; b(:,[2 1 5 4])];
    end
    
    [A,B] = meshgrid(c(:,1),c(:,2));
    a=cat(2,A',B');
    A=reshape(a,[],2);
    [~,a,~] = intersect(A,c(:,1:2),'rows');
    A(a,:) = [];
    s_comb{i,1} = A;
end

save('surrogate_trial','s_comb','word_comb','index_comb');
