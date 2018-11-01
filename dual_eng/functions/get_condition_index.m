function index = get_condition_index(D,convergence_data,condition)

if(strcmp(condition,'convergence'))
    index = find(convergence_data(:,1) .* convergence_data(:,5));
elseif(strcmp(condition,'noch'))
    
    conv_index = find(convergence_data(:,1) .* convergence_data(:,5));   
    
    index = setdiff([1:length(convergence_data(:,1))]',conv_index);

    temp = find(convergence_data(:,2).* convergence_data(:,5));
    index = setdiff(index,temp);
    temp = find(convergence_data(:,3).* convergence_data(:,5));
    index = setdiff(index,temp);
    temp = find(convergence_data(:,4).* convergence_data(:,5));
    index = setdiff(index,temp);
    
    
    sub_idx = D(index,1);
    session_idx = D(index,2);
    temp = find(sub_idx == 0);
    index(temp,1) = NaN;
    temp = find(session_idx == 1);
    index(temp,1) = NaN;
    temp = find(session_idx == 6);
    index(temp,1) = NaN;
    index(find(isnan(index(:,1))),:)=[];
    
elseif(strcmp(condition,'convergence_A'))
    index = find(convergence_data(:,3).* convergence_data(:,5));
    
    temp = find(convergence_data(:,1).* convergence_data(:,5));
    index = setdiff(index,temp);
    temp = find(convergence_data(:,4).* convergence_data(:,5));
    index = setdiff(index,temp);
    
elseif(strcmp(condition,'convergence_B'))
    index = find(convergence_data(:,4).* convergence_data(:,5));    
    
    temp = find(convergence_data(:,1).* convergence_data(:,5));
    index = setdiff(index,temp);
    temp = find(convergence_data(:,3).* convergence_data(:,5));
    index = setdiff(index,temp);
    
elseif(strcmp(condition,'divergence'))
    index = find(convergence_data(:,2).* convergence_data(:,5));
    
elseif(strcmp(condition,'all'))
    
    index =[];
    for s=2:5
        index = [index;find(D(:,2) == s)];
    end
else
    
end



end