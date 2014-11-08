function [pg, smaps, imsegs] = ijcvTestImageList(fn, imsegs, classifiers, laboutdir, confoutdir)
% Computes label probabilities for a list of images
% fn should be full path

if isempty(imsegs) 
    createimsegs = 1;
else
    createimsegs = 0;
end

for f = 1:numel(fn)

    try
        im = im2double(imread(fn{f}));
        disp([num2str(f) ': ' fn{f}])

        if createimsegs
            tmp = im2superpixels(im);
            toks = strtokAll(fn{f}, '/');
            tmp.imname = toks{end};
            imsegs(f) = tmp; 
        end

        [pg{f}, smaps{f}] = ijcvTestImage(im, imsegs(f), classifiers);

        if exist('laboutdir') && ~isempty(laboutdir)
            toks = strtokAll(fn{f}, '/');
            imdir = [];
            for k = 1:numel(toks)-1
                imdir = [imdir '/' toks{k}];
            end  
            writeAllLabeledImages(imdir, imsegs(f), pg(f), laboutdir);
        end
        if exist('confoutdir') && ~isempty(confoutdir)    
            [cimages, cnames] = pg2confidenceImages(imsegs(f), pg(f));
            save([confoutdir '/' strtok(imsegs(f).imname, '.') '.c.mat'], 'cimages', 'cnames');        
            writeConfidenceImages(imsegs(f), pg(f), confoutdir);
        end
    catch
        disp(lasterr)
    end
end
