% http://lewysjones.com/how-to-create-view-3d-graphs-in-matlab-with-3d-glasses/
% http://loomsci.wordpress.com/2013/08/14/3d-anaglyphs-in-matlab/
close all

 parallaxAngle = 1;       % You can change this to suit yourself.
 
 az=-37.5;
 el=8;
 leftImage = figure;
surf(-X,Y,Z, img, ...
     'edgecolor', 'none','FaceColor','texturemap');
axis equal
axis vis3d
set(gca,'visible','off')
set(gca,'units','normalized','position',[0 0 1 1])
r=150;
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 1000 1000]/r);
set(gcf,'Position',[0 0 1000 1000])
        
% Lock the aspect ration for rotation.
view(az-parallaxAngle,el)
 grid on ;                      % Switch on the figure grid, and
 set(gca,'GridLineStyle','-')   % set the grid to solid lines.
 
 rightImage = figure;
 surf(-X,Y,Z, img, ...
     'edgecolor', 'none','FaceColor','texturemap');
axis equal
axis vis3d
set(gca,'visible','off')
set(gca,'units','normalized','position',[0 0 1 1])
r=150;
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 1000 1000]/r);
set(gcf,'Position',[0 0 1000 1000])
        
view(az+parallaxAngle,el)
 grid on ;                      % Switch on the figure grid, and
 set(gca,'GridLineStyle','-')   % set the grid to solid lines.
 
 print(leftImage ,'-dtiffn','-painters', 'Left_Eye.tif')
 print(rightImage,'-dtiffn','-painters','Right_Eye.tif')

 img1  = imread('Left_Eye.tif')  ; % Load the left eye image.
 img2 = imread('Right_Eye.tif') ; % Load the right eye image.
 
 AG = zeros(size(img1)); %good, we'll get an RGB image.
 AG(:,:,1) = img1(:,:,1)*.456 + img1(:,:,2)*.5 + img1(:,:,3)*.176 + ...
 img2(:,:,1)*-.043+img2(:,:,2)*-.088 + img2(:,:,3)*-.002;
AG(:,:,2) = img1(:,:,1)*-.04 + img1(:,:,2)*-.038 + img1(:,:,3)*-.016 + ...
 img2(:,:,1)*.378+img2(:,:,2)*.734 + img2(:,:,3)*-.018;
AG(:,:,3) = img1(:,:,1)*-.015 + img1(:,:,2)*-.021 + img1(:,:,3)*-.005 + ...
 img2(:,:,1)*-.072+img2(:,:,2)*-.113 + img2(:,:,3)*1.226;

%  img1(:,:,2:3) = 0 ;               % Removes green and blue from the left eye image.
%  img2(:,:,1)  = 0 ;               % Removes red from the right eye image.
%  AG = img1 + img2 ; % Combines the two to produce the finished anaglyph.

imshow(uint8(AG),'border','tight') ;       % Show the anaglyph image with no padding.
 print(gcf,'-dtiffn','-painters','Anaglyph.tif')  % Save the anaglyph image.