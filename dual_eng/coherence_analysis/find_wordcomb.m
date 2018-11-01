function f = find_wordcomb(word_combination_index)

%%
fake_group_combination = nchoosek(1:26,2);
[~,a,~] = intersect(fake_group_combination,project.subjects.group_no,'rows');
fake_group_combination(a,:) = [];



a = [W(word_combination_index(1)) W(word_combination_index)];


find(ismember(word_comb(:,1),W(word_combination_index(1)))







end