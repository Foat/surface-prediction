function [X,Y,Z] = gensurflines(lines,vp,f,imgsize,start,img)
% computes surface for lines
% lines - tagged lines
% vp - 3 vanishing points (r,g,b) - (vertical, right, left)
% f - focal lenght
% imgsize - image size
% img - debug param
% important! assume that principal point located in the center of image

% height, width
s = imgsize(1:2);
% lines length
l = length(lines);
%                     |
% focal point - * --- * - principal point on image surface
%                     |
fp = [s(2)/2, s(1)/2];
z = f;

% vectors from f -> vp
vpv = zeros(3,2);
for i=1:3
    vpv(i,:) = vp{i} - fp;
end

% abstract param, can be any
scale = -1;
% max error between line points
err = 10;

% 2 points in 3d for each line
bufc = zeros(l, 2, 3);

figure;
imshow(img);
hold on;  

% local recursive function which computes coordinates for each connected line
function process(idx,s,isstart,rad)
% idx - index of curretn line
% s - scale for current line
% isstart - index for which we should use scale factor
% disp('start');
bl = lines(idx);
lc = bl.lineclass;
% disp(lc);
%% compute line coordinates, start/end vectors
if isstart 
    sv = bl.point1 - fp;
    ev = bl.point2 - fp;
else
    sv = bl.point2 - fp;
    ev = bl.point1 - fp;
end

% start, end points
sp = [sv z] * s;

% for collinear vectors
if lc ~= 1
    coef = (sp(1) * vpv(lc,2) - vpv(lc,1) * sp(2)) / (ev(1) * vpv(lc,2) - vpv(lc,1) * ev(2));
else 
    % todo : add vector computation for z
    coef = s;
end

ep = [ev z] * coef;

%% save x,y,z for 2 points
bufc(idx,1,:) = sp;
bufc(idx,2,:) = ep;

circle(sv + fp,rad);
circle(ev + fp,rad);

%% find nearest lines
for j=1:l
if (j ~= idx && ~bufc(j))
bnl = lines(j);
% check line class
if (bnl.lineclass >=1 && bnl.lineclass <= 3 && bnl.lineclass ~= lc)
    p1 = bnl.point1;
    p2 = bnl.point2;
    if getl(p1, ev + fp) < err
        process(j,coef,1,rad + 1);
    elseif getl(p2, ev + fp) < err
        process(j,coef,0,rad + 1);
    elseif getl(p1, sv + fp) < err
        process(j,s,1,rad + 1);
    elseif getl(p2, sv + fp) < err
        process(j,s,0,rad + 1);
    end
end 
end
end

end

process(start,scale,1,1);
hold off;
% plot each line
figure;
hold on;
for k=1:l
    b = reshape(bufc(k,:,:),2, []);
    if b
        plot3(b(:,1), b(:,2), b(:,3));
    end
end
hold off;

X = length(bufc(bufc ~= 0));
Y = bufc;
Z = 0;

end