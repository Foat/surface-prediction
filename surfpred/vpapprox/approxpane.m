function panenew = approxpane(pane,vp,type,omap)
%APPROXPANE approximates panel using vp
% todo : current panel layer continuation
s = size(pane);

se = strel('disk',2);        
buf = imerode(pane,se);

buf=pane&~buf;

omap3=omap;
omap3(:,:,type)=(omap3(:,:,type)&~buf)*255;
% imshow(omap3)
% pause

vparr = zeros([3 2]);
for i=1:3
    vparr(i,:) = vp{i};
end
% simplify contour
[row,col] = find(pane > 0);
c1 = bwtraceboundary(pane, [row(1) col(1)], 'N');
c = dpsimplify(c1, 2);
pane = roipoly(pane,c(:,2),c(:,1));

sc=size(c);
c=c(1:sc(1)-1,:);
lines = find_lines(c, vparr);
% adds new field-type, 1:3, 2-to vp, 3-in opposite dir,1-both
lines = ext_lines(lines,c,s,type);
% 
%% display
% disp_vanish(pane, lines, vp);
omap = generate_panes(pane,lines,vparr,type,omap3);
% figure;imshow(omap);
% pause;
panenew = omap;

end