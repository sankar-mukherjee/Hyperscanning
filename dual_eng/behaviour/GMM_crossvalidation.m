%% gmm ubm cross validation course in post session
load([project.paths.processedData '/processed_data_word_level.mat'],'D','mfc');

%% mfc raw , mfc feat wrap, mfc+f0,f1,f2,intensit = 43 (raw), same with feat wrap
input_data = mfc;

for i=1:length(input_data)
    A=input_data{i,1};
    if not(isempty(A))
        A = A(1:39,:);
    end
    input_data{i,1} = A;
end
%% Train UBM
ubm = train_UBM(D,input_data, 512, project.gmmUBM.itaration, 1, 1,project);
A = [];
for g=1:length(project.subjects.group)
    %% get gmm to be adapt traning data
    trainSpeakerData = get_gmm_trainData([project.subjects.group_no(g,1) project.subjects.group_no(g,2)],D,input_data);
    %% Adapt Speaker
    gmm = adapt_gmm(trainSpeakerData,2,project.gmmUBM.MAP_tau,project.gmmUBM.MAPconfig,ubm);
    A = [A;gmm];
end
gmm = A;


figure;EER = [];
for sss=6
    testSpeakerData = [];answers=[];P=1;
    for i=1:16
        %         subA = [];
        %         for s=6
        %             idx_A = find(D(:,1)==i & D(:,2)== s);
        %             subA = [subA;mfc(idx_A)];
        %         end
        %         for j=1:length(subA)
        %             subA{j,1} = subA{j,1}';
        %         end
        %         testSpeakerData{i,1} = cell2mat(subA)';
        
        subA = [];
        for s=sss
            idx_A = find(D(:,1)==i & D(:,2)== s);
            subA = [subA;input_data(idx_A)];
        end
        
        testSpeakerData = [testSpeakerData;subA];
        answers = [answers;P size(testSpeakerData,1)];
        P = size(testSpeakerData,1)+1;
    end
    
    A=[];
    for i=1:16
        for j=1:length(testSpeakerData)
            A = [A;i j];
        end
    end
    
    [gmmScores,gmmScores_std] = score_gmm_trials(gmm, testSpeakerData, A, ubm);
    
    
    B = [];j=1;P=[];
    for i = 1:length(testSpeakerData):length(gmmScores)
        A = zeros(length(testSpeakerData),1);
        s = answers(j,1);
        e = answers(j,2);j=j+1;
        A(s:e) = 1;
        B = [B;A];
    end
    
    
    
    [a,b,c]=compute_eer(gmmScores, B, true);
    EER = [EER;a b c];
    hold on
%     
    P = reshape(gmmScores,length(testSpeakerData),16);g=[];
    for i=1:16
        A = P(:,i);B=[];
        for j=1:length(answers)
            B =[B; mean(A(answers(j,1):answers(j,2)))];
        end
        g = [g B];
    end
    imagesc(g);
% %     caxis([-0.2 0.1]);
%     %
%     % imagesc(reshape(gmmScores,16, 16));
%     set(gca,'XTick',[1:16]);
%     set(gca,'XTickLabel',[1:16]);
%     
%     set(gca,'YTick',[1:16]);
%     set(gca,'YTickLabel',[1:16]);
%     xlabel('Speaker GMM Model');
%     ylabel('Post Speaker Speech');
%     title('Speaker Verification Likelihood (LLR)');
    % caxis([0 0.5]);
    
        A=reshape(gmmScores,length(testSpeakerData), 16);
%         B = reshape(gmmScores_std,length(testSpeakerData), 16);
        
        
a = mean(A)
b = std(A)
e = errorbar(a,b)
%         a = [];b=[];
%         for i=1:16
%             a = [a;g(i,i)];
% %             b=[b;B(i,i)];
%         end
% %     
% %         subplot(2,3,sss);
% %         bar(1:size(a,1),a);hold on
% %     %     errorbar(1:size(a,1),a,b,'.')
% %         set(gca,'ylim',[-2 3.5]);
% %         set(gca,'xlim',[0 17]);
% %         title(num2str(sss));
%         xlabel('Speaker GMM Model');
%         ylabel('mean LLR Score of the test speech');
end

legend(['Pre: EER = ' num2str(EER(1)) '%'],['Duet1: EER = ' num2str(EER(2)) '%'],['Duet2: EER = ' num2str(EER(3)) '%'],...
    ['Duet3: EER = ' num2str(EER(4)) '%'],['Duet4: EER = ' num2str(EER(5)) '%'],['Post: EER = ' num2str(EER(6)) '%']);











