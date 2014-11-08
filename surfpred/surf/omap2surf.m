function [X,Y,Z,planes] = omap2surf(omap,vp,f,gc)
% approximates planes from omap and extracts lines from them
% omap - 3 layered orientation map
% vp - 3 vanishing points
% f - focal length
s = size(omap);
s = s(1:2);
z = f;
% principal point
fp = [s(2)/2, s(1)/2];
outb = zeros(size(omap));
lb = zeros(s);
% for each layer
for i=1:3
    b = omap(:,:,i);
    labeled = bwlabel(b);
    num = max(labeled(:));
    
    % for each labeled component
    for j=1:num
        [row,col] = find(labeled == j);
        c = bwtraceboundary(labeled, [row(1) col(1)], 'N');
        for k=1:length(c)
            outb(c(k,1),c(k,2),i) = j;
        end
    end
    lb(:,:,i)=labeled;
end
coords = zeros(size(omap));

planes=findplanenear(outb);

perim=[planes.perim];
amt=[planes.namt];
comp=perim.*amt;
[~,poscomp]=sort(comp,'descend');

function process(planeid,CO2)
currp=planes(planeid);    
computed=[];
computedC=[];

nn=length(currp.nidx);
iter=0;
for l=1:nn
    res=currp.npts(l,:);
    if ~any(coords(res(2),res(1),:))
        ni=currp.nidx(l);
        nl=planes(ni).layer;
        nidx=planes(ni).idx;
        pb = [res - fp, z];
        cl = -1 / sum(CO2.*pb);
        [ncoords,C]=compute_coords(nl,nidx,cl,res,vp,[fp z],outb,lb,coords);
        iter=iter+1;
        computed(iter)=ni;
        computedC(iter,:)=C;
        coords=ncoords;
    end
end
% disp(planes(planeid))
% disp(poscomp)
% disp(computed)
if ~isempty(computed)
[~,~,ib] = intersect(poscomp,computed,'stable');
computed=computed(ib);
computedC=computedC(ib,:);
for l=1:length(computed)
    if computed(l)~=planeid
        process(computed(l),computedC(l,:));
    end
end
end
end

mx=planes(poscomp(1));
[rb,cb] = find(outb(:,:,mx.layer) == mx.idx);

[ncoords,C2]=compute_coords(mx.layer,mx.idx,-1,[cb(1) rb(1)],vp,[fp z],outb,lb,coords);
coords=coords+ncoords;
process(poscomp(1),C2);


rot=-40/180*pi;

Xb = coords(:,:,1);
Yb = coords(:,:,2);
Zb = coords(:,:,3);

X=Xb*cos(rot)-Zb*sin(rot);
Zb=Zb*cos(rot)+Xb*sin(rot);

rot2=90/180*pi;
Y=Yb*cos(rot2)-Zb*sin(rot2);
Z=Zb*cos(rot2)+Yb*sin(rot2);

rot3=10/180*pi;
Xb=X;
Yb=Y;
X=Xb*cos(rot3)-Yb*sin(rot3);
Y=Yb*cos(rot3)+Xb*sin(rot3);

pos = ~X.*~Y.*~Z == 1;

X(pos) = NaN;
Y(pos) = NaN;
Z(pos) = NaN;

% rm sky
if ~isempty(gc)
pos=gc(:,:,7)>0.5;
X(pos) = NaN;
Y(pos) = NaN;
Z(pos) = NaN;
end

end

function [coords,CO2] = compute_coords(layer,idx,scale,p,vp,f,bound,pane,coords)
% layer - id of layer (1-3)
% idx - plane id from lb
% s - scale for point
% p - start point
% fprintf('[%d,%d], scale = %d, p = [%d,%d]\n',...
%     layer,idx,scale,p(1),p(2));
fp=f(1:2);
z=f(3);
ql = 1:3;
ql = ql(ql~=layer);

% start point
point = [p - fp, z] * scale;

%% plane coefficients
vc = zeros(2,2);
iter = 1;
for l = ql
    vc(iter,:) = vp{l} - fp;
    iter = iter + 1;
end
A1 = (vc(1,2) - vc(2,2)) * z;
B1 = -(vc(1,1) - vc(2,1)) * z;
C1 = vc(1,1) * vc(2,2) - vc(1,2) * vc(2,1);

CO1 = [A1 B1 C1];
coef = -1 / sum(CO1.*point);
CO2 = CO1 * coef;

%% find all coordinates for all points on the plane
[rowp,colp] = find(pane(:,:,layer) == idx);

for l=1:length(rowp)
    pb = [[colp(l) rowp(l)] - fp, z];
    cl = -1 / sum(CO2.*pb);
    coords(rowp(l),colp(l),:) = cl.*pb;
end

%% compute for boundaries
[rowp,colp] = find(bound(:,:,layer) == idx);
for l=1:length(rowp)
    pb = [[colp(l) rowp(l)] - fp, z];
    cl = -1 / sum(CO2.*pb);
    coords(rowp(l),colp(l),:) = cl.*pb;
end
coords(p(2),p(1),:) = point;

% fprintf('computed [%d,%d], size = %d\n', ql(1), ql(2), length(rowp));
end

