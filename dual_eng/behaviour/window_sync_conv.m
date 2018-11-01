
window=[2:40];

for w=1:length(window)
    win=window(w);
        [fA,t,w]=enframe(a,win,1);

    corealtion = [];corealtion_std = [];
    for sub=1:2:16
        i = index_comb(find(index_comb(:,5)==sub),:);
        TEMP =[];
        
        for s=1:4
            A = i(find(i(:,4)==s),:);
            %
            j = [A(find(A(:,3)==1),:); A(find(A(:,3)==2),:)];
            
            [a,b] = corr(D(j(1:win,1),4), D(j(1:win,2),4));
            [c,d] = corr(D(j(1:win,1),5), D(j(1:win,2),5));
            [e,f] = corr(D(j(1:win,1),6), D(j(1:win,2),6));
            [g,h] = corr(D(j(1:win,1),10), D(j(1:win,2),10));
            [k,l] = corr(D(j(1:win,1),11), D(j(1:win,2),11));
            [ii,jj] = corr(D(j(1:win,1),14), D(j(1:win,2),14));
            
            LLR = mean([gmmScores(A(1:win,1)) - gmmScores(A(1:win,2))]);
            LLR1 = std([gmmScores(A(1:win,1)) - gmmScores(A(1:win,2))]);
            
            
            corealtion = [corealtion;   LLR a c e g k ii];
            corealtion_std = [corealtion_std; LLR1  b d f h l jj];
            
            
            %         j=A;
            %         for m=1:length(A)
            %             if(A(m,3)==2)
            %                 j(m,:) = [j(m,2) j(m,1) j(m,3:end)];
            %             end
            %         end
            %         a = D(j(:,1),4)-D(j(:,2),4);
            %         b = D(j(:,1),5)-D(j(:,2),5);
            %         c = D(j(:,1),6)-D(j(:,2),6);
            %         d = D(j(:,1),10)-D(j(:,2),10);
            %         e = D(j(:,1),14)-D(j(:,2),14);
            %
            %         temp = [ a b c d  gmmScores(A(:,1)) - gmmScores(A(:,2)) e];
            %         corealtion = [corealtion;  temp];
            
        end
    end
end




