

%%
a=nchoosek(1:40,2);
A = find(a(:,2)-a(:,1)>2);
a = a(A,:);

A = cell(length(a),1);
for i=1:length(a)
    freq = [a(i,1) a(i,2)];
    A{i,1}=sig_find(signifincat,freq,prespeechTFR,3);
end
B = A(~cellfun('isempty',A))  ;

A = cell2mat(B);

a=find(ismember(A(:,2),[1:5]));
A(a,:) = [];
a=find(A(:,3)>-0.1);
A(a,:) = [];
a=find(A(:,3)<-0.48);
A(a,:) = [];
a = find(A(:,5)-A(:,4)>2);
A = A(a,:);



[~,a] = unique(A(:,1:3),'rows');
A=A(sort(a),:);
a = [prespeechTFR{1,1}.label(A(:,1))'];


glm_coeff = cat(5,glm_coeff1, glm_coeff2, glm_coeff3);
glm_coeff = permute(glm_coeff,[5 1 2 3 4]);
