function geom_labels = getgc(im,imgs,ld)
% GETRED
% im - rgb image
% outim - 1 channel binary
if nargin==2
    ld=1;
end
if ld
    cl = load('lib/GeometricContext/data/ijcvClassifier.mat');
else
    cl = load('lib/GeometricContext/data/ijcvClassifier_indoor.mat');
end
[pg, ~, imsegs] = ijcvTestImage(im2double(im), imgs, cl);

imsize=imsegs.imsize;
[ss, fs] = size(pg);
geom_labels=zeros([imsize fs]);
for i=1:fs 
    buf=zeros(imsize); 
    for j=1:ss
        buf(imsegs.segimage==j)=pg(j,i); 
    end 
    geom_labels(:,:,i)=buf;
end

end

