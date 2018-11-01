function [index,a] = findCommonWords_pre_duet_post(sub,D,W)
%%

pre_index = find(D(:,1)== sub &  D(:,2) == 1);
pre_word = W(pre_index,1);

post_index = find(D(:,1)== sub &  D(:,2) == 6);
post_word = W(post_index,1);

duet_index = [];
for session = 2:5
    temp = find(D(:,1)== sub &  D(:,2) == session);
    duet_index = [duet_index;temp];    
end
duet_word = W(duet_index,1);

[a,b] = ismember(pre_word,duet_word);
[a,c] = ismember(pre_word,post_word);

remove_idx_duet = find(b==0);
remove_idx_post = find(c==0);

f = 1:length(pre_word);

pre_index(remove_idx_duet) = NaN;
pre_index(remove_idx_post) = NaN;
b(remove_idx_duet) = NaN;
b(remove_idx_post) = NaN;
c(remove_idx_duet) = NaN;
c(remove_idx_post) = NaN;
f(remove_idx_duet) = NaN;
f(remove_idx_post) = NaN;

pre_index(isnan(pre_index))=[];
b(isnan(b))=[];
c(isnan(c))=[];
f(isnan(f))=[];


a = pre_word(f);
d = duet_word(b);
e = post_word(c);

index = [pre_index duet_index(b) post_index(c)];
end