function str = linestyle(i)
    
    
    vStr = {'-', '--', '-.', ':'};
    vStr = {'-', '--', '-.'};
    mod1(i,length(vStr));
    str=vStr{ans};
    
    
    
function v=mod1(v, md)
    
    
    v= mod(v -1, md) +1;