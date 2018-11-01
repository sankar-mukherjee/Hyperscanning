

load('gmm_ubm_32_crossvalidation.mat')

project.subjects.group_no = [1 2; 3 4; 5 6; 7 8; 9 10; 11 12; 13 14; 15 16];
project.subjects.gender = {'m','m','m','f','f','f','m','f'};



MM=[];
for i=1:16
    MM = [MM;g(i,i)];
    
    
end


MY=[];
for i=1:8
    a = project.subjects.group_no(i,:);
    
    MY = [MY;g(a(1),a(2));g(a(2),a(1))];
    
    
end

ME=[];MEM=[];MEF=[];
for i=1:8
    a = project.subjects.group_no(i,:);
    
    tt=[];
    b = find(ismember(1:16,a(:))==0);
    for j=1:length(b)
        tt = [tt;g(a(1),b(j))];
    end
    tt = mean(tt);
    ttt=[];
    for j=1:length(b)
        ttt = [ttt;g(a(2),b(j))];
    end
    ttt = mean(ttt);

    ME = [ME;tt;ttt];
    
    if(strcmp(project.subjects.gender{i},'m'))
        R = [1:6 13 14];
        
        b = find(ismember(R,a(:)));
        R(b)=[];
        for j=1:length(R)
            MEM = [MEM;g(a(1),R(j));g(a(2),R(j))];
        end
        
        
    else
        R = [7:12 15 16];
        
        
        b = find(ismember(R,a(:)));
        R(b)=[];
        for j=1:length(R)
            MEF = [MEF;g(a(1),R(j));g(a(2),R(j))];
        end
    end
    
    
    
end

% ME = [MEM; MEF];

A = [mean(MM) mean(MY) mean(ME)];
B = [std(MM) std(MY) std(ME)];

% errorbar(1:3,A,B)




[h,p1,ci,stats] = ttest2(MM,MY)
[h,p2,ci,stats] = ttest2(MM,ME)
[h,p3,ci,stats] = ttest2(MY,ME)

figure;
H=bar(A);
hold on;
errorbar(1:3,A,B,'color','k','linestyle','none');
set(H,'FaceColor',[0.5,0.5,0.5])
groups={[1,2],[1,3],[2,3]};

H=sigstar(groups(1:2),[p1,p2]);

Labels = {'Self-Self', 'Self-Partner', 'Self-Others'};
set(gca, 'XTick', 1:3, 'XTickLabel', Labels);
title('LLR score comparisons')
ylabel('Mean LLR Scores')
ylim([-1 1.3])

set(gca,'FontSize',14)







