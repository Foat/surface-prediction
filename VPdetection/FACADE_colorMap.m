function mClr = FACADE_colorMap(nb)
    
    
    mClr = hsv(nb);
    %mClr = varycolor(nb);
    
    for i=1:size(mClr)
        if all(mClr(i,:)==[1,0,0]) %R
            rand(1,3);
            mClr(i,:)= ans/norm(ans);            
        end
        if all(mClr(i,:)==[0,1,0]) %G
            rand(1,3);
            mClr(i,:)= ans/norm(ans);
        end
        if all(mClr(i,:)==[0,0,1]) %B
            rand(1,3);
            mClr(i,:)= ans/norm(ans);
        end
        
    end
       
    mClr(1,:) = [1,0,0];
    mClr(2,:) = [0,1,0];
    mClr(3,:) = [0,0,1];