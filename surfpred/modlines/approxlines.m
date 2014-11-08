function [lines,romap] = approxlines(omap,vp)
% approximates lines on orientation map & returns new omap

s=size(omap);
fomap=zeros(s);
kernel = strel('rectangle',[3 3]);
for i=1:3
    fomap(:,:,i) = imerode(omap(:,:,i), kernel);
end
vparr=zeros([3 2]);
for i=1:3
    vparr(i,:)=vp{i};
end

lines=fitlines(fomap,vparr);
lines=approxtilt(lines,vparr);


romap=omap;
s=s(1:2);
gomap=zeros(s);
for i=1:length(lines)
    bl=lines(i);
    p1=bl.point1;
    p2=bl.point2;
    ind=drawline([p1(2) p1(1)],[p2(2) p2(1)],s);
    gomap(ind)=1;
end

kernel = strel('rectangle',[5 5]);
gomap = imdilate(gomap, kernel);

for i=1:3
    buf=romap(:,:,i)&~gomap;
    buf=imerode(buf,kernel);
    buf=imdilate(buf,kernel);
    romap(:,:,i)=imdilate(buf,kernel);
end

% figure; imshow(oomap);
% figure; imshow(oomap(:,:,1));
% figure; imshow(oomap(:,:,2));
% figure; imshow(oomap(:,:,3));

% disp_vanish(zeros(size(omap)), lines, vp);
% 
% romap=zeros(size(omap));

end

