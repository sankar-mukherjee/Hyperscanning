function index = get_condition_index2(convergence_data,condition)

rare = find(convergence_data(:,10)== -100);
% rare = [1:length(convergence_data)]';  
if(strcmp(condition,'convergence'))
    temp = find(~isnan(convergence_data(:,1)));
    index = intersect(temp,rare);
    
elseif(strcmp(condition,'noch'))    
    temp = find(~isnan(convergence_data(:,1)));
    conv_index = intersect(temp,rare);
    
    temp = find(~isnan(convergence_data(:,3)));
    div_index = intersect(temp,rare);
    
    temp = find(~isnan(convergence_data(:,5)));
    conv_indexA = intersect(temp,rare);
    
    temp = find(~isnan(convergence_data(:,7)));
    conv_indexB = intersect(temp,rare);
    
    temp = [1:length(convergence_data)]';   %all
    
    index = setdiff(temp,conv_index);
    index = setdiff(index,div_index);
    index = setdiff(index,conv_indexA);
    index = setdiff(index,conv_indexB);
    
elseif(strcmp(condition,'convergence_A'))    
    temp = find(~isnan(convergence_data(:,5)));
    index = intersect(temp,rare);
    
elseif(strcmp(condition,'convergence_B'))    
    temp = find(~isnan(convergence_data(:,7)));
    index = intersect(temp,rare);
    
elseif(strcmp(condition,'divergence'))
    temp = find(~isnan(convergence_data(:,3)));
    index = intersect(temp,rare);
    
elseif(strcmp(condition,'all'))    
    index =[1:length(convergence_data)]';   %all

else
    
end



end