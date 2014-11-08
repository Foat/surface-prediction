function dist = consist_measure(lines,vp)
%CONSIST_MEASURE computes cosistency measure for each line and for each vp
% lines - Nx4 array [x1 y1 x2 y2]
% vp - Mx2 matrix
% returns NxM matrix
sl=size(lines);
s=size(vp);
dist=zeros([sl(1) s(1)]);

p1=lines(:,1:2);
p2=lines(:,3:4);
m=(p1+p2)/2;

for i=1:s(1)
    vec = projPointOnLine(p1,createLine(m,vp(i,:))) - p1;
    dist(:,i)=sqrt(sum(vec.^2, 2));
end

end

