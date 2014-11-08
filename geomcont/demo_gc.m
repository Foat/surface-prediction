im=imread('testimg.jpg');
imsize=size(im);
imgs=im2superpixels(im);
geom_labels=getgc(im,imgs);

romap=zeros(imsize);
% ceiling, floor
romap(:,:,1)=geom_labels(:,:,1)>geom_labels(:,:,2)&...
    geom_labels(:,:,1)>geom_labels(:,:,3)&...
    geom_labels(:,:,1)>geom_labels(:,:,4)|...
    geom_labels(:,:,7)>geom_labels(:,:,2)&...
    geom_labels(:,:,7)>geom_labels(:,:,3)&...
    geom_labels(:,:,7)>geom_labels(:,:,4);

% right, left
romap(:,:,2)=geom_labels(:,:,2)>geom_labels(:,:,1)&...
    geom_labels(:,:,2)>geom_labels(:,:,3)&...
    geom_labels(:,:,2)>geom_labels(:,:,7)|...
    geom_labels(:,:,4)>geom_labels(:,:,1)&...
    geom_labels(:,:,4)>geom_labels(:,:,3)&...
    geom_labels(:,:,4)>geom_labels(:,:,7);

% center
romap(:,:,3)=geom_labels(:,:,3)>geom_labels(:,:,1)&...
    geom_labels(:,:,3)>geom_labels(:,:,2)&...
    geom_labels(:,:,3)>geom_labels(:,:,4)&...
    geom_labels(:,:,3)>geom_labels(:,:,7);

romap(:,:,2)=romap(:,:,2)|~(romap(:,:,1)|romap(:,:,2)|romap(:,:,3));