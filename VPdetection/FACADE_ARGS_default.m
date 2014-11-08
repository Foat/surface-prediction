function ARGS = FACADE_ARGS_default(ARGS)
    
    
    const = FACADE_const();
    
    %ARGS.ALL_pixelThreshold =2;
    ARGS.ALL_calibrated = false;
    ARGS.REF_remNonManhantan = false; %remove , to used with Calibrated JLinkage
         
    ARGS.ALL_samplingAlgo = const.SAMPLING_EDGELENGTH;
    %--------------------------------------------------------------------
    ARGS.ALL_sampleSize  = 2; %# of edges to compute candidates
    ARGS.ALL_minInliers  = 5; %min # of inliers to keep a solutio
    
    %--------------------------------------------------------------------
    %error functions
    
    ARGS.ERROR = const.ERROR_DIST; %regular distance
    ARGS.ERROR_DIST = 2;
  
    %ARGS.ERROR = const.ERROR_NDIST; %normalized distance
    ARGS.ERROR_NDIST = 0.020;%*2;
                             
    %ARGS.ERROR = const.ERROR_ANGLE; %angle, buggy?
    ARGS.ERROR_ANGLE = 1.5;
    %--------------------------------------------------------------------
    %J-Linkage
    ARGS.JL_minNModel          = 500;
    ARGS.JL_solveVP            = const.SOLVE_VP_MAX;  %don't touch  
    ARGS.JL_ERROR_DIST         = 2;    %overide the above threshold
    ARGS.JL_GRICselect         = false;%true;
           
    %--------------------------------------------------------------------
      
    %--------------------------------------------------------------------
    %tests: runTest function
    ARGS.manhattanVP       = false;
    ARGS.useGaussSphere    = false;  %default, GS is turned off
    ARGS.refine            = true;   %refine using e.g. EM
    ARGS.selfCalib_nonlin  = false;  %not fair
    ARGS.fixedrand         = false;  %initialize random gen with the same val, for DEBUGGING
    
    %--------------------------------------------------------------------
    %edges
    ARGS.minEdgeLength     = 20;    %in pixels
    ARGS.linesegTOL        = 2;     %pixel tolerance when selecting straight edges    
    ARGS.edgeCache         = false; %precomputing and saving, or online
    ARGS.edgeGT            = false; %use ground truth for Yord DB
    ARGS.plot              = 0;     %show plot
    ARGS.savePlot          = false; %save plot
