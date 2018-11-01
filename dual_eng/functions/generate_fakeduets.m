function combos = generate_fakeduets(current_comb,gender,project)
%% fake group generation

if(gender == 0)
    combos = nchoosek(1:length(project.subjects.list),2);
    id = find(all(ismember(combos,current_comb),2));
    combos(id,:) = [];
else
    
    gender = find(project.subjects.female == current_comb(1));
    if(isempty(gender))
        gender =  'm';
    else
        gender = 'f';
    end
    other = 1:length(project.subjects.list);
    if(strcmp(gender,'m'))
        other(project.subjects.female)=0;
    else
        other(project.subjects.male)=0;
    end
    other(find(other==0))=[];
    
    combos = nchoosek(other,2);
    id = find(all(ismember(combos,current_comb),2));
    combos(id,:) = [];
end

%% remove real ones
[C,D] = sortrows([combos;project.subjects.group_no]);
E = all(C(1:end-1,:)==C(2:end,:),2);
id = D(E);
combos(id,:) = [];
end