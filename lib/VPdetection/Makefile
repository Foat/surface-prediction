#author:	Jean-Philippe Tardif

MAKEFILEDEP     := Makefile Makefile.spec
ALLDEP 	        += $(MAKEFILEDEP)

#../CMINPACK/libminpack.a
include Makefile.spec

MINPACK		:= CMINPACK/libminpack.a
LDFLAGS         += $(MINPACK)
MEX_CFLAGS 	+= -ICMINPACK 
CFLAGS 		+= -ICMINPACK 

strDiv		:= "======================================================================="
mexfile 	:= FACADE_mxFitL_x_constVP.$(MEX_SUFFIX)  FACADE_mxFitVP_x_MAX.$(MEX_SUFFIX)


SUBDIRS := CMINPACK  lineSegDetect  JLinkage/CSources/

all: SUBS $(mexfile)  


SUBS:
	for subdir in $(SUBDIRS); do\
		(cd $$subdir && make all)\
	done

FACADE_mxFitL_x_constVP.$(MEX_SUFFIX): FACADE_mxFitL_x_constVP.cpp $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	$(MEX) CXX=$(CXX) $(MEX_CFLAGS) $(CXXFLAGS) $(LDFLAGS)   $< -output $@

FACADE_mxFitL_x_constVP_MLE.$(MEX_SUFFIX): FACADE_mxFitL_x_constVP_MLE.c $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	$(MEX) CXX=$(CXX) $(MEX_CFLAGS) $(CXXFLAGS) $(LDFLAGS)   $< -output $@

FACADE_mxFitVP_x_multiL.$(MEX_SUFFIX): FACADE_mxFitVP_x_multiL.c $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	$(MEX) CXX=$(CXX) $(MEX_CFLAGS) $(CXXFLAGS) $(LDFLAGS)   $< -output $@


FACADE_mxFitVP_x_GS.$(MEX_SUFFIX): FACADE_mxFitVP_x_GS.c $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	$(MEX) CXX=$(CXX) $(MEX_CFLAGS) $(CXXFLAGS) $(LDFLAGS)   $< -output $@

FACADE_mxFitVP_x_MAX.$(MEX_SUFFIX): FACADE_mxFitVP_x_MAX.c $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	$(MEX) CXX=$(CXX) $(MEX_CFLAGS) $(CXXFLAGS) $(LDFLAGS)   $< -output $@

FACADE_mxFitVP_x_MLE.$(MEX_SUFFIX): FACADE_mxFitVP_x_MLE.c $(ALLDEP)
	@echo $(strDiv)
	@echo "   MEX '$<' ==> '$@'"	
	@echo ""
	$(MEX) CXX=$(CXX) $(MEX_CFLAGS) $(CXXFLAGS) $(LDFLAGS)   $< -output $@


clean:
	rm -f *$(MEX_SUFFIX) *.o
	rm -f *$(MEX_SUFFIX) *.mex*
	for subdir in $(SUBDIRS); do\
		(cd $$subdir && make clean)\
	done
