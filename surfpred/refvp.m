function [vp,lines] = refvp(vp1,lines,imsize)
% 1 (red) - vertical vp (ground, floor, ceiling)
% 3 (blue) - hor vp, nearest to the principal point (left, right walls in indoor scenes)
% 2 (green) - hor vp, central wall on most indoor scenes

vpb=zeros([3 1]);
pb=zeros([2 1]);
vparr=zeros([3 2]);
for i=1:3
    vparr(i,:)=vp1{i};
end
% find vertical (max abs number by y)
[~,p]=max(abs(vparr(:,2)));
vpb(p)=1;
pb(1)=p;
vp{1}=vp1{p};
% find nearest to pp
pp=imsize(1:2)/2;
l=ones([3 1])*10000;
for i=1:3
    if i~=p
        l(i)=getl(vparr(i,:),pp/2);
    end
end
[~,p]=min(l);
vpb(p)=3;
pb(2)=p;
vp{3}=vp1{p};
% the last one will be for the central wall
p=setdiff(1:3,pb);
vpb(p)=2;
vp{2}=vp1{p};
% update lines&vp information
for i=1:length(lines)
    if (lines(i).lineclass~=0)
        lines(i).lineclass=vpb(lines(i).lineclass);
    end
end

end

