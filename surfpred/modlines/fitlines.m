function lines = fitlines(omap,vparr)
s=size(omap);
s=s(1:2);

imgray=~rgb2gray(omap);
% test=padarray(test,[3 3],1);
thinned=bwmorph(imgray,'thin','Inf');
edgelist = edgelink(thinned, 10, 8);
% Line segments are fitted with maximum deviation from
% original edge of 2 pixels.
tol = 4;         
seglist = lineseg(edgelist, tol);

sl=size(seglist);
lines = repmat(struct('point1', [0 0], 'point2', [0 0], 'length', 0.0,...
    'lineclass',0,'id',0), sl(1), 1);
dist=consist_measure(seglist,vparr);
[~,pos]=min(dist,[],2);
for i=1:sl(1)
    point1 = seglist(i,1:2);
	point2 = seglist(i,3:4);
	l = norm(point1 - point2);
    lineclass=pos(i);
    lines(i)=struct('point1', point1, 'point2', point2, 'length', l,...
    'lineclass',lineclass,'id',i);
end
if nargout==0
    disp_vanish(zeros(s), lines, vp);
end

end

