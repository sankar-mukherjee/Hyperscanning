function [subA, subB, lead] = manage_sequence(a,b,position,session)


%% construct sequence
x = 1:50;
j=1;
z = zeros(99,2);
for i=1:2:99
    z(i,1) = x(j);
    z(i,2) = x(j);
    
    if(i ~=99)
        z(i+1,1) = x(j);
        z(i+1,2) = x(j+1);
    end
    j=j+1;
end

lead = zeros(1,99)+2;
%% arrange word pair combination per session
if(position == 3)
    subA = a(z(:,1));
    subB = b(z(:,2));
    lead(1:2:end) = 1;
elseif(position == 4)
    subA = a(z(:,2));
    subB = b(z(:,1));
    lead(2:2:end) = 1;
else
    if(position == 1 && (session == 2 || session == 3))
        subA = a(z(:,1));
        subB = b(z(:,2));
        lead(2:2:end) = 1;
    elseif(position == 1 && (session == 4 || session == 5))
        subA = a(z(:,2));
        subB = b(z(:,1));
        lead(1:2:end) = 1;
    elseif(position == 2 && (session == 2 || session == 3))
        subA = a(z(:,2));
        subB = b(z(:,1));
        lead(1:2:end) = 1;
    elseif(position == 2 && (session == 4 || session == 5))
        subA = a(z(:,1));
        subB = b(z(:,2));
        lead(2:2:end) = 1;
    end
    
end
end