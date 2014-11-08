function [l, sides] = line_box(x0, x1, y0, y1, r, theta)
% LINE_BOX Intersection of line with sides of box
% L = LINE_BOX(X0, X1, Y0, Y1, R, THETA) returns the intersection of
% the straight line such that the polar coordinates of the nearest
% point on it to the origin are R,THETA with the box with opposite
% corners at (X0,Y0) and (X1,Y1). If the line does not intersect the
% box, an empty matrix is returned. Otherwise the points at the ends of
% the line segment are returned in the order [x y x y]'.
%
% [L, S] = LINE_BOX(X0, X1, Y0, Y1, R, THETA) returns also a list of
% the sides of the box intersected by the line, numbered in the same
% sense as THETA starting from 1, which is on the right.
% see http://www.mathworks.com/matlabcentral/newsreader/view_thread/293655

c = cos(theta); s = sin(theta);
npts = 0;
l = [];
sides = [];

ylf = intersect(s, c, r, x0);
if ylf >= y0 && ylf <= y1
    npts = npts + 1;
    sides(npts, 1) = 3;
    l(2*npts-1, 1) = x0; l(2*npts, 1) = ylf;
end

yrt = intersect(s, c, r, x1);
if yrt >= y0 && yrt <= y1
    npts = npts + 1;
    sides(npts, 1) = 1;
    l(2*npts-1, 1) = x1; l(2*npts, 1) = yrt;
end

if npts < 2
    xtp = intersect(c, s, r, y0);
    if xtp >= x0 && xtp <= x1
        npts = npts + 1;
        sides(npts, 1) = 4;
        l(2*npts-1, 1) = xtp; l(2*npts, 1) = y0;
    end
end

if npts < 2
    xbt = intersect(c, s, r, y1);
    if xbt >= x0 && xbt <= x1
        npts = npts + 1;
        sides(npts, 1) = 2;
        l(2*npts-1, 1) = xbt; l(2*npts, 1) = y1;
    end
end

end


function y = intersect(s, c, r, x)
if s == 0 
    y = Inf;
else
    y = (r - c * x) / s;
end
end