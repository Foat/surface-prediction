#author:	Jean-Philippe Tardif

MAKEFILEDEP     := Makefile ../Makefile.spec
ALLDEP 	        += $(MAKEFILEDEP)

#../CMINPACK/libminpack.a
include ../Makefile.spec


strDiv		:= "======================================================================="
mexfile 	:= mxEdgelink.$(MEX_SUFFIX) mxGetEdges.$(MEX_SUFFIX)
#exefile 	:= mxGetEdges

all: $(mexfile)


mxEdgelink.$(MEX_SUFFIX): mxEdgelink.cpp $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	@echo $(MEX_LDFLAGS)
	$(MEX) CXX=$(MEX_CXX) $(MEX_CXXFLAGS) $(CXXFLAGS) $(MEX_LDFLAGS) -DMATLAB   $< -output $@

mxGetEdges.$(MEX_SUFFIX): mxGetEdges.cpp $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	@echo $(MEX_LDFLAGS)
	$(MEX) CXX=$(MEX_CXX) $(MEX_CXXFLAGS) $(CXXFLAGS) $(MEX_LDFLAGS) -DMATLAB    $< -output $@ 


mxGetEdges: mxGetEdges.cpp $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	@echo $(LDFLAGS)
	$(CXX)  $(CXXFLAGS) $(LDFLAGS)     $< -output $@  


clean:
	rm -f *$(MEX_SUFFIX) *.o
	rm -f *$(MEX_SUFFIX) *.mex*

