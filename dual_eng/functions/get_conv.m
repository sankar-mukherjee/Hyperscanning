function [subA,subB,idxA,idxB,pos] = get_conv(D,sub,partner,sessionA,sessionB,group_no,gmmScores,position)
%% get convergence score sessionwise using GMM LLR score as basis

sub_A = find(D(:,1)== sub &  D(:,2) == sessionA);
sub_B = find(D(:,1)== partner &  D(:,2) == sessionB);
A  = gmmScores(sub_A,group_no);
B  = gmmScores(sub_B,group_no);

wordA =  D(sub_A,3);
wordB =  D(sub_B,3);

a=nan(1,50);
b=nan(1,50);
%     a=zeros(1,50);
%     b=zeros(1,50);
%% for missng words due to mistake (miss pronunciation or etc)
for i=1:length(wordA)
    a(wordA(i)) = A(i);
end
for i=1:length(wordB)
    b(wordB(i)) = B(i);
end


%%
[subA,subB,pos] = manage_sequence(a,b,position,sessionA);


a=nan(1,50);
b=nan(1,50);
%     a=zeros(1,50);
%     b=zeros(1,50);
%% for missng words due to mistake (miss pronunciation or etc)
for i=1:length(wordA)
    a(wordA(i)) = sub_A(i);
end
for i=1:length(wordB)
    b(wordB(i)) = sub_B(i);
end
[idxA,idxB,pos] = manage_sequence(a,b,position,sessionA);

%% framing
% [fA,t,w]=enframe(a,project.convergence.winLength,project.convergence.winShift);
% [fB,t,w]=enframe(b,project.convergence.winLength,project.convergence.winShift);
% 
% fA(isnan(fA)) = 0;        
% fB(isnan(fB)) = 0;
% 
% 
% 
% ALL = [{fA} {fB}];


% ALL = [{a} {b}];

% %% output to same structure as D
% ALL = D;
% ALL(sub_A,16) = A;
% ALL(sub_B,16) = B;

end