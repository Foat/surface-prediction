function imsegs = im2superpixels(im)

prefix = num2str(floor(rand(1)*10000000));
fn1 = ['./tmpim' prefix '.ppm'];
fn2 = ['./tmpimsp' prefix '.ppm'];
segcmd = 'lib/segment/segment 0.5 100 100';

imwrite(im, fn1);
system([segcmd ' ' fn1 ' ' fn2]);
imsegs = processSuperpixelImage(fn2);

delete(fn1);
delete(fn2);