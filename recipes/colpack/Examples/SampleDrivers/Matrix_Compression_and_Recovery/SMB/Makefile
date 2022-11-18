# Compiler
CC = g++
CFLAGS = -O5
#CFLAGS = -g
LIBS = -lm -lstdc++

# Definitions for ADOL-C
# CHANGE THIS TO YOUR ADOL-C BASE DIRECTORY
ADPATH = $(HOME)/adolc_base/include/adolc
ADPATHa = $(HOME)/adolc_base/include
ADLIBDIR = $(HOME)/adolc_base/lib
ADCFLAGS = -I$(ADPATH) -I$(ADPATHa) -I$(HOME)/Desktop/Working_U/research_Assefaw/svn_projects/projects/src/ColPack/build/include
ADLIBS = -Wl,--rpath -Wl,$(ADLIBDIR) -L$(ADLIBDIR) -ladolc -lColPack -L$(HOME)/Desktop/Working_U/research_Assefaw/svn_projects/projects/src/ColPack/build/lib

ADPATH1 = $(HOME)/adolc_base/include/adolc
ADPATH1a = $(HOME)/adolc_base/include
ADLIBDIR1 = $(HOME)/adolc_base/lib
ADCFLAGS1 = -I$(ADPATH1)  -I$(ADPATH1a)
ADLIBS1 = -Wl,--rpath -Wl,$(ADLIBDIR1) -L$(ADLIBDIR1) -ladolc

ADPATH2 = $(HOME)/adolc_base/include/adolc
ADPATH3 = $(HOME)/adolc_base/include
ADLIBDIR2 = $(HOME)/adolc_base/lib
ADCFLAGS2 = -I$(ADPATH2)  -I$(ADPATH3)
ADLIBS2 = -Wl,--rpath -Wl,$(ADLIBDIR2) -L$(ADLIBDIR2) -ladolc

ADPATH4 = $(HOME)/adolc_base/include/adolc
ADPATH5 = $(HOME)/adolc_base/include
ADLIBDIR4 = $(HOME)/adolc_base/lib
ADCFLAGS4 = -I$(ADPATH4)  -I$(ADPATH5)
ADLIBS4 = -Wl,--rpath -Wl,$(ADLIBDIR4) -L$(ADLIBDIR4) -ladolc

ADPATH6 = $(HOME)/adolc_base/include/adolc
ADPATH7 = $(HOME)/adolc_base/include
ADLIBDIR6 = $(HOME)/adolc_base/lib
ADCFLAGS6 = -I$(ADPATH6)  -I$(ADPATH7)
ADLIBS6 = -Wl,--rpath -Wl,$(ADLIBDIR6) -L$(ADLIBDIR6) -ladolc

# Ziele
all:  sparse_jac_hess

sparse_jac_hess: sparse_jac_hess.o eval_fun_chem.o
	$(CC) -o sparse_jac_hess  $(ADCFLAGS) sparse_jac_hess.o eval_fun_chem.o \
	$(LIBS) $(ADLIBS) -lgcc

sparse_jac_hess_fun_a: sparse_jac_hess.o eval_fun_struct.o GraphColoring.o DisjointSets.o
	$(CC) -o sparse_jac_hess_a  $(ADCFLAGS1) sparse_jac_hess.o eval_fun_struct.o GraphColoring.o DisjointSets.o \
	$(LIBS) $(ADLIBS1) -lgcc

sparse_jac_hess_fun_b: sparse_jac_hess_b.o eval_fun_struct.o GraphColoring.o DisjointSets.o
	$(CC) -o sparse_jac_hess_b  $(ADCFLAGS2) sparse_jac_hess_b.o eval_fun_struct.o GraphColoring.o DisjointSets.o \
	$(LIBS) $(ADLIBS2) -lgcc

sparse_jac_hess_fun_c: sparse_jac_hess_c.o eval_fun_struct.o GraphColoring.o DisjointSets.o
	$(CC) -o sparse_jac_hess_c  $(ADCFLAGS4) sparse_jac_hess_c.o eval_fun_struct.o GraphColoring.o DisjointSets.o \
	$(LIBS) $(ADLIBS4) -lgcc

sparse_jac_hess_fun_d: sparse_jac_hess_d.o eval_fun_struct.o GraphColoring.o DisjointSets.o
	$(CC) -o sparse_jac_hess_d  $(ADCFLAGS6) sparse_jac_hess_c.o eval_fun_struct.o GraphColoring.o DisjointSets.o \
	$(LIBS) $(ADLIBS6) -lgcc

#-----------------------------------------------------------------------
#                                                                      #

sparse_jac_hess.o: sparse_jac_hess.cpp
	$(CC) -c $(CFLAGS) $(ADCFLAGS) sparse_jac_hess.cpp -lm

sparse_jac_hess_b.o: sparse_jac_hess.cpp
	$(CC) -o sparse_jac_hess_b.o -c $(CFLAGS) $(ADCFLAGS2) sparse_jac_hess.cpp -lm

sparse_jac_hess_c.o: sparse_jac_hess.cpp
	$(CC) -o sparse_jac_hess_c.o -c $(CFLAGS) $(ADCFLAGS4) sparse_jac_hess.cpp -lm

sparse_jac_hess_d.o: sparse_jac_hess.cpp
	$(CC) -o sparse_jac_hess_d.o -c $(CFLAGS) $(ADCFLAGS4) sparse_jac_hess.cpp -lm

sparse_jac_hess_chem.o: sparse_jac_hess_chem.cpp
	$(CC) -c $(CFLAGS) $(ADCFLAGS) sparse_jac_hess_chem.cpp -lm

#-----------------------------------------------------------------------
#                                                  function evaluation #

eval_fun_chem.o: eval_fun_chem.c
	$(CC) -c $(CFLAGS) $(ADCFLAGS) eval_fun_chem.c

#-----------------------------------------------------------------------
#                                                     acyclic coloring #

GraphColoring.o: GraphColoring.cpp
	$(CC) -c $(CFLAGS) $(ADCFLAGS) GraphColoring.cpp

DisjointSets.o: DisjointSets.cpp
	$(CC) -c $(CFLAGS) $(ADCFLAGS) DisjointSets.cpp

#-----------------------------------------------------------------------
#                                                             clean up #

clean:
	-/bin/rm *.o
