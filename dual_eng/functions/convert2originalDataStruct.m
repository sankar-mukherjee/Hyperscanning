function convergence_data = convert2originalDataStruct(all,data,project,file_name_suffix)
%% convergence, divergence, convergence A, convergence B, rare events
convergence_data = zeros(size(data,1),5);
load([project.paths.processedData '/convergence/word_pair_position' file_name_suffix '.mat']);

%% construct sequence
a = 1:50;
j=1;
z = zeros(99,2);
for i=1:2:99
    z(i,1) = a(j);
    z(i,2) = a(j);
    
    if(i ~=99)
        z(i+1,1) = a(j);
        z(i+1,2) = a(j+1);
    end
    j=j+1;
end

%% main
for condition = 1:5
    
    group_data = cell2mat(squeeze(all(:,:,condition)));
    idxA = cell2mat(squeeze(word_pair_position(:,:,2)));
    idxB = cell2mat(squeeze(word_pair_position(:,:,3)));
    position = cell2mat(squeeze(word_pair_position(:,:,1)));
    
    idxA = idxA .* group_data;
    idxB = idxB .* group_data;
    
    leader = position;
    leader(leader==2)=0;
    
    index= [];
    index(:,:,1) = idxA .* leader;
    index(:,:,2) = idxB .* leader;
    index(find(index == 0)) = NaN;
    index = index(:);
    index(find(isnan(index))) = [];
    convergence_data(index,condition) = 1;
    
    
    follower = position;
    follower(follower==1)=0;
    follower(follower==2)=1;

    index= [];
    index(:,:,1) = idxA .* follower;
    index(:,:,2) = idxB .* follower;
    index(find(index == 0)) = NaN;
    index = index(:);
    index(find(isnan(index))) = [];
    convergence_data(index,condition) = 2;
    
    %
    %     for g=1:length(project.subjects.group)
    %         group_data = all(g,:,condition);
    %         sub = project.subjects.group_no(g,1);
    %         partner = project.subjects.group_no(g,2);
    %         position = project.subjects.data(sub).position;
    %
    %         for session= 2:5
    %             %% arrange word pair combination per session
    %             if(position == 1 && (session == 2 || session == 3))
    %                 combination = z;
    %             elseif(position == 1 && (session == 4 || session == 5))
    %                 combination = [z(:,2) z(:,1)];
    %             elseif(position == 2 && (session == 2 || session == 3))
    %                 combination = [z(:,2) z(:,1)];
    %             elseif(position == 2 && (session == 4 || session == 5))
    %                 combination = z;
    %             end
    %
    %             session_data = group_data{session-1};
    %             idx = find(session_data);
    %             if(length(idx)>0)
    %                 for i=1:length(idx)
    %                     sub_A = find(data(:,1)== sub &  data(:,2) == session &  data(:,3) == combination(idx(i),1));
    %                     sub_B = find(data(:,1)== partner &  data(:,2) == session &  data(:,3) == combination(idx(i),2));
    %
    %                     if(length(sub_A)>0)
    %                         convergence_data(sub_A,condition) = convergence_data(sub_A,1)+1;
    %                     end
    %                     if(length(sub_B)>0)
    %                         convergence_data(sub_B,condition) = convergence_data(sub_B,1)+1;
    %                     end
    %
    %                 end
    %             end
    %         end
    %     end
end

end











