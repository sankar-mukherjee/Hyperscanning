function  [comp_r] = clicksubplot(H)
comp_r=[];
while 1 == 1
    w = waitforbuttonpress;
    switch w
        case 1 % keyboard
            key = get(gcf,'currentcharacter');
            if key==27 % (the Esc key)
                try; delete(h); end
                break
            end
        case 0 % mouse click
            mousept = get(gca,'currentPoint');
            x = mousept(1,1);
            y = mousept(1,2);
            
            
            if(strcmp(get(gca,'tag'),'XXX'))
                disp(get(gca,'tag'))
                break;
            elseif not(isempty(get(gca,'tag')))
                disp(get(gca,'tag'))
                comp_r = [comp_r str2num(get(gca,'tag'))];
                
                h = findobj('Tag',get(gca,'tag'));
                if(sum(h.XAxis.Color)==1)
                    h.XAxis.Color = 'k';
                    a = find(ismember(comp_r,str2num(get(gca,'tag'))));
                    comp_r(a) = [];
                else
                    h.XAxis.Color = 'r';
                end
            elseif(isempty(get(gca,'tag')))
                disp('cccc')
                
            end
    end
    disp('Rejected Components');
    disp(comp_r);

end
close(H);

end