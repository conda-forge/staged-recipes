#include "adolc.h"

// This file implements the dynamic optimization of the simplified SMB
// process developed in Diehl and Walther (2006). The problem discretizes
// the column as a set of mixing tanks. 6 columns are used and the two
// components mix at different rates.
// AMPL model written by  L. T. Biegler/ CMU, Jan. 9, 2007
//
// transferred to C by A. Walther / TU Dresden, Jun 5 2007

//#define nel 2
//#define ndis  2                     // =>
//#define cstr 406
//#define nel 5
//#define ndis  10                     // =>
//#define cstr 4375
//#define ndis  15                     // =>
//#define cstr 12925
//#define ndis  20                     // =>
//#define cstr 8575
//#define ndis  30                     // =>  n = 12780
//#define cstr 12775
//#define ndis  40                     // =>  n = 16980
//#define cstr 16980
//#define ndis  50                     // =>  n = 16980
//#define cstr 21175
//#define ndis  60                     // =>  n = 25380
//#define cstr 25380

//#define nel 10
//#define ndis 10                      // =>  n = 8755
//#define cstr 8750
//#define ndis  15                     // =>  n = 12955
//#define cstr 25845
//#define ndis  20                     // => n = 17155
//#define cstr 17150
//#define ndis  30                     // => n = 25555
//#define cstr 25550
//#define ndis  40                     // => n = 33955
//#define cstr 33950
//#define ndis  50                     // => n = 42355
//#define cstr 84645
//#define ndis  60                     // => n = 50755
//#define cstr  50750


// ad2008:
#define nel 5
// 1
//#define ndis  10                     // =>
//#define cstr 4375
// 2
#define ndis  20                     // =>
#define cstr 8575
// 3
//#define ndis  40                     // =>  n = 16980
//#define cstr 16975
// 4
//#define ndis  60                     // =>  n = 25380
//#define cstr 25375

//#define nel 10
// 11 replaces 3
//#define ndis  20                     // => n = 17155
//#define cstr 17150
//12  replaces 4
//#define ndis  30                     // => n = 25555
//#define cstr 25550
// 5
//#define ndis  60                     // => n = 50755
//#define cstr  50750

// 6
//#define nel 15
//#define ndis 60                        // => n = 76115
//#define cstr  76120

// 7
//#define nel 20
//#define ndis 60                        // => n = 101505
//#define cstr  101495

// 8
//#define nel 30
//#define ndis 60                        // => n = 152255
//#define cstr  152245

// 9
//#define nel 40
//#define ndis 80                        // => n = 270205
//#define cstr  270195

// 10
//#define nel 60
//#define ndis 100                        // => n = 506105
//#define cstr  506095

#define n1 1
#define n2 2
#define n3 2
#define n4 1
#define ncol 6

#define nex (ndis * n1)
#define nfe ((n1 + n2) * ndis)
#define nra ((n1 + n2 + n3) * ndis)
#define nde ((n1 + n2 + n3 + n4) * ndis)

#define pex 0.95
#define pra 0.95

#define kA (2*ndis)
#define kB  ndis

#define cFEA  0.1
#define cFEB  0.1

#define qmax 2



double kk = 0;

double omega[3][3];

double h[nel];

//******************************************************************
// Initialize dimensions

void init_dim(int *n, int *m)
{

  //       cA, cB,cAdot, cBdot    cA0 cB0       m*A,m*B,m*Adot,m*Bdot   m*A0,m*B0
  *n = 5 + 4*(nde*nel*3)        + 2*(nde*nel) + 8*(nel*3)                 + 4*nel
     + 2*nel*3     + nel;
  //   mfe,mfedot    mfe0
  *m = cstr-5;

}

//******************************************************************
// Initialize starting point x

void init_startpoint(double *x, int n)
{
  int i,j,l;
  int index;

  omega[0][0] = 0.19681547722366;
  omega[0][1] = 0.39442431473909;
  omega[0][2] = 0.37640306270047;
  omega[1][0] =-0.06553542585020;
  omega[1][1] = 0.29207341166523;
  omega[1][2] = 0.51248582618842;
  omega[2][0] = 0.02377097434822;
  omega[2][1] =-0.04154875212600;
  omega[2][2] = 0.11111111111111;

  for(i=0;i<nel;i++)
    h[i] = 1.0/nel;

  x[0] = 2;
  x[1] = 0.5;
  x[2] = 0.5;
  x[3] = 0.5;
  x[4] = 1;

  index = 5;
  for(l=0;l<nde;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    x[index] = cFEA;
	    index++;
	    x[index] = cFEB;
	    index++;
	    x[index] = 1;
	    index++;
	    x[index] = 1;
	    index++;
	  }
	x[index] = cFEA;
	index++;
	x[index] = cFEB;
	index++;
      }

  for(i=index;i<n;i++)
    x[i] = 1;
}

//******************************************************************
//***************    Function Evaluation   *************************
//*************** Lagrange function of optimization ****************
//******************************************************************

double feval(double *x, int n)
{
  double cA[nde][nel][3],cB[nde][nel][3],cAdot[nde][nel][3],cBdot[nde][nel][3];
  double cA0[nde][nel],cB0[nde][nel];
  double mexA[nel][3],mexB[nel][3],mexAdot[nel][3],mexBdot[nel][3];
  double mexA0[nel],mexB0[nel];
  double mraA[nel][3],mraB[nel][3],mraAdot[nel][3],mraBdot[nel][3];
  double mraA0[nel],mraB0[nel];
  double mfe[nel][3],mfedot[nel][3];
  double mfe0[nel];

  double q1,qde,qfe,qex,time;
  double q2,q3,q4,qra;

  double res;
  double c[cstr],lam[cstr];

  double sum, test;

  int index;
  int i,j,l,k;

  q1 = x[0]; qde = x[1]; qfe = x[2]; qex = x[3]; time = x[4];

  q2 = q1 - qex;
  q3 = q1 - qex + qfe;
  q4 = q1 - qde;
  qra = qde - qex + qfe;

  index = 5;
  for(l=0;l<nde;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    cA[l][i][j] = x[index];
	    index++;
	    cB[l][i][j] = x[index];
	    index++;
	    cAdot[l][i][j] = x[index];
	    index++;
	    cBdot[l][i][j] = x[index];
	    index++;
	  }
	cA0[l][i] = x[index];
	index++;
	cB0[l][i] = x[index];
	index++;
      }

  for(i=0;i<nel;i++)
    {
      for(j=0;j<3;j++)
	{
	  mexA[i][j] = x[index];
	  index++;
	  mexB[i][j] = x[index];
	  index++;
	  mexAdot[i][j] = x[index];
	  index++;
	  mexBdot[i][j] = x[index];
	  index++;
	  mraA[i][j] = x[index];
	  index++;
	  mraB[i][j] = x[index];
	  index++;
	  mraAdot[i][j] = x[index];
	  index++;
	  mraBdot[i][j] = x[index];
	  index++;
	  mfe[i][j] = x[index];
	  index++;
	  mfedot[i][j] = x[index];
	  index++;
	}
      mexA0[i] = x[index];
      index++;
      mexB0[i] = x[index];
      index++;
      mraA0[i] = x[index];
      index++;
      mraB0[i] = x[index];
      index++;
      mfe0[i] = x[index];
      index++;
    }

  // target function

  res = -mfe[nel-1][2]/time;

  // constraints

  index = 0;

  for(l=0;l<nde;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    sum = 0;
	    for(k=0;k<3;k++)
	      sum += omega[k][j]*cAdot[l][i][k];
	    c[index] = cA[l][i][j] - cA0[l][i]+time*h[i]*sum;
	    index++;
	    sum = 0;
	    for(k=0;k<3;k++)
	      sum += omega[k][j]*cBdot[l][i][k];
	    c[index] = cB[l][i][j] - cB0[l][i]+time*h[i]*sum;
	    index++;
	  }
      }

  for(l=0;l<nde;l++)
    for(i=1;i<nel;i++)
      {
	sum = 0;
	for(j=0;j<3;j++)
	  sum += omega[j][2]*cAdot[l][i-1][j];
	c[index] = cA0[l][i] - cA0[l][i-1] + time*h[i-1]*sum;
	index++;
	sum = 0;
	for(j=0;j<3;j++)
	  sum += omega[j][2]*cBdot[l][i-1][j];
	c[index] = cB0[l][i] - cB0[l][i-1] + time*h[i-1]*sum;
	index++;
      }

  for(i=0;i<nel;i++)
    {
      for(j=0;j<3;j++)
	{
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mexAdot[i][k];
	  c[index] = mexA[i][j] - mexA0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mexBdot[i][k];
	  c[index] = mexB[i][j] - mexB0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mraAdot[i][k];
	  c[index] = mraA[i][j] - mraA0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mraBdot[i][k];
	  c[index] = mraB[i][j] - mraB0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mfedot[i][k];
	  c[index] = mfe[i][j]-mfe0[i]+time*h[i]*sum;
	  index++;

	  c[index] = cAdot[0][i][j] - kA*(q4*cA[nde-1][i][j]-q1*cA[0][i][j])*
                            (2*(1 + kk*cA[0][ i][ j])*(1 + kk*cA[0][ i][ j]))/ (1+(1 +kk*cA[0][i][j])*(1 +kk*cA[0][i][j]));
	  index++;
	  c[index] = cBdot[0][i][j] - kB*(q4*cB[nde-1][i][j]-q1*cB[0][i][j])*
                            (2*(1 + kk*cB[0][ i][ j])*(1 + kk*cB[0][ i][ j]))/ (1+(1 +kk*cB[0][i][j])*(1 +kk*cB[0][i][j]));
	  index++;

	  c[index] = cAdot[nfe][i][j] - kA*(q2*cA[nfe-1][i][j] + qfe*cFEA -
                q3*cA[nfe][i][j])*(2*(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j]))/
	        (1+(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j]));
	  index++;
	  c[index] = cBdot[nfe][i][j] - kB*(q2*cB[nfe-1][i][j] + qfe*cFEB -
                q3*cB[nfe][i][j])*(2*(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j]))/
	        (1+(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j]));
	  index++;

	  c[index] = mexAdot[i][j] - qex*cA[nex-1][ i][j];
	  index++;
	  c[index] = mexBdot[i][j] - qex*cB[nex-1][ i][j];
	  index++;
	  c[index] = mraAdot[i][j] - qra*cA[nra-1][ i][j];
	  index++;
	  c[index] = mraBdot[i][j] - qra*cB[nra-1][ i][j];
	  index++;
	  c[index] = mfedot[i][j] - qfe;
	  index++;

	}
    }

  for(i=1;i<nel;i++)
    {
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mexAdot[i-1][j];
      c[index] = mexA0[i] - mexA0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mexBdot[i-1][j];
      c[index] = mexB0[i] - mexB0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mraAdot[i-1][j];
      c[index] = mraA0[i] - mraA0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mraBdot[i-1][j];
      c[index] = mraB0[i] - mraB0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mfedot[i-1][j];
      c[index] = mfe0[i] - mfe0[i-1] + time*h[i-1]*sum;
      index++;
    }

  for(l=1;l<nex-1;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q1*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q1*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }
  for(l=nex-1;l<nfe;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q2*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q2*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }

  for(l=nfe+1;l<nra;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q3*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q3*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }

  for(l=nra;l<nde;l++)
    {
      for(i=0;i<nel;i++)
	{
	  for(j=0;j<3;j++)
	    {
	      c[index] = cAdot[l][i][j] - kA*q4*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
		(1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	      index++;
	      c[index] = cBdot[l][i][j] - kB*q4*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
		(1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	      index++;
	    }
	}
      c[index] = cA0[l][0] - cA[l-nra][nel-1][2];
      index++;
      c[index] = cB0[l][0] - cB[l-nra][nel-1][2];
      index++;
    }

  for(l=0;l<nra;l++)
    {
      c[index] = cA0[l][0] - cA[l+ndis][nel-1][2];
      index++;
      c[index] = cB0[l][0] - cB[l+ndis][nel-1][2];
      index++;
    }

  c[index] = mexA0[0];
  index++;
  c[index] = mexB0[0];
  index++;
  c[index] = mraA0[0];
  index++;
  c[index] = mraB0[0];
  index++;
  c[index] = mfe0[0];
  index++;

  //printf(" f index %d \n",index);

  for(i=0;i<cstr;i++)
    lam[i] = 1;

  for(i=0;i<cstr;i++)
    res += lam[i]*c[i];

  return res;
}


//**************       active version      ************************


adouble feval_ad(double *x, int n)
{
  adouble cA[nde][nel][3],cB[nde][nel][3],cAdot[nde][nel][3],cBdot[nde][nel][3];
  adouble cA0[nde][nel],cB0[nde][nel];
  adouble mexA[nel][3],mexB[nel][3],mexAdot[nel][3],mexBdot[nel][3];
  adouble mexA0[nel],mexB0[nel];
  adouble mraA[nel][3],mraB[nel][3],mraAdot[nel][3],mraBdot[nel][3];
  adouble mraA0[nel],mraB0[nel];
  adouble mfe[nel][3],mfedot[nel][3];
  adouble mfe0[nel];

  adouble q1,qde,qfe,qex,time;
  adouble q2,q3,q4,qra;

  adouble res;
  adouble c[cstr];
  double lam[cstr];
  adouble sum;

  int index;
  int i,j,l,k;

  q1 <<= x[0]; qde <<= x[1]; qfe <<= x[2]; qex <<= x[3]; time <<= x[4];

  q2 = q1 - qex;
  q3 = q1 - qex + qfe;
  q4 = q1 - qde;
  qra = qde - qex + qfe;

  index = 5;
  for(l=0;l<nde;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    cA[l][i][j] <<= x[index];
	    index++;
	    cB[l][i][j] <<= x[index];
	    index++;
	    cAdot[l][i][j] <<= x[index];
	    index++;
	    cBdot[l][i][j] <<= x[index];
	    index++;
	  }
	cA0[l][i] <<= x[index];
	index++;
	cB0[l][i] <<= x[index];
	index++;
      }

  for(i=0;i<nel;i++)
    {
      for(j=0;j<3;j++)
	{
	  mexA[i][j] <<= x[index];
	  index++;
	  mexB[i][j] <<= x[index];
	  index++;
	  mexAdot[i][j] <<= x[index];
	  index++;
	  mexBdot[i][j] <<= x[index];
	  index++;
	  mraA[i][j] <<= x[index];
	  index++;
	  mraB[i][j] <<= x[index];
	  index++;
	  mraAdot[i][j] <<= x[index];
	  index++;
	  mraBdot[i][j] <<= x[index];
	  index++;
	  mfe[i][j] <<= x[index];
	  index++;
	  mfedot[i][j] <<= x[index];
	  index++;
	}
      mexA0[i] <<= x[index];
      index++;
      mexB0[i] <<= x[index];
      index++;
      mraA0[i] <<= x[index];
      index++;
      mraB0[i] <<= x[index];
      index++;
      mfe0[i] <<= x[index];
      index++;
    }

  res = -mfe[nel-1][2]/time;

  index = 0;

  for(l=0;l<nde;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    sum = 0;
	    for(k=0;k<3;k++)
	      sum += omega[k][j]*cAdot[l][i][k];
	    c[index] = cA[l][i][j] - cA0[l][i]+time*h[i]*sum;
	    index++;
	    sum = 0;
	    for(k=0;k<3;k++)
	      sum += omega[k][j]*cBdot[l][i][k];
	    c[index] = cB[l][i][j] - cB0[l][i]+time*h[i]*sum;
	    index++;
	  }
      }

  for(l=0;l<nde;l++)
    for(i=1;i<nel;i++)
      {
	sum = 0;
	for(j=0;j<3;j++)
	  sum += omega[j][2]*cAdot[l][i-1][j];
	c[index] = cA0[l][i] - cA0[l][i-1] + time*h[i-1]*sum;
	index++;
	sum = 0;
	for(j=0;j<3;j++)
	  sum += omega[j][2]*cBdot[l][i-1][j];
	c[index] = cB0[l][i] - cB0[l][i-1] + time*h[i-1]*sum;
	index++;
      }

  for(i=0;i<nel;i++)
    {
      for(j=0;j<3;j++)
	{
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mexAdot[i][k];
	  c[index] = mexA[i][j] - mexA0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mexBdot[i][k];
	  c[index] = mexB[i][j] - mexB0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mraAdot[i][k];
	  c[index] = mraA[i][j] - mraA0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mraBdot[i][k];
	  c[index] = mraB[i][j] - mraB0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mfedot[i][k];
	  c[index] = mfe[i][j]-mfe0[i]+time*h[i]*sum;
	  index++;

	  c[index] = cAdot[0][i][j] - kA*(q4*cA[nde-1][i][j]-q1*cA[0][i][j])*
	    (2*(1 + kk*cA[0][ i][ j])*(1 + kk*cA[0][ i][ j]))/ (1+(1 +kk*cA[0][i][j])*(1 +kk*cA[0][i][j]));
	  index++;
	  c[index] = cBdot[0][i][j] - kB*(q4*cB[nde-1][i][j]-q1*cB[0][i][j])*
	    (2*(1 + kk*cB[0][ i][ j])*(1 + kk*cB[0][ i][ j]))/ (1+(1 +kk*cB[0][i][j])*(1 +kk*cB[0][i][j]));
	  index++;

	  c[index] = cAdot[nfe][i][j] - kA*(q2*cA[nfe-1][i][j] + qfe*cFEA -
                q3*cA[nfe][i][j])*(2*(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j]))/
	        (1+(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j]));
	  index++;
	  c[index] = cBdot[nfe][i][j] - kB*(q2*cB[nfe-1][i][j] + qfe*cFEB -
                q3*cB[nfe][i][j])*(2*(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j]))/
	        (1+(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j]));
	  index++;

	  c[index] = mexAdot[i][j] - qex*cA[nex-1][ i][j];
	  index++;
	  c[index] = mexBdot[i][j] - qex*cB[nex-1][ i][j];
	  index++;
	  c[index] = mraAdot[i][j] - qra*cA[nra-1][ i][j];
	  index++;
	  c[index] = mraBdot[i][j] - qra*cB[nra-1][ i][j];
	  index++;
	  c[index] = mfedot[i][j] - qfe;
	  index++;
	}
    }

  for(i=1;i<nel;i++)
    {
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mexAdot[i-1][j];
      c[index] = mexA0[i] - mexA0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mexBdot[i-1][j];
      c[index] = mexB0[i] - mexB0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mraAdot[i-1][j];
      c[index] = mraA0[i] - mraA0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mraBdot[i-1][j];
      c[index] = mraB0[i] - mraB0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mfedot[i-1][j];
      c[index] = mfe0[i] - mfe0[i-1] + time*h[i-1]*sum;
      index++;
    }

  for(l=1;l<nex-1;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q1*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q1*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }

  for(l=nex-1;l<nfe;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q2*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q2*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }

  for(l=nfe+1;l<nra;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q3*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q3*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }

  for(l=nra;l<nde;l++)
    {
      for(i=0;i<nel;i++)
	{
	  for(j=0;j<3;j++)
	    {
	      c[index] = cAdot[l][i][j] - kA*q4*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
		(1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	      index++;
	      c[index] = cBdot[l][i][j] - kB*q4*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
		(1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	      index++;
	    }
	}
      c[index] = cA0[l][0] - cA[l-nra][nel-1][2];
      index++;
      c[index] = cB0[l][0] - cB[l-nra][nel-1][2];
      index++;
    }

  for(l=0;l<nra;l++)
    {
      c[index] = cA0[l][0] - cA[l+ndis][nel-1][2];
      index++;
      c[index] = cB0[l][0] - cB[l+ndis][nel-1][2];
      index++;
    }

  c[index] = mexA0[0];
  index++;
  c[index] = mexB0[0];
  index++;
  c[index] = mraA0[0];
  index++;
  c[index] = mraB0[0];
  index++;
  c[index] = mfe0[0];
  index++;


  for(i=0;i<cstr;i++)
    {
      lam[i] = 1;
    }

  for(i=0;i<cstr;i++)
    {
      res += lam[i]*c[i];
    }

  return res;

}

//******************************************************************
//***************    Constraint Evaluation   ***********************
//*************** constraints of optimization       ****************
//******************************************************************

void ceval(double *x, double *c, int n)
{
  double cA[nde][nel][3],cB[nde][nel][3],cAdot[nde][nel][3],cBdot[nde][nel][3];
  double cA0[nde][nel],cB0[nde][nel];
  double mexA[nel][3],mexB[nel][3],mexAdot[nel][3],mexBdot[nel][3];
  double mexA0[nel],mexB0[nel];
  double mraA[nel][3],mraB[nel][3],mraAdot[nel][3],mraBdot[nel][3];
  double mraA0[nel],mraB0[nel];
  double mfe[nel][3],mfedot[nel][3];
  double mfe0[nel];

  double q1,qde,qfe,qex,time;
  double q2,q3,q4,qra;

  double sum, test;

  int index;
  int i,j,l,k;

  q1 = x[0]; qde = x[1]; qfe = x[2]; qex = x[3]; time = x[4];

  q2 = q1 - qex;
  q3 = q1 - qex + qfe;
  q4 = q1 - qde;
  qra = qde - qex + qfe;

  index = 5;
  for(l=0;l<nde;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    cA[l][i][j] = x[index];
	    index++;
	    cB[l][i][j] = x[index];
	    index++;
	    cAdot[l][i][j] = x[index];
	    index++;
	    cBdot[l][i][j] = x[index];
	    index++;
	  }
	cA0[l][i] = x[index];
	index++;
	cB0[l][i] = x[index];
	index++;
      }

  for(i=0;i<nel;i++)
    {
      for(j=0;j<3;j++)
	{
	  mexA[i][j] = x[index];
	  index++;
	  mexB[i][j] = x[index];
	  index++;
	  mexAdot[i][j] = x[index];
	  index++;
	  mexBdot[i][j] = x[index];
	  index++;
	  mraA[i][j] = x[index];
	  index++;
	  mraB[i][j] = x[index];
	  index++;
	  mraAdot[i][j] = x[index];
	  index++;
	  mraBdot[i][j] = x[index];
	  index++;
	  mfe[i][j] = x[index];
	  index++;
	  mfedot[i][j] = x[index];
	  index++;
	}
      mexA0[i] = x[index];
      index++;
      mexB0[i] = x[index];
      index++;
      mraA0[i] = x[index];
      index++;
      mraB0[i] = x[index];
      index++;
      mfe0[i] = x[index];
      index++;
    }

  // constraints

  index = 0;

  for(l=0;l<nde;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    sum = 0;
	    for(k=0;k<3;k++)
	      sum += omega[k][j]*cAdot[l][i][k];
	    c[index] = cA[l][i][j] - cA0[l][i]+time*h[i]*sum;
	    index++;
	    sum = 0;
	    for(k=0;k<3;k++)
	      sum += omega[k][j]*cBdot[l][i][k];
	    c[index] = cB[l][i][j] - cB0[l][i]+time*h[i]*sum;
	    index++;
	  }
      }

  for(l=0;l<nde;l++)
    for(i=1;i<nel;i++)
      {
	sum = 0;
	for(j=0;j<3;j++)
	  sum += omega[j][2]*cAdot[l][i-1][j];
	c[index] = cA0[l][i] - cA0[l][i-1] + time*h[i-1]*sum;
	index++;
	sum = 0;
	for(j=0;j<3;j++)
	  sum += omega[j][2]*cBdot[l][i-1][j];
	c[index] = cB0[l][i] - cB0[l][i-1] + time*h[i-1]*sum;
	index++;
      }

  for(i=0;i<nel;i++)
    {
      for(j=0;j<3;j++)
	{
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mexAdot[i][k];
	  c[index] = mexA[i][j] - mexA0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mexBdot[i][k];
	  c[index] = mexB[i][j] - mexB0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mraAdot[i][k];
	  c[index] = mraA[i][j] - mraA0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mraBdot[i][k];
	  c[index] = mraB[i][j] - mraB0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mfedot[i][k];
	  c[index] = mfe[i][j]-mfe0[i]+time*h[i]*sum;
	  index++;

	  c[index] = cAdot[0][i][j] - kA*(q4*cA[nde-1][i][j]-q1*cA[0][i][j])*
                            (2*(1 + kk*cA[0][ i][ j])*(1 + kk*cA[0][ i][ j]))/ (1+(1 +kk*cA[0][i][j])*(1 +kk*cA[0][i][j]));
	  index++;
	  c[index] = cBdot[0][i][j] - kB*(q4*cB[nde-1][i][j]-q1*cB[0][i][j])*
                            (2*(1 + kk*cB[0][ i][ j])*(1 + kk*cB[0][ i][ j]))/ (1+(1 +kk*cB[0][i][j])*(1 +kk*cB[0][i][j]));
	  index++;

	  c[index] = cAdot[nfe][i][j] - kA*(q2*cA[nfe-1][i][j] + qfe*cFEA -
                q3*cA[nfe][i][j])*(2*(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j]))/
	        (1+(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j]));
	  index++;
	  c[index] = cBdot[nfe][i][j] - kB*(q2*cB[nfe-1][i][j] + qfe*cFEB -
                q3*cB[nfe][i][j])*(2*(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j]))/
	        (1+(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j]));
	  index++;

	  c[index] = mexAdot[i][j] - qex*cA[nex-1][ i][j];
	  index++;
	  c[index] = mexBdot[i][j] - qex*cB[nex-1][ i][j];
	  index++;
	  c[index] = mraAdot[i][j] - qra*cA[nra-1][ i][j];
	  index++;
	  c[index] = mraBdot[i][j] - qra*cB[nra-1][ i][j];
	  index++;
	  c[index] = mfedot[i][j] - qfe;
	  index++;

	}
    }

  for(i=1;i<nel;i++)
    {
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mexAdot[i-1][j];
      c[index] = mexA0[i] - mexA0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mexBdot[i-1][j];
      c[index] = mexB0[i] - mexB0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mraAdot[i-1][j];
      c[index] = mraA0[i] - mraA0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mraBdot[i-1][j];
      c[index] = mraB0[i] - mraB0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mfedot[i-1][j];
      c[index] = mfe0[i] - mfe0[i-1] + time*h[i-1]*sum;
      index++;
    }

  for(l=1;l<nex-1;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q1*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q1*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }
  for(l=nex-1;l<nfe;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q2*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q2*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }

  for(l=nfe+1;l<nra;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q3*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q3*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }

  for(l=nra;l<nde;l++)
    {
      for(i=0;i<nel;i++)
	{
	  for(j=0;j<3;j++)
	    {
	      c[index] = cAdot[l][i][j] - kA*q4*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
		(1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	      index++;
	      c[index] = cBdot[l][i][j] - kB*q4*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
		(1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	      index++;
	    }
	}
      c[index] = cA0[l][0] - cA[l-nra][nel-1][2];
      index++;
      c[index] = cB0[l][0] - cB[l-nra][nel-1][2];
      index++;
    }

  for(l=0;l<nra;l++)
    {
      c[index] = cA0[l][0] - cA[l+ndis][nel-1][2];
      index++;
      c[index] = cB0[l][0] - cB[l+ndis][nel-1][2];
      index++;
    }


}


//**************       active version      ************************


void ceval_ad(double *x, adouble *c, int n)
{
  adouble cA[nde][nel][3],cB[nde][nel][3],cAdot[nde][nel][3],cBdot[nde][nel][3];
  adouble cA0[nde][nel],cB0[nde][nel];
  adouble mexA[nel][3],mexB[nel][3],mexAdot[nel][3],mexBdot[nel][3];
  adouble mexA0[nel],mexB0[nel];
  adouble mraA[nel][3],mraB[nel][3],mraAdot[nel][3],mraBdot[nel][3];
  adouble mraA0[nel],mraB0[nel];
  adouble mfe[nel][3],mfedot[nel][3];
  adouble mfe0[nel];

  adouble q1,qde,qfe,qex,time;
  adouble q2,q3,q4,qra;

  adouble sum;

  int index;
  int i,j,l,k;

  q1 <<= x[0]; qde <<= x[1]; qfe <<= x[2]; qex <<= x[3]; time <<= x[4];

  q2 = q1 - qex;
  q3 = q1 - qex + qfe;
  q4 = q1 - qde;
  qra = qde - qex + qfe;

  index = 5;
  for(l=0;l<nde;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    cA[l][i][j] <<= x[index];
	    index++;
	    cB[l][i][j] <<= x[index];
	    index++;
	    cAdot[l][i][j] <<= x[index];
	    index++;
	    cBdot[l][i][j] <<= x[index];
	    index++;
	  }
	cA0[l][i] <<= x[index];
	index++;
	cB0[l][i] <<= x[index];
	index++;
      }

  for(i=0;i<nel;i++)
    {
      for(j=0;j<3;j++)
	{
	  mexA[i][j] <<= x[index];
	  index++;
	  mexB[i][j] <<= x[index];
	  index++;
	  mexAdot[i][j] <<= x[index];
	  index++;
	  mexBdot[i][j] <<= x[index];
	  index++;
	  mraA[i][j] <<= x[index];
	  index++;
	  mraB[i][j] <<= x[index];
	  index++;
	  mraAdot[i][j] <<= x[index];
	  index++;
	  mraBdot[i][j] <<= x[index];
	  index++;
	  mfe[i][j] <<= x[index];
	  index++;
	  mfedot[i][j] <<= x[index];
	  index++;
	}
      mexA0[i] <<= x[index];
      index++;
      mexB0[i] <<= x[index];
      index++;
      mraA0[i] <<= x[index];
      index++;
      mraB0[i] <<= x[index];
      index++;
      mfe0[i] <<= x[index];
      index++;
    }


  index = 0;

  for(l=0;l<nde;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    sum = 0;
	    for(k=0;k<3;k++)
	      sum += omega[k][j]*cAdot[l][i][k];
	    c[index] = cA[l][i][j] - cA0[l][i]+time*h[i]*sum;
	    index++;
	    sum = 0;
	    for(k=0;k<3;k++)
	      sum += omega[k][j]*cBdot[l][i][k];
	    c[index] = cB[l][i][j] - cB0[l][i]+time*h[i]*sum;
	    index++;
	  }
      }

  for(l=0;l<nde;l++)
    for(i=1;i<nel;i++)
      {
	sum = 0;
	for(j=0;j<3;j++)
	  sum += omega[j][2]*cAdot[l][i-1][j];
	c[index] = cA0[l][i] - cA0[l][i-1] + time*h[i-1]*sum;
	index++;
	sum = 0;
	for(j=0;j<3;j++)
	  sum += omega[j][2]*cBdot[l][i-1][j];
	c[index] = cB0[l][i] - cB0[l][i-1] + time*h[i-1]*sum;
	index++;
      }

  for(i=0;i<nel;i++)
    {
      for(j=0;j<3;j++)
	{
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mexAdot[i][k];
	  c[index] = mexA[i][j] - mexA0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mexBdot[i][k];
	  c[index] = mexB[i][j] - mexB0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mraAdot[i][k];
	  c[index] = mraA[i][j] - mraA0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mraBdot[i][k];
	  c[index] = mraB[i][j] - mraB0[i]+time*h[i]*sum;
	  index++;
	  sum = 0;
	  for(k=0;k<3;k++)
	    sum += omega[k][j]*mfedot[i][k];
	  c[index] = mfe[i][j]-mfe0[i]+time*h[i]*sum;
	  index++;

	  c[index] = cAdot[0][i][j] - kA*(q4*cA[nde-1][i][j]-q1*cA[0][i][j])*
	    (2*(1 + kk*cA[0][ i][ j])*(1 + kk*cA[0][ i][ j]))/ (1+(1 +kk*cA[0][i][j])*(1 +kk*cA[0][i][j]));
	  index++;
	  c[index] = cBdot[0][i][j] - kB*(q4*cB[nde-1][i][j]-q1*cB[0][i][j])*
	    (2*(1 + kk*cB[0][ i][ j])*(1 + kk*cB[0][ i][ j]))/ (1+(1 +kk*cB[0][i][j])*(1 +kk*cB[0][i][j]));
	  index++;

	  c[index] = cAdot[nfe][i][j] - kA*(q2*cA[nfe-1][i][j] + qfe*cFEA -
                q3*cA[nfe][i][j])*(2*(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j]))/
	        (1+(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j]));
	  index++;
	  c[index] = cBdot[nfe][i][j] - kB*(q2*cB[nfe-1][i][j] + qfe*cFEB -
                q3*cB[nfe][i][j])*(2*(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j]))/
	        (1+(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j]));
	  index++;

	  c[index] = mexAdot[i][j] - qex*cA[nex-1][ i][j];
	  index++;
	  c[index] = mexBdot[i][j] - qex*cB[nex-1][ i][j];
	  index++;
	  c[index] = mraAdot[i][j] - qra*cA[nra-1][ i][j];
	  index++;
	  c[index] = mraBdot[i][j] - qra*cB[nra-1][ i][j];
	  index++;
	  c[index] = mfedot[i][j] - qfe;
	  index++;
	}
    }

  for(i=1;i<nel;i++)
    {
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mexAdot[i-1][j];
      c[index] = mexA0[i] - mexA0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mexBdot[i-1][j];
      c[index] = mexB0[i] - mexB0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mraAdot[i-1][j];
      c[index] = mraA0[i] - mraA0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mraBdot[i-1][j];
      c[index] = mraB0[i] - mraB0[i-1] + time*h[i-1]*sum;
      index++;
      sum = 0;
      for(j=0;j<3;j++)
	sum += omega[j][2]*mfedot[i-1][j];
      c[index] = mfe0[i] - mfe0[i-1] + time*h[i-1]*sum;
      index++;
    }

  for(l=1;l<nex-1;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q1*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q1*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }

  for(l=nex-1;l<nfe;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q2*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q2*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }

  for(l=nfe+1;l<nra;l++)
    for(i=0;i<nel;i++)
      {
	for(j=0;j<3;j++)
	  {
	    c[index] = cAdot[l][i][j] - kA*q3*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	    index++;
	    c[index] = cBdot[l][i][j] - kB*q3*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	    index++;
	  }
      }

  for(l=nra;l<nde;l++)
    {
      for(i=0;i<nel;i++)
	{
	  for(j=0;j<3;j++)
	    {
	      c[index] = cAdot[l][i][j] - kA*q4*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/
		(1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]));
	      index++;
	      c[index] = cBdot[l][i][j] - kB*q4*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/
		(1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]));
	      index++;
	    }
	}
      c[index] = cA0[l][0] - cA[l-nra][nel-1][2];
      index++;
      c[index] = cB0[l][0] - cB[l-nra][nel-1][2];
      index++;
    }

  for(l=0;l<nra;l++)
    {
      c[index] = cA0[l][0] - cA[l+ndis][nel-1][2];
      index++;
      c[index] = cB0[l][0] - cB[l+ndis][nel-1][2];
      index++;
    }

  printf(" in ceval_ad index %d \n",index);
/*   for(i=0;i<cstr-5;i++) */
/*     { */
/*       printf("%d %e \n",i,c[i].value()); */
/*     } */
}


/* //\**************       active version      ************************ */


/* adouble feval_ad_mod(double *x, int n) */
/* { */
/*   adouble cA[nde][nel][3],cB[nde][nel][3],cAdot[nde][nel][3],cBdot[nde][nel][3]; */
/*   adouble cA0[nde][nel],cB0[nde][nel]; */
/*   adouble mexA[nel][3],mexB[nel][3],mexAdot[nel][3],mexBdot[nel][3]; */
/*   adouble mexA0[nel],mexB0[nel]; */
/*   adouble mraA[nel][3],mraB[nel][3],mraAdot[nel][3],mraBdot[nel][3]; */
/*   adouble mraA0[nel],mraB0[nel]; */
/*   adouble mfe[nel][3],mfedot[nel][3]; */
/*   adouble mfe0[nel]; */

/*   adouble q1,qde,qfe,qex,time; */
/*   adouble q2,q3,q4,qra; */

/*   adouble res; */
/*   adouble c[cstr]; */
/*   double lam[cstr]; */
/*   adouble sum; */

/*   int index; */
/*   int i,j,l,k; */

/*   q1 = x[0]; qde = x[1]; qfe = x[2]; qex = x[3]; time = x[4]; */

/*   q2 = q1 - qex;  */
/*   q3 = q1 - qex + qfe;  */
/*   q4 = q1 - qde;  */
/*   qra = qde - qex + qfe;  */

/*   index = 5; */
/*   for(l=0;l<nde;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    cA[l][i][j] <<= x[index]; */
/* 	    index++; */
/* 	    cB[l][i][j] <<= x[index]; */
/* 	    index++; */
/* 	    cAdot[l][i][j] <<= x[index]; */
/* 	    index++; */
/* 	    cBdot[l][i][j] <<= x[index]; */
/* 	    index++; */
/* 	  } */
/* 	cA0[l][i] <<= x[index]; */
/* 	index++; */
/* 	cB0[l][i] <<= x[index]; */
/* 	index++; */
/*       } */

/*   for(i=0;i<nel;i++) */
/*     { */
/*       for(j=0;j<3;j++) */
/* 	{ */
/* 	  mexA[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mexB[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mexAdot[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mexBdot[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mraA[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mraB[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mraAdot[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mraBdot[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mfe[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mfedot[i][j] <<= x[index]; */
/* 	  index++; */
/* 	} */
/*       mexA0[i] <<= x[index]; */
/*       index++; */
/*       mexB0[i] <<= x[index]; */
/*       index++; */
/*       mraA0[i] <<= x[index]; */
/*       index++; */
/*       mraB0[i] <<= x[index]; */
/*       index++; */
/*       mfe0[i] <<= x[index]; */
/*       index++; */
/*     } */

/*   res = -mfe[nel-1][2]/time; */

/*   index = 0; */

/*   for(l=0;l<nde;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    sum = 0; */
/* 	    for(k=0;k<3;k++) */
/* 	      sum += omega[k][j]*cAdot[l][i][k]; */
/* 	    c[index] = cA[l][i][j] - cA0[l][i]+time*h[i]*sum; */
/* 	    index++; */
/* 	    sum = 0; */
/* 	    for(k=0;k<3;k++) */
/* 	      sum += omega[k][j]*cBdot[l][i][k]; */
/* 	    c[index] = cB[l][i][j] - cB0[l][i]+time*h[i]*sum; */
/* 	    index++; */
/* 	  } */
/*       } */

/*   for(l=0;l<nde;l++) */
/*     for(i=1;i<nel;i++) */
/*       { */
/* 	sum = 0; */
/* 	for(j=0;j<3;j++) */
/* 	  sum += omega[j][2]*cAdot[l][i-1][j]; */
/* 	c[index] = cA0[l][i] - cA0[l][i-1] + time*h[i-1]*sum; */
/* 	index++; */
/* 	sum = 0; */
/* 	for(j=0;j<3;j++) */
/* 	  sum += omega[j][2]*cBdot[l][i-1][j]; */
/* 	c[index] = cB0[l][i] - cB0[l][i-1] + time*h[i-1]*sum; */
/* 	index++; */
/*       } */

/*   for(i=0;i<nel;i++) */
/*     { */
/*       for(j=0;j<3;j++) */
/* 	{ */
/* 	  sum = 0; */
/* 	  for(k=0;k<3;k++) */
/* 	    sum += omega[k][j]*mexAdot[i][k]; */
/* 	  c[index] = mexA[i][j] - mexA0[i]+time*h[i]*sum; */
/* 	  index++; */
/* 	  sum = 0; */
/* 	  for(k=0;k<3;k++) */
/* 	    sum += omega[k][j]*mexBdot[i][k]; */
/* 	  c[index] = mexB[i][j] - mexB0[i]+time*h[i]*sum; */
/* 	  index++; */
/* 	  sum = 0; */
/* 	  for(k=0;k<3;k++) */
/* 	    sum += omega[k][j]*mraAdot[i][k]; */
/* 	  c[index] = mraA[i][j] - mraA0[i]+time*h[i]*sum; */
/* 	  index++; */
/* 	  sum = 0; */
/* 	  for(k=0;k<3;k++) */
/* 	    sum += omega[k][j]*mraBdot[i][k]; */
/* 	  c[index] = mraB[i][j] - mraB0[i]+time*h[i]*sum; */
/* 	  index++; */
/* 	  sum = 0; */
/* 	  for(k=0;k<3;k++) */
/* 	    sum += omega[k][j]*mfedot[i][k]; */
/* 	  c[index] = mfe[i][j]-mfe0[i]+time*h[i]*sum; */
/* 	  index++; */

/* 	  c[index] = cAdot[0][i][j] - kA*(q4*cA[nde-1][i][j]-q1*cA[0][i][j])* */
/* 	    (2*(1 + kk*cA[0][ i][ j])*(1 + kk*cA[0][ i][ j]))/ (1+(1 +kk*cA[0][i][j])*(1 +kk*cA[0][i][j])); */
/* 	  index++; */
/* 	  c[index] = cBdot[0][i][j] - kB*(q4*cB[nde-1][i][j]-q1*cB[0][i][j])* */
/* 	    (2*(1 + kk*cB[0][ i][ j])*(1 + kk*cB[0][ i][ j]))/ (1+(1 +kk*cB[0][i][j])*(1 +kk*cB[0][i][j])); */
/* 	  index++; */

/* 	  c[index] = cAdot[nfe][i][j] - kA*(q2*cA[nfe-1][i][j] + qfe*cFEA -  */
/*                 q3*cA[nfe][i][j])*(2*(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j]))/  */
/* 	        (1+(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j])); */
/* 	  index++; */
/* 	  c[index] = cBdot[nfe][i][j] - kB*(q2*cB[nfe-1][i][j] + qfe*cFEB -  */
/*                 q3*cB[nfe][i][j])*(2*(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j]))/  */
/* 	        (1+(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j])); */
/* 	  index++; */

/* 	  c[index] = mexAdot[i][j] - qex*cA[nex-1][ i][j]; */
/* 	  index++; */
/* 	  c[index] = mexBdot[i][j] - qex*cB[nex-1][ i][j]; */
/* 	  index++; */
/* 	  c[index] = mraAdot[i][j] - qra*cA[nra-1][ i][j]; */
/* 	  index++; */
/* 	  c[index] = mraBdot[i][j] - qra*cB[nra-1][ i][j]; */
/* 	  index++; */
/* 	  c[index] = mfedot[i][j] - qfe; */
/* 	  index++; */
/* 	} */
/*     } */

/*   for(i=1;i<nel;i++) */
/*     { */
/*       sum = 0; */
/*       for(j=0;j<3;j++) */
/* 	sum += omega[j][2]*mexAdot[i-1][j]; */
/*       c[index] = mexA0[i] - mexA0[i-1] + time*h[i-1]*sum; */
/*       index++; */
/*       sum = 0; */
/*       for(j=0;j<3;j++) */
/* 	sum += omega[j][2]*mexBdot[i-1][j]; */
/*       c[index] = mexB0[i] - mexB0[i-1] + time*h[i-1]*sum; */
/*       index++; */
/*       sum = 0; */
/*       for(j=0;j<3;j++) */
/* 	sum += omega[j][2]*mraAdot[i-1][j]; */
/*       c[index] = mraA0[i] - mraA0[i-1] + time*h[i-1]*sum; */
/*       index++; */
/*       sum = 0; */
/*       for(j=0;j<3;j++) */
/* 	sum += omega[j][2]*mraBdot[i-1][j]; */
/*       c[index] = mraB0[i] - mraB0[i-1] + time*h[i-1]*sum; */
/*       index++; */
/*       sum = 0; */
/*       for(j=0;j<3;j++) */
/* 	sum += omega[j][2]*mfedot[i-1][j]; */
/*       c[index] = mfe0[i] - mfe0[i-1] + time*h[i-1]*sum; */
/*       index++; */
/*     } */

/*   for(l=1;l<nex-1;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    c[index] = cAdot[l][i][j] - kA*q1*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/ */
/* 	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j])); */
/* 	    index++; */
/* 	    c[index] = cBdot[l][i][j] - kB*q1*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/ */
/* 	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j])); */
/* 	    index++; */
/* 	  } */
/*       } */

/*   for(l=nex-1;l<nfe;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    c[index] = cAdot[l][i][j] - kA*q2*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/ */
/* 	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j])); */
/* 	    index++; */
/* 	    c[index] = cBdot[l][i][j] - kB*q2*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/ */
/* 	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j])); */
/* 	    index++; */
/* 	  } */
/*       } */

/*   for(l=nfe+1;l<nra;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    c[index] = cAdot[l][i][j] - kA*q3*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/ */
/* 	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j])); */
/* 	    index++; */
/* 	    c[index] = cBdot[l][i][j] - kB*q3*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/ */
/* 	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j])); */
/* 	    index++; */
/* 	  } */
/*       } */

/*   for(l=nra;l<nde;l++) */
/*     { */
/*       for(i=0;i<nel;i++) */
/* 	{ */
/* 	  for(j=0;j<3;j++) */
/* 	    { */
/* 	      c[index] = cAdot[l][i][j] - kA*q4*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/ */
/* 		(1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j])); */
/* 	      index++; */
/* 	      c[index] = cBdot[l][i][j] - kB*q4*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/ */
/* 		(1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j])); */
/* 	      index++; */
/* 	    } */
/* 	} */
/*       c[index] = cA0[l][0] - cA[l-nra][nel-1][2]; */
/*       index++;  */
/*       c[index] = cB0[l][0] - cB[l-nra][nel-1][2]; */
/*       index++;  */
/*     } */

/*   for(l=0;l<nra;l++) */
/*     { */
/*       c[index] = cA0[l][0] - cA[l+ndis][nel-1][2]; */
/*       index++;  */
/*       c[index] = cB0[l][0] - cB[l+ndis][nel-1][2]; */
/*       index++;  */
/*     } */

/*   c[index] = mexA0[0]; */
/*   index++;  */
/*   c[index] = mexB0[0]; */
/*   index++;  */
/*   c[index] = mraA0[0]; */
/*   index++;  */
/*   c[index] = mraB0[0]; */
/*   index++;  */
/*   c[index] = mfe0[0]; */
/*   index++;  */

/*   printf(" index = %d\n",index); */

/*   for(i=0;i<cstr;i++) */
/*     lam[i] = 1; */

/*   for(i=0;i<cstr;i++) */
/*     { */
/*       res += lam[i]*c[i]; */
/*     } */

/*   return res; */

/* } */


/* //\**************       active version      ************************ */


/* adouble feval_ad_modHP(double *x, int n) */
/* { */
/*   adouble cA[nde][nel][3],cB[nde][nel][3],cAdot[nde][nel][3],cBdot[nde][nel][3]; */
/*   adouble cA0[nde][nel],cB0[nde][nel]; */
/*   adouble mexA[nel][3],mexB[nel][3],mexAdot[nel][3],mexBdot[nel][3]; */
/*   adouble mexA0[nel],mexB0[nel]; */
/*   adouble mraA[nel][3],mraB[nel][3],mraAdot[nel][3],mraBdot[nel][3]; */
/*   adouble mraA0[nel],mraB0[nel]; */
/*   adouble mfe[nel][3],mfedot[nel][3]; */
/*   adouble mfe0[nel]; */

/*   adouble q1,qde,qfe,qex,time; */
/*   adouble q2,q3,q4,qra; */

/*   adouble res; */
/*   adouble c[cstr]; */
/*   double lam[cstr]; */
/*   adouble sum; */

/*   int index; */
/*   int i,j,l,k; */

/*   q1 = x[0]; qde = x[1]; qfe = x[2]; qex = x[3]; time = x[4]; */

/*   q2 = q1 - qex;  */
/*   q3 = q1 - qex + qfe;  */
/*   q4 = q1 - qde;  */
/*   qra = qde - qex + qfe;  */

/*   index = 5; */
/*   for(l=0;l<nde;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    cA[l][i][j] <<= x[index]; */
/* 	    index++; */
/* 	    cB[l][i][j] <<= x[index]; */
/* 	    index++; */
/* 	    cAdot[l][i][j] <<= x[index]; */
/* 	    index++; */
/* 	    cBdot[l][i][j] <<= x[index]; */
/* 	    index++; */
/* 	  } */
/* 	cA0[l][i] <<= x[index]; */
/* 	index++; */
/* 	cB0[l][i] <<= x[index]; */
/* 	index++; */
/*       } */

/*   for(i=0;i<nel;i++) */
/*     { */
/*       for(j=0;j<3;j++) */
/* 	{ */
/* 	  mexA[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mexB[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mexAdot[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mexBdot[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mraA[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mraB[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mraAdot[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mraBdot[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mfe[i][j] <<= x[index]; */
/* 	  index++; */
/* 	  mfedot[i][j] <<= x[index]; */
/* 	  index++; */
/* 	} */
/*       mexA0[i] <<= x[index]; */
/*       index++; */
/*       mexB0[i] <<= x[index]; */
/*       index++; */
/*       mraA0[i] <<= x[index]; */
/*       index++; */
/*       mraB0[i] <<= x[index]; */
/*       index++; */
/*       mfe0[i] <<= x[index]; */
/*       index++; */
/*     } */

/*   res = -mfe[nel-1][2]/time; */

/*   index = 0; */

/*   for(l=0;l<nde;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    sum = 0; */
/* 	    for(k=0;k<3;k++) */
/* 	      sum += omega[k][j]*cAdot[l][i][k]; */
/* 	    c[index] = cA[l][i][j] - cA0[l][i]+time*h[i]*sum; */
/* 	    index++; */
/* 	    sum = 0; */
/* 	    for(k=0;k<3;k++) */
/* 	      sum += omega[k][j]*cBdot[l][i][k]; */
/* 	    c[index] = cB[l][i][j] - cB0[l][i]+time*h[i]*sum; */
/* 	    index++; */
/* 	  } */
/*       } */

/*   for(l=0;l<nde;l++) */
/*     for(i=1;i<nel;i++) */
/*       { */
/* 	sum = 0; */
/* 	for(j=0;j<3;j++) */
/* 	  sum += omega[j][2]*cAdot[l][i-1][j]; */
/* 	c[index] = cA0[l][i] - cA0[l][i-1] + time*h[i-1]*sum; */
/* 	index++; */
/* 	sum = 0; */
/* 	for(j=0;j<3;j++) */
/* 	  sum += omega[j][2]*cBdot[l][i-1][j]; */
/* 	c[index] = cB0[l][i] - cB0[l][i-1] + time*h[i-1]*sum; */
/* 	index++; */
/*       } */

/*   for(i=0;i<nel;i++) */
/*     { */
/*       for(j=0;j<3;j++) */
/* 	{ */
/* 	  sum = 0; */
/* 	  for(k=0;k<3;k++) */
/* 	    sum += omega[k][j]*mexAdot[i][k]; */
/* 	  c[index] = mexA[i][j] - mexA0[i]+time*h[i]*sum; */
/* 	  index++; */
/* 	  sum = 0; */
/* 	  for(k=0;k<3;k++) */
/* 	    sum += omega[k][j]*mexBdot[i][k]; */
/* 	  c[index] = mexB[i][j] - mexB0[i]+time*h[i]*sum; */
/* 	  index++; */
/* 	  sum = 0; */
/* 	  for(k=0;k<3;k++) */
/* 	    sum += omega[k][j]*mraAdot[i][k]; */
/* 	  c[index] = mraA[i][j] - mraA0[i]+time*h[i]*sum; */
/* 	  index++; */
/* 	  sum = 0; */
/* 	  for(k=0;k<3;k++) */
/* 	    sum += omega[k][j]*mraBdot[i][k]; */
/* 	  c[index] = mraB[i][j] - mraB0[i]+time*h[i]*sum; */
/* 	  index++; */
/* 	  sum = 0; */
/* 	  for(k=0;k<3;k++) */
/* 	    sum += omega[k][j]*mfedot[i][k]; */
/* 	  c[index] = mfe[i][j]-mfe0[i]+time*h[i]*sum; */
/* 	  index++; */

/* 	  c[index] = cAdot[0][i][j] - kA*(q4*cA[nde-1][i][j]-q1*cA[0][i][j])* */
/* 	    (2*(1 + kk*cA[0][ i][ j])*(1 + kk*cA[0][ i][ j]))/ (1+(1 +kk*cA[0][i][j])*(1 +kk*cA[0][i][j])); */
/* 	  index++; */
/* 	  c[index] = cBdot[0][i][j] - kB*(q4*cB[nde-1][i][j]-q1*cB[0][i][j])* */
/* 	    (2*(1 + kk*cB[0][ i][ j])*(1 + kk*cB[0][ i][ j]))/ (1+(1 +kk*cB[0][i][j])*(1 +kk*cB[0][i][j])); */
/* 	  index++; */

/* 	  c[index] = cAdot[nfe][i][j] - kA*(q2*cA[nfe-1][i][j] + qfe*cFEA -  */
/*                 q3*cA[nfe][i][j])*(2*(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j]))/  */
/* 	        (1+(1 + kk*cA[nfe][i][j])*(1 + kk*cA[nfe][i][j])); */
/* 	  index++; */
/* 	  c[index] = cBdot[nfe][i][j] - kB*(q2*cB[nfe-1][i][j] + qfe*cFEB -  */
/*                 q3*cB[nfe][i][j])*(2*(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j]))/  */
/* 	        (1+(1 + kk*cB[nfe][i][j])*(1 + kk*cB[nfe][i][j])); */
/* 	  index++; */

/* 	  c[index] = mexAdot[i][j] - qex*cA[nex-1][ i][j]; */
/* 	  index++; */
/* 	  c[index] = mexBdot[i][j] - qex*cB[nex-1][ i][j]; */
/* 	  index++; */
/* 	  c[index] = mraAdot[i][j] - qra*cA[nra-1][ i][j]; */
/* 	  index++; */
/* 	  c[index] = mraBdot[i][j] - qra*cB[nra-1][ i][j]; */
/* 	  index++; */
/* 	  c[index] = mfedot[i][j] - qfe; */
/* 	  index++; */
/* 	} */
/*     } */

/*   for(i=1;i<nel;i++) */
/*     { */
/*       sum = 0; */
/*       for(j=0;j<3;j++) */
/* 	sum += omega[j][2]*mexAdot[i-1][j]; */
/*       c[index] = mexA0[i] - mexA0[i-1] + time*h[i-1]*sum; */
/*       index++; */
/*       sum = 0; */
/*       for(j=0;j<3;j++) */
/* 	sum += omega[j][2]*mexBdot[i-1][j]; */
/*       c[index] = mexB0[i] - mexB0[i-1] + time*h[i-1]*sum; */
/*       index++; */
/*       sum = 0; */
/*       for(j=0;j<3;j++) */
/* 	sum += omega[j][2]*mraAdot[i-1][j]; */
/*       c[index] = mraA0[i] - mraA0[i-1] + time*h[i-1]*sum; */
/*       index++; */
/*       sum = 0; */
/*       for(j=0;j<3;j++) */
/* 	sum += omega[j][2]*mraBdot[i-1][j]; */
/*       c[index] = mraB0[i] - mraB0[i-1] + time*h[i-1]*sum; */
/*       index++; */
/*       sum = 0; */
/*       for(j=0;j<3;j++) */
/* 	sum += omega[j][2]*mfedot[i-1][j]; */
/*       c[index] = mfe0[i] - mfe0[i-1] + time*h[i-1]*sum; */
/*       index++; */
/*     } */

/*   for(l=1;l<nex-1;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    c[index] = cAdot[l][i][j] - kA*q1*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/ */
/* 	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j])); */
/* 	    index++; */
/* 	    c[index] = cBdot[l][i][j] - kB*q1*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/ */
/* 	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j])); */
/* 	    index++; */
/* 	  } */
/*       } */

/*   for(l=nex-1;l<nfe;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    c[index] = cAdot[l][i][j] - kA*q2*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/ */
/* 	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j])); */
/* 	    index++; */
/* 	    c[index] = cBdot[l][i][j] - kB*q2*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/ */
/* 	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j])); */
/* 	    index++; */
/* 	  } */
/*       } */

/*   for(l=nfe+1;l<nra;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    c[index] = cAdot[l][i][j] - kA*q3*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/ */
/* 	                (1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j])); */
/* 	    index++; */
/* 	    c[index] = cBdot[l][i][j] - kB*q3*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/ */
/* 	                (1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j])); */
/* 	    index++; */
/* 	  } */
/*       } */

/*   for(l=nra;l<nde;l++) */
/*     { */
/*       for(i=0;i<nel;i++) */
/* 	{ */
/* 	  for(j=0;j<3;j++) */
/* 	    { */
/* 	      c[index] = cAdot[l][i][j] - kA*q4*(cA[l-1][i][j] - cA[l][i][j])*(2*(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j]))/ */
/* 		(1+(1 + kk*cA[l][i][j])*(1 + kk*cA[l][i][j])); */
/* 	      index++; */
/* 	      c[index] = cBdot[l][i][j] - kB*q4*(cB[l-1][i][j] - cB[l][i][j])*(2*(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j]))/ */
/* 		(1+(1 + kk*cB[l][i][j])*(1 + kk*cB[l][i][j])); */
/* 	      index++; */
/* 	    } */
/* 	} */
/*       c[index] = cA0[l][0] - cA[l-nra][nel-1][2]; */
/*       index++;  */
/*       c[index] = cB0[l][0] - cB[l-nra][nel-1][2]; */
/*       index++;  */
/*     } */

/*   for(l=0;l<nra;l++) */
/*     { */
/*       c[index] = cA0[l][0] - cA[l+ndis][nel-1][2]; */
/*       index++;  */
/*       c[index] = cB0[l][0] - cB[l+ndis][nel-1][2]; */
/*       index++;  */
/*     } */

/*   c[index] = mexA0[0]; */
/*   index++;  */
/*   c[index] = mexB0[0]; */
/*   index++;  */
/*   c[index] = mraA0[0]; */
/*   index++;  */
/*   c[index] = mraB0[0]; */
/*   index++;  */
/*   c[index] = mfe0[0]; */
/*   index++;  */

/*   printf(" index = %d\n",index); */

/*   for(i=0;i<cstr;i++) */
/*     lam[i] = 1; */

/*   for(i=0;i<cstr;i++) */
/*     { */
/*       res += lam[i]*c[i]; */
/*     } */

/*   for(l=0;l<nde;l++) */
/*     for(i=0;i<nel;i++) */
/*       { */
/* 	for(j=0;j<3;j++) */
/* 	  { */
/* 	    res += cA[l][i][j]*cA[l][i][j]; */
/* 	    res += cB[l][i][j]*cB[l][i][j]; */
/* 	    res += cAdot[l][i][j]*cAdot[l][i][j]; */
/* 	    res += cBdot[l][i][j]*cBdot[l][i][j]; */
/* 	  } */
/* 	res += cA0[l][i]*cA0[l][i]; */
/* 	res += cA0[l][i]*cB0[l][i]; */
/*       } */

/*   for(i=0;i<nel;i++) */
/*     { */
/*       for(j=0;j<3;j++) */
/* 	{ */
/* 	  res += mexA[i][j]*mexA[i][j]; */
/* 	  res += mexB[i][j]*mexB[i][j]; */
/* 	  res += mexAdot[i][j]*mexAdot[i][j]; */
/* 	  res += mexBdot[i][j]*mexBdot[i][j]; */
/* 	  res += mraA[i][j]*mraA[i][j]; */
/* 	  res += mraB[i][j]*mraB[i][j]; */
/* 	  res += mraAdot[i][j]*mraAdot[i][j]; */
/* 	  res += mraBdot[i][j]*mraBdot[i][j]; */
/* 	  res += mfe[i][j]*mfe[i][j]; */
/* 	  res += mfedot[i][j]*mfedot[i][j]; */
/* 	} */
/*       res += mexA0[i]*mexA0[i]; */
/*       res += mexB0[i]*mexB0[i]; */
/*       res += mraA0[i]*mraA0[i]; */
/*       res += mraB0[i]*mraB0[i]; */
/*       res += mfe0[i]*mfe0[i]; */
/*     } */

/*   return res; */

/* } */
