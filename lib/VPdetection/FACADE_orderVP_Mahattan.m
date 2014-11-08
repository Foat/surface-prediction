function  [vsVP, vClass] = FACADE_orderVP_Mahattan(vsVP, vsEdges, vClass)
    
    
    vSupport = FACADE_get_ManhattanSupport(vsVP, vsEdges, vClass);
    [vsVP, vClass] = FACADE_sortClass(vsVP, vClass, vSupport);
    
    
    
    
    