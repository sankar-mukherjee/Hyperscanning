function fake_scores = get_fake_conv(D,sub,partner,fake_group_no,gmmScores,project)

fake = 0;


if(project.subjects.data(sub).position == 1 && project.subjects.data(partner).position == 1)
    fake = 1;    session_pos = [3;3; 4; 4];

elseif(project.subjects.data(sub).position == 2 && project.subjects.data(partner).position == 2)
    fake = 1; session_pos = [4;4; 3; 3];
else
    fake = 0;
end


temp =[];
if(fake)
    session_comb = [2 4;3 5; 4 2; 5 3];
    
    for session = 1:length(session_comb)
        [subA subB] = get_conv(D,sub,partner,session_comb(session,1),session_comb(session,2),fake_group_no,gmmScores,session_pos(session));
        temp{1,session} = abs(subA-subB);
    end
    
else
    
    for session = 2:5
        [subA subB] = get_conv(D,sub,partner,session,session,fake_group_no,gmmScores,project.subjects.data(sub).position);
        temp{1,session-1} = abs(subA-subB);
    end
    
end





fake_scores =  temp;





%
%
%
%
%
%
% other_idx = [];
% a = nan(50,length(other));
%
% for d=1:length(other)
%     temp = find(D(:,1)== other(d) &  D(:,2) == session);
%     word =  D(temp,3);
%     A  = gmm.gmmScores(temp,g);
%
%     for i=1:length(word)
%         a(word(i),d) = A(i);
%     end
% end
%
% other_scores  = a';
%
% %% output to same structure as D
% a(isnan(a))=0;
%
% % z_a = zeros(size(a));
% % for i=1:size(a,1)
% % %     z_a(i,:) = (a(i,:) - mean(a(i,:)))/std(a(i,:));
% %     z_a(i,:) = 1/((1+a(i)));
% %
% % end
% % std_a = std(a')';
% mean_a = mean(a,2);
% other_scores = D;
%
% temp = find(D(:,1)== sub &  D(:,2) == session);
% wordA =  D(temp,3);
% other_scores(temp,17) = mean_a(wordA);
%
% temp = find(D(:,1)== partner &  D(:,2) == session);
% wordA =  D(temp,3);
% other_scores(temp,17) = mean_a(wordA);


end