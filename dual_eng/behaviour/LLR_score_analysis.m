
A=[];
for i =1:8
   A = [A; TH(i,1)-TH(i,3) TH(i,2)-TH(i,1) abs(TH(i,4)-TH(i,3)) ...
       TH(i,5)-TH(i,7) TH(i,6)-TH(i,5) abs(TH(i,8)-TH(i,7))]; 
    
end

B = reshape(A,4,8);
B = sum(B);

A = [A B']