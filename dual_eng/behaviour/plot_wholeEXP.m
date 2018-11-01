
%% plot whole exp
A = zeros(length(Oindex_comb),1);

index = get_condition_index2(convergence_data,'convergence');
A(index) = 4;
index = get_condition_index2(convergence_data,'convergence_A');
A(index) = 3;
index = get_condition_index2(convergence_data,'convergence_B');
A(index) = 2;
index = get_condition_index2(convergence_data,'divergence');
A(index) = 1;
index = get_condition_index2(convergence_data,'noch');
A(index) = 0;

A = reshape(A,396,8)';        A = [A;zeros(1,396)];

figure;pcolor(A)
hold on;colormap(jet);
plot( [99 99],get(gca,'ylim'),'k','LineWidth',5)
plot( [198 198],get(gca,'ylim'),'k','LineWidth',5)
plot( [297 297],get(gca,'ylim'),'k','LineWidth',5)
set(get(gca,'YLabel'),'String','Groups');
set(get(gca,'XLabel'),'String','Duet (Word Pairs)')
set(gca,'YTick',[1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5]);
set(gca,'YTickLabel',[(project.subjects.group)]);
set(gca,'XTick',[1 50 100 150 200 250 300 350 396]);
set(gca,'XTickLabel',{'0','Session 1','100','Session 2','200','Session 3','300','Session 4','396'});
h1 = area(NaN,NaN,'Facecolor','r');
h2 = area(NaN,NaN,'Facecolor','y');
h3 = area(NaN,NaN,'Facecolor','g');
h4 = area(NaN,NaN,'Facecolor','w');
h5 = area(NaN,NaN,'Facecolor','b');

hL = legend([h1 h2 h3 h4 h5],{'Convergence','Convergence A', 'Convergence B', 'NoChange','Divergence'},'Orientation','horizontal','FontSize',12);
%         hL = legend([h2 h3],{'Convergence', 'No change'},'Orientation','horizontal','FontSize',9);
set(hL,'Position', [0.5 0.025 0.005 0.0009]);
title('Whole Duet Task');


%% plot all gmm scores in whle exp

i=1;
for g=1:8
    A = Oindex_comb(i:i+395,1:2);
    A = [gmmScores(A(:,1)) gmmScores(A(:,2))];
%     subplot(8,1,g)
figure;
    plot(A);hold on;
    plot( get(gca,'xlim'),[TH(g,1) TH(g,1)],'--k','LineWidth',0.1)
    plot( get(gca,'xlim'),[TH(g,2) TH(g,2)],'--k','LineWidth',0.1)
    plot( get(gca,'xlim'),[TH(g,3) TH(g,3)],'--k','LineWidth',0.1)
    plot( get(gca,'xlim'),[TH(g,4) TH(g,4)],'--k','LineWidth',0.1)
    
    plot( [99 99],get(gca,'ylim'),'k','LineWidth',1)
    plot( [198 198],get(gca,'ylim'),'k','LineWidth',1)
    plot( [297 297],get(gca,'ylim'),'k','LineWidth',1)
    set(gca,'ylim',[-5 5]);
title(num2str(g))
    i=i+396;
end





