function [R,group]=plot_corr_btwcond(index_O,speech,listen,tf_speech,tf_listen,conv_idx,noCh_idx,conv,noch,config,gmmScores,D)



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% speech
index = [];pow=[];
speech.avgovertime = 'yes';
speech.avgoverfreq = 'yes';
speech.avgoverchan = 'yes';

for sub=1:16
    index{sub,1} = tf_speech{1,sub}.trialinfo(:,2);
    a = ft_selectdata(speech, tf_speech{1,sub});
    pow{sub,1} = a.powspctrm;
end
speech.index = index;
index = cell2mat(index);
pow = cell2mat(pow);
speech.pow = pow;
speech.indexFULL = index;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% listen
index = [];pow=[];
listen.avgovertime = 'yes';
listen.avgoverfreq = 'yes';
listen.avgoverchan = 'yes';

for sub=1:15
    index{sub,1} = tf_listen{1,sub}.trialinfo(:,2);
    a = ft_selectdata(listen, tf_listen{1,sub});
    pow{sub,1} = a.powspctrm;
end

listen.index = index;
listen.index = [listen.index(1:2,:) ;0; listen.index(3:end,:)];
index = cell2mat(index);
pow = cell2mat(pow);
listen.pow = pow;
listen.indexFULL = index;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
group = [];
j=1;g=1;
for sub=1:2:16
    %     if not(sub==3)
    s = cell2mat(index_O(j:j+3,:));
    
    a=s;
    % check for leader folower
    for i=1:length(a)
        if(s(i,3)==2)
            a(i,:)=[s(i,2) s(i,1) s(i,3)];
        end
    end
    s=a;
    
    if(strcmp(config,'PreSpeech-PostListen'))
        A = [];
        for i=1:99:396
            a = s(i:i+98,:);
            a = a(1:2:end,:);
            % individual subject for avg afterwords
            a=kron(a,ones(2,1));
            a(2:2:end,1:2) = fliplr(a(1:2:end,1:2));
                            a = a(1:2:end,:);
            A = [A;a];
        end
        s=A;
    elseif(strcmp(config,'PreSpeech-PreSpeech'))
        A = [];
        for i=1:99:396
            a = s(i:i+98,:);
            a = a(1:2:end,:);
            A = [A;a];
        end
        s=A;
    elseif(strcmp(config,'PostListen-PostListen'))
        A = [];
        for i=1:99:396
            a = s(i:i+98,:);
            a = a(1:2:end,:);
            
            A = [A;a(:,2) a(:,1)];
        end
        s=A;
    end
    
    s(any(isnan(s), 2), :) = [];
    
    % conv noch
    if(conv)
        a = s(find(ismember(s(:,1),conv_idx)),:);
        s=a;
    elseif(noch)
        a = s(find(ismember(s(:,1),noCh_idx)),:);
        s=a;
    end
    
    %% condition combination
    if(strcmp(config,'PreSpeech-PreSpeech'))
        a = [speech.index{sub,1}; speech.index{sub+1,1}];
        A = ismember(s(:,1),a);
        b = [speech.index{sub,1}; speech.index{sub+1,1}];
        B = ismember(s(:,2),b);
        A = find(A.*B);        
        s = s(A,:);    
        
        a = find(ismember(speech.indexFULL,s(:,1)));
        b = find(ismember(speech.indexFULL,s(:,2)));
        %                         group{g,1}=[speech.pow(a) speech.pow(b)  (gmmScores(s(:,1))) (gmmScores(s(:,2)))];
        
        %             S = D(s(:,1),1);
        
        %             if (mod(S(1),2))
        score_diff = abs(gmmScores(s(:,1),1)- gmmScores(s(:,2),2));
        %             else
        %                 score_diff = (abs(gmmScores(s(:,1)))- abs(gmmScores(s(:,2))));
        %             end
        s=nan(200,3);
        s= [speech.pow(a) speech.pow(b)  score_diff];
        group{g,1}=s;
        
        %                                     group{g,1}=[mean(speech.pow(a)) mean(speech.pow(b)) mean(score_diff)];
    elseif(strcmp(config,'PreSpeech-PostListen'))
        a = [speech.index{sub,1}; speech.index{sub+1,1}];
        A = ismember(s(:,1),a);
        b = [listen.index{sub,1}; listen.index{sub+1,1}];
        B = ismember(s(:,2),b);
        A = find(A.*B);
        s = s(A,:);
        
        a = find(ismember(speech.indexFULL,s(:,1)));
        b = find(ismember(listen.indexFULL,s(:,2)));
         score_diff = abs(gmmScores(s(:,1),1)- gmmScores(s(:,2),2));
                    group{g,1}=[speech.pow(a) listen.pow(b) score_diff];
%         group{g,1}=[mean(speech.pow(a)) mean(listen.pow(b))];
        
    elseif(strcmp(config,'PostListen-PostListen'))
        a = [listen.index{sub,1}; listen.index{sub+1,1}];
        A = ismember(s(:,1),a);
        b = [listen.index{sub,1}; listen.index{sub+1,1}];
        B = ismember(s(:,2),b);
        A = find(A.*B);
        s = s(A,:);
        
        a = find(ismember(listen.indexFULL,s(:,1)));
        b = find(ismember(listen.indexFULL,s(:,2)));
        
        score_diff = abs(gmmScores(s(:,1),1)- gmmScores(s(:,2),2));
        s=nan(200,3);
         s(A,:)= [listen.pow(a) listen.pow(b)  score_diff];
        group{g,1}=s;
        %         group{g,1}=[mean(listen.pow(a)) mean(listen.pow(b))];
    else
        
    end
    
    %     end
    j=j+4;g=g+1;
end



%% plot
B =[];R=[];
for g=1:8
    A = group{g,1};
    if not(A==0)
        [r,p]=corr(A(:,1),A(:,2), 'rows','pairwise');
        a = zeros(size(A,1),1) + g;
        B = [B; [A a]];
        R = [R;r p g];
    end
end

% B(any(isnan(B), 2), :) = [];
% B(:,1)=log(B(:,1));
% B(:,2)=log(B(:,2));


gscatter(B(:,1),B(:,2),B(:,3));
xlabel('PreSpeech')
ylabel('PostListen')
end