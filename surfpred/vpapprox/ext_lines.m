function lines = ext_lines(lines,c,s,type)
%EXT_LINES extends line to boundaries
% figure; imshow(pane);
% hold on
for i=1:length(lines)
    bl=lines(i);
    if bl.lineclass~=type
        continue
    end
    vec = projPointOnLine([1 1],createLine(bl.point1,bl.point2)) - [1 1];
    [t,r] = cart2pol(vec(1),vec(2));
    offset=50;
    l = line_box(1-offset, s(2)+offset, 1-offset, s(1)+offset, r, t);
    if ~isempty(l)
        typeline = line_type(bl,c);
        point1 = l(1:2)';
        point2 = l(3:4)';
        cond=norm(point1-bl.point2)>norm(point2-bl.point2);
        in = inpolygon(bl.point2(1),bl.point2(2),[1-offset, s(2)+offset],[1-offset, s(1)+offset]);
        repl=~in;
        if typeline==1
            if cond
                bl.point1=point1;
                if repl
                    bl.point2=point2;
                end
            else
                bl.point1=point2;
                if repl
                    bl.point2=point1;
                end
            end
        elseif typeline==3
            if cond
                bl.point2=point1;
            else
                bl.point2=point2;
            end
        elseif typeline==2
            if repl
                bl.point2=point2;
                if cond
                    bl.point2=point2; 
                else
                    bl.point2=point1;
                end
            end
        end
        bl.length = norm(bl.point1 - bl.point2);
        bl.type=typeline;
        lines(i) = bl;
    else 
        fprintf('empty %d, %d, %d, %d\n',bl.point1(1),bl.point1(2),...
            bl.point2(1),bl.point2(2));
    end
end
% hold off
end

function typeout = line_type(line,c)
% 3 cases
% in == 1 - both     1
% == 1 0000 - to vp  2
% 1 1010 - reverse   3
x1=[line.point1(1) line.point2(1) line.point1(1)];
y1=[line.point1(2) line.point2(2) line.point1(2)];

x2=c(:,2);
y2=c(:,1);
poly(:,1)=x2;
poly(:,2)=y2;
p=intersectLinePolygon(createLine(line.point1,line.point2),poly);
p=unique(round(p),'rows');
lp=size(p);
in=zeros(lp(1),1);
for i=1:lp(1)
    buf=between(p(i,1),line.point1(1),line.point2(1)) &...
        between(p(i,2),line.point1(2),line.point2(2));
    in(i)=buf;
end
s=sum(in);
l=length(in);
if s==1
    if l==1
        typeout=1;
    else
        typeout=2;
    end
else
    if s>0
        typeout=3;
    else
        % error?
%         typeout=0;
        typeout=2;
%         fprintf('err\n');
%         plot(x1,y1,'c',x2,y2,'b',p(:,1),p(:,2),'ro');
%         pause;
    end
end
% disp(typeout)
% plot(x1,y1,'c',x2,y2,'b',p(:,1),p(:,2),'ro');
% pause;
end



