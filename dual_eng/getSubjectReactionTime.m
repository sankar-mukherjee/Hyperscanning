% get reaction time

duet_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/01_post_import/';
duet_path2 = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/duet/00_original_nocut_afterImport/';
post_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/solo_post/01_post_import/';
pre_path = 'C:/Users/SMukherjee/Desktop/data/dual_eeg/MNI/sankar/spic/epochs/solo_pre/01_post_import/';


subjectReactionTime = [];
for ss = 1:length(project.subjects.list)
    
    if(ss==8 || ss == 10 || ss == 14 || ss == 16)
        file_name = [duet_path2 project.subjects.data(1,ss).name '_duet_raw.set'];
    else
        file_name = [duet_path project.subjects.data(1,ss).name '_duet_raw.set'];
    end
    EEG = pop_loadset(file_name);
    
    
    all_events_latency=[EEG.event.latency];
    all_events_type={EEG.event.type};
    
    numev = size(all_events_type, 2);
    j = 1;k=1;
    temp = [];
    temp1 = [];
    
    for ev=1:(numev)
        if(project.subjects.data(1,ss).position == 1)
            typeV = '31';
            type = '41';
        else
            typeV = '32';
            type = '42';
        end
        if (strcmp(all_events_type{ev}, type))
            temp{j,1} = all_events_type(ev);
            temp{j,2} = all_events_latency(ev);
            j=j+1;
        end
        if (strcmp(all_events_type{ev}, typeV))
            temp1{k,1} = all_events_type(ev);
            temp1{k,2} = all_events_latency(ev);
            k=k+1;
        end
    end
    
    temp3 = all_events_latency(find(ismember(all_events_type, '2')));
    temp3 = [0 temp3];
    
    if(ss==4)
        temp = [temp(1:100,:);temp(102:152,:);temp(154:end,:)];
        temp1 = [temp1(1:100,:);temp1(102:152,:);temp1(154:end,:)];
    elseif(ss==2)
        a = temp(1:2,:);
        a{1,2} = 1;        a{2,2} = 1;
        temp = [a;temp(1:98,:);temp(100:150,:);temp(152:end,:)];
        temp1 = [a;temp1(1:98,:);temp1(100:150,:);temp1(152:end,:)];
    end
    
    for i=1:4
        temp11 = cell2mat(temp(:,2));
        index = find(temp11>temp3(i) & temp11<temp3(i+1));
        
        subjectReactionTime{ss,i,1} = temp(index,:);
        subjectReactionTime{ss,i,2} = temp1(index,:);
        subjectReactionTime{ss,i,3} = project.subjects.data(1,ss).position;
        %         subjectReactionTime{ss,1} = temp;
        %         subjectReactionTime{ss,2} = temp1;
        %         subjectReactionTime{ss,3} = project.subjects.data(1,ss).position;
    end
end
%% pre post

subjectReactionTime_pre = [];
subjectReactionTime_post = [];

for ss = 1:length(project.subjects.list)
    %% pre
    file_name = [pre_path project.subjects.data(1,ss).name '_solo_pre_raw.set'];
    EEG = pop_loadset(file_name);
    
    all_events_latency=[EEG.event.latency];
    all_events_type={EEG.event.type};
    
    numev = size(all_events_type, 2);
    j = 1;k=1;
    temp = [];
    temp1 = [];
    for ev=1:(numev)
        typeV = '11';
        type = '21';
        if (strcmp(all_events_type{ev}, type))
            temp{j,1} = all_events_type(ev);
            temp{j,2} = all_events_latency(ev);
            j=j+1;
        end
        if (strcmp(all_events_type{ev}, typeV))
            temp1{k,1} = all_events_type(ev);
            temp1{k,2} = all_events_latency(ev);
            k=k+1;
        end
    end
    
    subjectReactionTime_pre{ss,1} = temp;
    subjectReactionTime_pre{ss,2} = temp1;
    
    %% post
    file_name = [post_path project.subjects.data(1,ss).name '_solo_post_raw.set'];
    EEG = pop_loadset(file_name);
    
    all_events_latency=[EEG.event.latency];
    all_events_type={EEG.event.type};
    
    numev = size(all_events_type, 2);
    j = 1;k=1;
    temp = [];
    temp1 = [];
    for ev=1:(numev)
        typeV = '12';
        type = '22';
        if (strcmp(all_events_type{ev}, type))
            temp{j,1} = all_events_type(ev);
            temp{j,2} = all_events_latency(ev);
            j=j+1;
        end
        if (strcmp(all_events_type{ev}, typeV))
            temp1{k,1} = all_events_type(ev);
            temp1{k,2} = all_events_latency(ev);
            k=k+1;
        end
    end
    subjectReactionTime_post{ss,1} = temp;
    subjectReactionTime_post{ss,2} = temp1;
end

%%
save([project.paths.processedData '/reactionTime.mat'],'subjectReactionTime','subjectReactionTime_post','subjectReactionTime_pre');






