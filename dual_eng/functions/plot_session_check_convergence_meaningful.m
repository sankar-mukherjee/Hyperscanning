function f = plot_session_check_convergence_meaningful(original,fake,g,project)


original_data = original;
fake_data = fake{1,1};

FigHandle1 = figure('Position', [100, 100, 600, 500]);

for session = 1: length(original_data)
    
    original_session_data = original_data{1,session};
    fake_session_data = cell2mat(fake_data(:,session));
    
    %% check distribution of each word pair
%     for i=1:99
%     ksdensity(fake_session_data(:,i));hold on;
%     end
    

%%
    A = abs(original_session_data(:,1)-original_session_data(:,2));
    
    fake_session_data(isnan(fake_session_data))=0;
    fake_score = mean(fake_session_data);
%     
%     i=2
% %     f = reflet_inverse_transfrom(fake_session_data(:,i));
%     r= zeros(99,4);
%     for i=1:99
%         if(~isnan(A(i)))
% %             [p,h,stats] = ranksum(A(i),fake_session_data(:,i));
% %             r(i,:) = [p h stats.zval stats.ranksum];
%             [p,h,stats,cv] =  kstest(fake_session_data(:,i));
%             r(i,:) = [p h stats cv];
%         end
%     end
% %     [p,h,stats] = signrank(fake_session_data(:,i))
% % ztest(x,m,sigma)
% 
%     f = log(fake_session_data(:,i));
% h = kstest(fake_session_data(:,i))
    %% plot
    h(session) = subplot(4,1,session);
    plot(fake_score,'.-g');
    hold on;
    plot(A,'.-b');    
    
    set(get(gca,'YLabel'),'String',project.session.list{session+1})
    %         title(project.session.list{session+1});    
    
    %% Mann-Whitney U test (here Wilcoxon rank sum test) between origianl and fake conversation means
    pA = ranksum(A,fake_score);    
    
    title([project.session.list{session+1} 'Wilcoxon rank sum test with p = ' num2str(pA)]);
end
linkaxes(h,'xy');
annotation('textbox', [0 0.9 1 0.1], ...
    'String', ['Group ' project.subjects.group{g} ' with Wilcoxon rank sum test'], ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
legend('Fake','Original');

set(get(gca,'XLabel'),'String','Word No')
saveas(FigHandle1,[project.paths.figures '\original_VS_fake_' [project.subjects.group{g}] '.fig']);
saveas(FigHandle1,[project.paths.figures '\original_VS_fake_' [project.subjects.group{g}] '.tif']);
close all;
end
