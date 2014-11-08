function omapnew = approxomap(omap,vp,gc)
%APPROXOMAP approximates orientation map with lines from vp
s = size(omap);
omapnew = zeros(s);
s = s(1:2);
% close all

for i=1:3
    b=omap(:,:,i);
    labeled = bwlabel(b);
    num = max(max(labeled));
    
    fprintf('level = %d, num = %d\n', i, num);
    for j=1:num
        bufpane = zeros(s);
        bufpane(labeled == j) = 1;
%         pane=zeros([s 3]);
%         pane(:,:,i)=bufpane;
        ap=approxpane(bufpane,vp,i,omap);
%         imshow(ap+pane);
        omapnew=omapnew+ap;
        
%         pause;
        b=1:3;
        ep=b(b~=i);
        omapnew(:,:,i)=omapnew(:,:,i)+bufpane;
        for k=ep
            ap=approxpane(bufpane,vp,k,omap);
            omapnew=omapnew+ap;
        end
    end
%     imshow(omapnew(:,:,i));
%     pause;
end

% combine gc with sp approach
% if ~isempty(gc)
%     omapnew(:,:,1)=omapnew(:,:,1)+(gc(:,:,1))*2;
%     omapnew(:,:,2)=omapnew(:,:,2)+(gc(:,:,4))*2;
%     omapnew(:,:,3)=omapnew(:,:,3)+(gc(:,:,2))*2;
% end

% find max on 3 layers & set other to 0
[~,p]=max(omapnew,[],3);
for i=1:3
    omapnew(:,:,i)=omapnew(:,:,i)&(p==i);
end

end

