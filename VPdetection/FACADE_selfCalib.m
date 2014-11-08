%
% Perform self-calibration of the camera using 2 and 3 vanishing points
%
function [f123,f12] = FACADE_selfCalib(ARGS,vsVP, vsEdges, vClass, vbOutliers)


    
%All 3 vp
    if length(vsVP)>=3
        mA = [[vsVP(1).VP]' .* [vsVP(2).VP]';...
              [vsVP(1).VP]' .* [vsVP(3).VP]';...
              [vsVP(2).VP]' .* [vsVP(3).VP]';...
             ];
        
        mA2 = [mA(:,1)+mA(:,2), mA(:,3)];
        [u,d,v] = svd(mA2);
        sol = v(:,end);
        f123 = sqrt(1/ (sol(1)/sol(2)) )*ARGS.imgS;
    else
        f123 =0;
    end

    %first 2 only
    if length(vsVP)>=2

        mA = [vsVP(1).VP]' .* [vsVP(2).VP]';
        
        
        mA2 = [mA(:,1)+mA(:,2), mA(:,3)];
        [u,d,v] = svd(mA2);
        sol = v(:,end);
        f12 = sqrt(1/ (sol(1)/sol(2)) )*ARGS.imgS;
    else
        f12 = 0;
    end
        
    FCprintf('focal length are %f | %f\n', f123, f12);  
    
    
   