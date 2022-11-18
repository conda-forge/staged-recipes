#include "math.h"
#include "stdlib.h"
#include "stdio.h"

#include "adolc.h"
#include "sparse/sparsedrivers.h"

#define repnum 10

//------------------------------------------------------------------------------------
// for time measurements

#include <sys/time.h>
#include "ColPackHeaders.h"

using namespace ColPack;

double k_getTime() {
   struct timeval v;
   struct timezone z;
   gettimeofday(&v, &z);
   return ((double)v.tv_sec)+((double)v.tv_usec)/1000000;
}

//------------------------------------------------------------------------------------
// required for second method

using namespace std;

#include <list>
#include <map>
#include <string>
#include <vector>

//------------------------------------------------------------------------------------
// as before

#define tag_f 1
#define tag_red 2
#define tag_HP 3

#define tag_c 4

// problem definition -> eval_fun.c
void init_dim(int *n, int *m);
void init_startpoint(double *x, int n);
double  feval(double *x, int n);
adouble feval_ad(double *x, int n);
void ceval(double *x, double *c, int n);
void ceval_ad(double *x, adouble *c, int n);
adouble feval_ad_mod(double *x, int n);
adouble feval_ad_modHP(double *x, int n);

void printmat(char* kette, int n, int m, double** M);
void printmatint(char* kette, int n, int m, int** M);
void printmatint_c(char* kette, int m,unsigned int** M);


int main()
{
  int i, j, k, l, sum, n, m, nnz, direct = 1, found;
  double f;
  double *x, *c;
  adouble fad, *xad, *cad;
  //double** Zpp;
  //double** Zppf;
  double** J;
  //double* s;
  //int p_H_dir, p_H_indir;
  size_t tape_stats[11];
  int num;
  FILE *fp_JP;

  double **Seed_J;
  double **Jc;
  int p_J;

  int recover = 1;
  int jac_vec = 1;
  int compute_full = 1;
  int output_sparsity_pattern_J = 0;
  //int output_sparsity_pattern_H = 1;
  //int use_direct_method = 1;
  //int output_direct = 0;
  //int use_indirect_method = 1;
  //int output_indirect = 0;

  double t_f_1, t_f_2, div_f=0, div_c=0, div_JP=0, div_JP2=0, div_Seed=0, div_Seed_C=0, div_Jc=0, div_Jc_C=0, div_rec=0, div_rec_C=0, div_J=0;
  //double test;
  unsigned int *rind;
  unsigned int *cind;
  double *values;

  //tring s_InputFile = "test_mat.mtx";
  //string s_InputFile = "jac_pat.mtx";


//------------------------------------------------------------------------------------
// problem definition + evaluation

  init_dim(&n,&m); // initialize n and m

  printf(" n = %d m = %d\n",n,m);

  x =   (double*)  malloc(n*sizeof(double)); // x: vector input for function evaluation
  c =   (double*)  malloc(m*sizeof(double)); // c: constraint vector
  cad = new adouble[m];

  init_startpoint(x,n);

  t_f_1 = k_getTime();
  for(i=0;i<repnum;i++)
    f = feval(x,n);
  t_f_2 = k_getTime();
  div_f = (t_f_2 - t_f_1)*1.0/repnum;
  printf("XXX The time needed for function evaluation:  %10.6f \n \n", div_f);


  t_f_1 = k_getTime();
  for(i=0;i<repnum;i++)
    ceval(x,c,n);
  t_f_2 = k_getTime();
  div_c = (t_f_2 - t_f_1)*1.0/repnum;
  printf("XXX The time needed for constraint evaluation:  %10.6f \n \n", div_c);


  trace_on(tag_f);

    fad = feval_ad(x, n); // feval_ad: derivative of feval

    fad >>= f;

  trace_off();

  trace_on(tag_c);

    ceval_ad(x, cad, n); //ceval_ad: derivative of ceval

    for(i=0;i<m;i++)
      cad[i] >>= f;

  trace_off();
  //return 1;

  tapestats(tag_c,tape_stats);              // reading of tape statistics
  printf("\n    independents   %ld\n",(long)tape_stats[0]);
  printf("    dependents     %ld\n",(long)tape_stats[1]);
  printf("    operations     %ld\n",(long)tape_stats[5]);
  printf("    buffer size    %ld\n",(long)tape_stats[4]);
  printf("    maxlive        %ld\n",(long)tape_stats[2]);
  printf("    valstack size  %ld\n\n",(long)tape_stats[3]);


//------------------------------------------------------------------------------------
// full Jacobian:

  div_J = -1;

  if(compute_full == 1)
    {
      J =  myalloc2(m,n);

      t_f_1 = k_getTime();
      jacobian(tag_c,m,n,x,J);
      t_f_2 = k_getTime();
      div_J = (t_f_2 - t_f_1);

      printf("XXX The time needed for full Jacobian:  %10.6f \n \n", div_J);
      printf("XXX runtime ratio:  %10.6f \n \n", div_J/div_c);

      //save the matrix into a file (non-zero entries only)

	fp_JP = fopen("jac_full.mtx","w");

	fprintf(fp_JP,"%d %d\n",m,n);

	for (i=0;i<m;i++)
	  {
	    for (j=0;j<n;j++)
	      if(J[i][j]!=0.0) fprintf(fp_JP,"%d %d %10.6f\n",i,j,J[i][j] );
	  }
	fclose(fp_JP);
    }

//------------------------------------------------------------------------------------
  printf("XXX THE 4 STEP TO COMPUTE SPARSE MATRICES USING ColPack \n \n");
// STEP 1: Determination of sparsity pattern of Jacobian JP:

  unsigned int  *rb=NULL;          /* dependent variables          */
  unsigned int  *cb=NULL;          /* independent variables        */
  unsigned int  **JP=NULL;         /* compressed block row storage */
  int ctrl[2];

  JP = (unsigned int **) malloc(m*sizeof(unsigned int*));
  ctrl[0] = 0; ctrl[1] = 0;


  t_f_1 = k_getTime();
  jac_pat(tag_c, m, n, x, JP, ctrl);	//ADOL-C calculate the sparsity pattern
  t_f_2 = k_getTime();
  div_JP = (t_f_2 - t_f_1);

  printf("XXX STEP 1: The time needed for Jacobian pattern:  %10.6f \n \n", div_JP);
  printf("XXX STEP 1: runtime ratio:  %10.6f \n \n", div_JP/div_c);


  nnz = 0;
  for (i=0;i<m;i++)
    nnz += JP[i][0];

  printf(" nnz %d \n",nnz);
  printf(" hier 1a\n");


//------------------------------------------------------------------------------------
// STEP 2: Determination of Seed matrix:

  double tg_C;
  int dummy;

  t_f_1 = k_getTime();

  BipartiteGraphPartialColoringInterface * gGraph = new BipartiteGraphPartialColoringInterface(SRC_MEM_ADOLC, JP, m, n);
  //gGraph->PrintBipartiteGraph();
  t_f_2 = k_getTime();

  printf("XXX STEP 2: The time needed for Graph construction:  %10.6f \n \n", (t_f_2-t_f_1) );
  printf("XXX STEP 2: runtime ratio:  %10.6f \n \n", (t_f_2-t_f_1)/div_c);

  t_f_1 = k_getTime();
  //gGraph->GenerateSeedJacobian(&Seed_J, &dummy, &p_J,
  //                          "NATURAL", "COLUMN_PARTIAL_DISTANCE_TWO");
  gGraph->PartialDistanceTwoColoring("NATURAL", "COLUMN_PARTIAL_DISTANCE_TWO");
  t_f_2 = k_getTime();

  printf("XXX STEP 2: The time needed for Coloring:  %10.6f \n \n", (t_f_2-t_f_1));
  printf("XXX STEP 2: runtime ratio:  %10.6f \n \n", (t_f_2-t_f_1)/div_c);

  t_f_1 = k_getTime();
  Seed_J = gGraph->GetSeedMatrix(&dummy, &p_J);
  t_f_2 = k_getTime();
  tg_C = t_f_2 - t_f_1;


  printf("XXX STEP 2: The time needed for Seed generation:  %10.6f \n \n", tg_C);
  printf("XXX STEP 2: runtime ratio:  %10.6f \n \n", tg_C/div_c);

  //*/

//------------------------------------------------------------------------------------
// STEP 3: Jacobian-matrix product:

// ADOL-C:
//*
  if (jac_vec == 1)
    {

      Jc = myalloc2(m,p_J);
      t_f_1 = k_getTime();
      printf(" hier 1\n");
      fov_forward(tag_c,m,n,p_J,x,Seed_J,c,Jc);
      printf(" hier 2\n");
      t_f_2 = k_getTime();
      div_Jc = (t_f_2 - t_f_1);

      printf("XXX STEP 3: The time needed for Jacobian-matrix product:  %10.6f \n \n", div_Jc);
      printf("XXX STEP 3: runtime ratio:  %10.6f \n \n", div_Jc/div_c);


    }

//------------------------------------------------------------------------------------
// STEP 4: computed Jacobians/ recovery


  if (recover == 1)
    {


      JacobianRecovery1D jr1d;

      printf("m = %d, n = %d, p_J = %d \n",m,n,p_J);
      //printmatint_c("JP Jacobian Pattern",m,JP);
      //printmat("Jc Jacobian compressed",m,p_J,Jc);

      t_f_1 = k_getTime();
      jr1d.RecoverD2Cln_CoordinateFormat (gGraph, Jc, JP, &rind, &cind, &values);
      t_f_2 = k_getTime();
      div_rec_C = (t_f_2 - t_f_1);

      printf("XXX STEP 4: The time needed for Recovery:  %10.6f \n \n", div_rec_C);
      printf("XXX STEP 4: runtime ratio:  %10.6f \n \n", div_rec_C/div_c);

      //save recovered matrix into file

	fp_JP = fopen("jac_recovered.mtx","w");

	fprintf(fp_JP,"%d %d %d\n",m,n,nnz);

	for (i=0;i<nnz;i++)
	  {
	      fprintf(fp_JP,"%d %d %10.6f\n",rind[i],cind[i],values[i] );
	  }
	fclose(fp_JP);

    }

    /*By this time, if you compare the 2 output files: jac_full.mtx and jac_recovered.mtx
    You should be able to see that the non-zero entries are identical
    */


  free(JP);
  delete[] cad;
  free(c);
  free(x);
  delete gGraph;
  if(jac_vec == 1) {
    myfree2(Jc);
  }
  if(compute_full == 1)
    {
      myfree2(J);
    }

  return 0;

}




/***************************************************************************/

void printmat(char* kette, int n, int m, double** M)
{ int i,j;

  printf("%s \n",kette);
  for(i=0; i<n ;i++)
  {
    printf("\n %d: ",i);
    for(j=0;j<m ;j++)
	printf(" %10.4f ", M[i][j]);
  }
  printf("\n");
}

void printmatint(char* kette, int n, int m, int** M)
{ int i,j;

  printf("%s \n",kette);
  for(i=0; i<n ;i++)
  {
    printf("\n %d: ",i);
    for(j=0;j<m ;j++)
      printf(" %d ", M[i][j]);
  }
  printf("\n");
}


void printmatint_c(char* kette, int m,unsigned int** M)
{ int i;
  unsigned int j;

  printf("%s \n",kette);
  for (i=0;i<m;i++)
    {
    printf("\n %d (%d): ",i,M[i][0]);
      for (j=1;j<=M[i][0];j++)
	printf("\t%d ",M[i][j]);
    }
  printf("\n");
}
