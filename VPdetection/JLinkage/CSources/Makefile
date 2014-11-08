#author:	Jean-Philippe Tardif

MAKEFILEDEP     := Makefile ../../Makefile.spec
ALLDEP 	        += $(MAKEFILEDEP)

#../CMINPACK/libminpack.a
include ../../Makefile.spec


strDiv		:= "======================================================================="
#mexfile 	:= mexJLinkage.$(MEX_SUFFIX) mexPLinkage.$(MEX_SUFFIX) linkageIntersect.$(MEX_SUFFIX)  pDistJaccard.$(MEX_SUFFIX)
mexfile 	:= mexJLinkage.$(MEX_SUFFIX) 
exefile 	:= 

all: $(mexfile) $(exefile)



mexJLinkage.$(MEX_SUFFIX): mexJLinkage.cpp $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	@echo $(MEX_LDFLAGS)
	$(MEX) CXX=$(MEX_CXX) $(MEX_CXXFLAGS) $(CXXFLAGS) $(MEX_LDFLAGS) -DMATLAB   $< -o $@


mexPLinkage.$(MEX_SUFFIX): mexPLinkage.cpp $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	@echo $(MEX_LDFLAGS)
	$(MEX) CXX=$(MEX_CXX) $(MEX_CXXFLAGS) $(CXXFLAGS) $(MEX_LDFLAGS) -DMATLAB   $< -o $@


linkageIntersect.$(MEX_SUFFIX): linkageIntersect.cpp $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	@echo $(MEX_LDFLAGS)
	$(MEX) CXX=$(MEX_CXX) $(MEX_CXXFLAGS) $(CXXFLAGS) $(MEX_LDFLAGS) -DMATLAB   $< -o $@

pDistJaccard.$(MEX_SUFFIX): pDistJaccard.cpp $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	@echo $(MEX_LDFLAGS)
	$(MEX) CXX=$(MEX_CXX) $(MEX_CXXFLAGS) $(CXXFLAGS) $(MEX_LDFLAGS) -DMATLAB   $< -o $@


clean:
	rm -f *$(MEX_SUFFIX) *.o 

