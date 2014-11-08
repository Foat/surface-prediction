function isb = between(a,x1,x2,eps)
%BETWEEN checks if point lies between 2 points
if nargin<4
    eps=1;
end
s=min(x1,x2);
l=max(x1,x2);
isb=a>=s-eps & a<=l+eps;
end

