function rlines = approxtilt(lines,vparr)
% approximates lines tilt toward vp

l=length(lines);
rlines=lines;
for i=1:l
    bl=lines(i);
    p1=bl.point1;
    p2=bl.point2;
    m=(p1+p2)/2;
    vp=vparr(bl.lineclass,:);
    
    proj = projPointOnLine([p1;p2],createLine(m,vp));
    bl.point1=proj(1,:);
    bl.point2=proj(2,:);
    rlines(i)=bl;
end

end

