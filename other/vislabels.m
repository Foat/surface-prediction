function out = vislabels(L)
% useful for superpixels
% input - grayscale image: imshow(vislabels(imgs.segimage))
out = zeros([size(L) 3],'double');
mx=max(L(:));
colors=zeros([mx 3]);
colors(:,1)=rand([mx 1]);
colors(:,2)=(rand([mx 1])*10+90)/100;
colors(:,3)=(rand([mx 1])*10+90)/100;
for j=1:3
    outj=out(:,:,j);
    for i=1:mx        
        outj(L==i)=colors(i,j);
    end
    out(:,:,j)=out(:,:,j)+outj;
end
out=hsv2rgb(out);
end
