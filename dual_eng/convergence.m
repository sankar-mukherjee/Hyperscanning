%% compute the convergence
% [Investigating automatic measurements of prosodic accommodation and its dynamics in social interaction]

load([project.paths.processedData '/processed_data_word_level.mat']);

filelist = dir([project.paths.processedData '/GMM_configs/GMM_scores_' num2str(project.gmmUBM.gmmcomp) '_10_mwv_mfc.mat']);
for ff=1:length(filelist)
    AAAA = strrep([project.paths.processedData '/GMM_configs/' filelist(ff).name],[project.paths.processedData '/GMM_configs/GMM_scores'],[project.paths.processedData '/convergence/convergence']);
%     if ~exist(AAAA)        
        gmm = load([project.paths.processedData '/GMM_configs/' filelist(ff).name]);
        file_name222 = strrep([project.paths.processedData '/GMM_configs/' filelist(ff).name],[project.paths.processedData '/GMM_configs/GMM_scores'],'');
        file_name222 = strrep(file_name222,'.mat','');

        %% normalize featrues according to gender
        % D_norm = gender_normalization(D,project.synchrony.feature_idx,project);
        
        %% plot session by session feature by feature convergence, divergence
        
        orginal_conversation = [];word_pair_position=[];
        fake_conversaion = [];
        for g=1:length(project.subjects.group)
            
            sub = project.subjects.group_no(g,1);
            partner = project.subjects.group_no(g,2);
            
            
            for session = 2:5
                [subA, subB, idxA, idxB, pos] = get_conv(D,sub,partner,session,session,g,gmm.gmmScores,project.subjects.data(sub).position);
                orginal_conversation{g,session-1} = [subA' subB'];
                word_pair_position{g,session-1,1} = pos;
                word_pair_position{g,session-1,2} = idxA;
                word_pair_position{g,session-1,3} = idxB;
            end
            fake_group_combination = generate_fakeduets([sub partner],1,project);
            
            temp = [];
            for fake = 1:length(fake_group_combination)
                fake_scores = get_fake_conv(D,fake_group_combination(fake,1),fake_group_combination(fake,2),fake,gmm.gmmScores_other{g},project);
                temp = [temp; fake_scores];
            end
            fake_conversaion{g,1} = temp;
            % % % % % % % %
            % % % % % % % %     %      for session = 2:5
            % % % % % % % %     %         temp = get_conv(orginal_conversation,sub,partner,session,g,project,gmm);
            % % % % % % % %     %         orginal_conversation = get_fake_conv(temp,sub,partner,other,session,g,gmm);
            % % % % % % % %     %     end
            % % % % % % % %
            % % % % % % % %     %     for session = 1:6
            % % % % % % % %     %         orginal_conversation = get_conv(orginal_conversation,sub,partner,session,g,project,gmm);
            % % % % % % % % %         if(session ~= 1 && session ~= 6)
            % % % % % % % % %             orginal_conversation = get_fake_conv(orginal_conversation,sub,partner,other,session,g,gmm);
            % % % % % % % % %         end
            % % % % % % % % %     end
            % % % % % % % %
            % % % % % % % %
            % % % % % % % %     % plot
            % % % % % % % % %     plot_session_convergence(orginal_conversation,g,project);
            % % % % % % % % %     orginal_conversation = plot_session_convergence_bar(orginal_conversation,g,project);
            % % % % % % % % %
            
            %     %% plot original vs fake conversation to check if convergence is meaningful
            %     plot_session_check_convergence_meaningful(orginal_conversation(g,:),fake_conversaion(g,1),g,project);
            
            disp(project.subjects.group{g});
            
            
        end
        
%         save([project.paths.processedData '/convergence/original_fake_convergence' file_name222 '.mat'],'orginal_conversation','fake_conversaion');
%         save([project.paths.processedData '/convergence/word_pair_position' file_name222 '.mat'],'word_pair_position');
        
        
        
        %% find convergence word pair points
        
        % project.paths.figures = 'C:/Users/SMukherjee/Desktop/data/figures/convergence';
        
        %% merge into only event distribution
        ALL=[];
        for g=1:length(project.subjects.group)
            
            % fake
            fake_event_dist_diff = fake_conversaion{g,1};
            temp =[];
            for i=1:size(fake_event_dist_diff,1)
                temp = [temp; fake_event_dist_diff(i,1:2);fake_event_dist_diff(i,3:4)];
            end
            fake_event_dist_diff = cell2mat(temp);
            
            
            % original
            temp = orginal_conversation(g,:);
            orginal_event_dist_diff = cell(1,4);
            for i=1:length(orginal_event_dist_diff)
                orginal_event_dist_diff{i} = abs(temp{1,i}(:,1) - temp{1,i}(:,2))';
            end
            
            
            orginal_event_dist = orginal_conversation(g,:);
            
            for session= 1:4
                session_data = orginal_event_dist{session};
                [convergence_score,divergence,convergence_A,convergence_B,rare_event] = convergence_condition2(session_data(:,1),session_data(:,2),fake_event_dist_diff,D,gmm.gmmScores(:,g),...
                    session,project,g,project.convergence.use_both_cond);
                ALL{g,session,1} = convergence_score';
                ALL{g,session,2} = divergence';
                ALL{g,session,3} = convergence_A';
                ALL{g,session,4} = convergence_B';
                ALL{g,session,5} = rare_event';
            end
        end
        GMM_conv.convergence = cell2mat(ALL(:,:,1));
        GMM_conv.divergence = cell2mat(ALL(:,:,2));
        GMM_conv.convergence_A = cell2mat(ALL(:,:,3));
        GMM_conv.convergence_B = cell2mat(ALL(:,:,4));
        GMM_conv.rare_event = cell2mat(ALL(:,:,5));
        save([project.paths.processedData '/convergence/GMM_speech_conv_spy' file_name222 '.mat'],'GMM_conv');
        
        %%
        % show=1;
        % b = [51 102 153 204];
        % a=0;
        % for i=1:4
        % a = a+(cell2mat(ALL(:,:,i))*b(i));
        % end
        % % a= cell2mat(ALL(:,:,show));
        
        A = GMM_conv.convergence_A;
        b  = find(A);
        A(b) = 2;
        a = GMM_conv.convergence + A;
        A = GMM_conv.convergence_B;
        b  = find(A);
        A(b) = 3;
        a = a + A;
        A = GMM_conv.divergence;
        b  = find(A);
        A(b) = 4;
        a = a + A;
        a = a .* GMM_conv.rare_event;

        % ALL
        a = GMM_conv.convergence + NaN*GMM_conv.convergence_A + NaN*GMM_conv.convergence_B + NaN*GMM_conv.divergence;
        a = a .* GMM_conv.rare_event;
        
        % convergence
        a = GMM_conv.convergence .* GMM_conv.rare_event;
        
        a = [a;zeros(1,396)];
        
        FigHandle1 = figure('Position', [100, 100, 800, 700]);
        pcolor(a);
        imagesc(flipud(a))
        hold on;
        plot( [99 99],get(gca,'ylim'),'k','LineWidth',5)
        plot( [198 198],get(gca,'ylim'),'k','LineWidth',5)
        plot( [297 297],get(gca,'ylim'),'k','LineWidth',5)
        set(get(gca,'YLabel'),'String','Groups');
        set(get(gca,'XLabel'),'String','Duet (Word Pairs)')
        set(gca,'YTick',[1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5]);
        set(gca,'YTickLabel',[fliplr(project.subjects.group)]);
        set(gca,'XTick',[1 50 100 150 200 250 300 350 396]);
        set(gca,'XTickLabel',{'0','Session 1','100','Session 2','200','Session 3','300','Session 4','396'});
        
        h1 = area(NaN,NaN,'Facecolor','b');
        h2 = area(NaN,NaN,'Facecolor','r');
        h3 = area(NaN,NaN,'Facecolor','g');
        h4 = area(NaN,NaN,'Facecolor','w');
        h5 = area(NaN,NaN,'Facecolor','w');
        
        hL = legend([h1 h2 h3 h4 h5],{'Convergence','convergence A', 'convergence B', 'NoChange'},'Orientation','horizontal','FontSize',12);
%         hL = legend([h2 h3],{'Convergence', 'No change'},'Orientation','horizontal','FontSize',9);
        set(hL,'Position', [0.5 0.025 0.005 0.0009]);
        title('Whole Duet Task');
        
        saveas(FigHandle1,[project.paths.figures '/convergence_points' file_name222 '.fig']);
        saveas(FigHandle1,[project.paths.figures '/convergence_points' file_name222 '.tif']);
        
        %% an example pair
        group = 5;session=2;diff_flag=0;
        plot_session_convergence(D,orginal_conversation,gmm.gmmScores(:,group),ALL,group,session,project,diff_flag);
        
        
        %%
        
        [event event_idx event_common_idx] = get_event_wordPair();
        
        temp =[];
        for i=1:size(ALL,1)
            temp = [temp; ALL(i,1:2);ALL(i,3:4)];
        end
        
        a = cell2mat(temp);
        b = sum(a);
        idx = find(b > 0);
        words = event(idx,:);
        
        %%
        convergence_data = convert2originalDataStruct(ALL,D,project,file_name222);
        
        %% get gmm score diff
        convergence_score_diff = zeros(size(D,1),2);
        gmmScores = sum(gmm.gmmScores,2);
        for sub=1:length(project.subjects.list)
            temp = find(D(:,1)== sub &  D(:,2) == 1);
            Score = gmmScores(temp);
            % compute the upper and lower of the pretest distribution
            UP = nanmean(Score)+project.convergence.fakestd*nanstd(Score);
            LW = nanmean(Score)-project.convergence.fakestd*nanstd(Score);
            %
            for session= 2:5
                idx = find(D(:,1)== sub &  D(:,2) == session);
                session_data = gmmScores(idx);
                if (mod(sub,2))
                    convergence_score_diff(idx,1) = LW - session_data;
                    convergence_score_diff(idx,2) = UP - session_data;
                else
                    convergence_score_diff(idx,1) = session_data - UP;
                    convergence_score_diff(idx,2) = session_data - LW;
                end
            end
        end
        
        save([project.paths.processedData '/convergence/convergence' file_name222 '.mat'],'convergence_data', 'convergence_score_diff');
        close all;
%     end
end
















