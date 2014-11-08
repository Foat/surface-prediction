function outroi = get_roi(p1,p2,omap,vp,level,tovp,type,dmap)
%GET_ROI 
s=size(omap);
s=s(1:2);
% disp([level, tovp, type])

b=1:3;
b=b(b~=level);
stoppingpoly=omap(:,:,b(1))+omap(:,:,b(2));
% imshow(stoppingpoly)
% pause
outroi=zeros(s);
% to vp
if type==1
    poly=extend_line(p1,p2,vp(tovp,:),1,stoppingpoly,s(2),s(1));
    outroi=outroi+poly2mask(poly(:,1), poly(:,2), s(1), s(2));
    poly=extend_line(p1,p2,vp(tovp,:),-1,stoppingpoly,s(2),s(1));
    outroi=outroi+poly2mask(poly(:,1), poly(:,2), s(1), s(2));
elseif type==2
    poly=extend_line(p1,p2,vp(tovp,:),1,stoppingpoly,s(2),s(1));
    outroi=outroi+poly2mask(poly(:,1), poly(:,2), s(1), s(2));
elseif type==3
    poly=extend_line(p1,p2,vp(tovp,:),-1,stoppingpoly,s(2),s(1));
    outroi=outroi+poly2mask(poly(:,1), poly(:,2), s(1), s(2));
end

% imshow(outroi)
% pause

end

function poly = extend_line(p1,p2, vp, towards_or_away, stoppingpoly, imgwidth, imgheight)
% towards_or_away: 1 or -1
curp1 = p1; curp2 = p2;
move_amount = 128;
leaf=[1 1; imgwidth 1; imgwidth imgheight; 1 imgheight];
while move_amount>=1
    [newp1, newp2, atvp] = move_line_towards_vp(curp1, curp2, vp, towards_or_away * move_amount);
    
    failed = 0;
    if atvp==1
%         move_amount = 0; % exit now.
        failed = 1;
    elseif ~(~isempty(intersectLinePolygon(createLine(newp1,newp2),leaf)) &&...
            (between(newp1(1),1,imgwidth,0)~=between(newp2(1),1,imgwidth,0)&&...
            between(newp1(2),1,imgheight,0)~=between(newp2(2),1,imgheight,0))) &&...
        (newp1(1)>imgwidth || newp1(1)<1 || newp1(2)>imgheight || newp1(2)<1) && ...
       (newp2(1)>imgwidth || newp2(1)<1 || newp2(2)>imgheight || newp2(2)<1)
           failed = 1;
    else
        isstop = poly_inter(stoppingpoly,p1,p2,newp1,newp2);
        
        if any(isstop)
            failed = 1;
        end
    end
    
    if failed
        move_amount = move_amount/2;
    else
        curp1 = newp1;
        curp2 = newp2;
    end
end
poly = [p1(:)'; p2(:)'; curp2(:)'; curp1(:)'];
end

function res = poly_inter(stopping,p1,p2,np1,np2)
s=size(stopping);
poly=[p1(:)'; p2(:)'; np2(:)'; np1(:)'];
mask=poly2mask(poly(:,1), poly(:,2), s(1), s(2));
res=0;
if sum(sum(stopping&mask))>0
    res=1;
end

% imshow(mask)
% pause

end


function [newp1, newp2, atvp] = move_line_towards_vp(linep1, linep2, vp, amount)
n1 = norm(vp-linep1);
n2 = norm(vp-linep2);
dir1 = (vp - linep1) / n1;
dir2 = (vp - linep2) / n2;
ratio21 = n2 / n1;

if n1 < amount
    newp1 = linep1;
    newp2 = linep2;
    atvp = 1;
else
    newp1 = linep1 + dir1 * amount;
    newp2 = linep2 + dir2 * amount * ratio21;
    atvp = 0;
end
end
