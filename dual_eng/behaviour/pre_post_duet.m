load([project.paths.processedData '/GMM_configs/GMM_scores_' num2str(project.gmmUBM.gmmcomp) '_10_mwv_mfc.mat']);

load([project.paths.processedData '/processed_data_word_level.mat'],'D','W');
load('SPIC_text.mat', 'keywords')
gmmScores = sum(gmmScores,2);

Duet = nan(40,16,5);
PRE = nan(40,16,5);
POST = nan(40,16,5);

i=1;aa=[];
for sub = 1:16
    PreSpeech = W(i:i+39,1);
    PreSpeech(find(cellfun('isempty',PreSpeech))) = [];
    
    % PRE
    B = intersect(keywords,PreSpeech);
    a = find(ismember(keywords,B));
    index =  i:i+39;
    
    PRE(a,sub,1) = gmmScores(index(a));
    PRE(a,sub,2) = D(index(a),4);
    PRE(a,sub,3) = D(index(a),5);
    PRE(a,sub,4) = D(index(a),6);
    PRE(a,sub,5) = D(index(a),10);
    
    
    % DUET
    i = i+40;
    duet = W(i:i+199,1);
    index =  i:i+199;
    a = find(cellfun('isempty',duet));
    duet(a) = [];    index(a) = [];
    
    B = intersect(keywords,PreSpeech);
    B = intersect(B,duet);
    
    a = find(ismember(duet,B));
    b = find(ismember(keywords,B));
    
    Duet(b,sub,1) = gmmScores(index(a));
    Duet(b,sub,2) = D(index(a),4);
    Duet(b,sub,3) = D(index(a),5);
    Duet(b,sub,4) = D(index(a),6);
    Duet(b,sub,5) = D(index(a),10);
    
    
    % POST
    i=i+199;

    PostSpeech = W(i:i+39,1);
    PostSpeech(find(cellfun('isempty',PostSpeech))) = [];
    
    B = intersect(keywords,PostSpeech);
    a = find(ismember(keywords,B));    
    index =  i:i+39;
    
    POST(a,sub,1) = gmmScores(index(a));
    POST(a,sub,2) = D(index(a),4);
    POST(a,sub,3) = D(index(a),5);
    POST(a,sub,4) = D(index(a),6);
    POST(a,sub,5) = D(index(a),10);
    
    
    aa=[aa;b sub*ones(length(b),1)];
    i=i+41;
end

A = [];
for i=1:5
    B = [];C=[];
    for sub = 1:16
        B = [B;mean(PRE(:,sub,i)) mean(Duet(:,sub,i)) mean(POST(:,sub,i))];
        C = [C;std(PRE(:,sub,i)) std(Duet(:,sub,i)) std(POST(:,sub,i))];
        
    end
    A{i,1} = B;
    A{i,2} = C;
    
end
B = [];
for i=1:5
    C=[];
    A = [];
    for sub = 1:16
%         A = [A;PRE(:,sub,i)];
%         C = [C;POST(:,sub,i)];
        [a,b] = ttest2(PRE(:,sub,i),POST(:,sub,i));
        C = [C;a b];        
    end
%     [a,b] = ttest2(A,C);

    B = [B C];
end
sub=6;i=3;
a = PRE(:,sub,i);
b = POST(:,sub,i);
figure;ksdensity(a);hold on;ksdensity(b);

a = A{2, 1}'
b = A{2, 2}'
e = errorbar(a,b)
e.Marker = 's';
e.MarkerSize = 4;
e.MarkerFaceColor= 'k'
e.Color = 'k';
xlabel(gca,'Session No')
ylabel(gca,'LLR Score Difference')
set(gca,'XTick',[1:4])
title('Session average LLR score difference of all pairs')





figure;ksdensity(A);hold on;ksdensity(C);





