/* Mutation routines */

# include <stdio.h>
# include <stdlib.h>
# include <math.h>

# include "nsga2.h"
# include "rand.h"

/* Function to perform mutation in a population */
void mutation_pop (population *pop, Global global,int *nrealmut,int *nbinmut)
{
    int i;
    for (i=0; i<global.popsize; i++)
    {
        mutation_ind(&(pop->ind[i]),global,nrealmut,nbinmut);
    }
    return;
}

/* Function to perform mutation of an individual */
void mutation_ind (individual *ind, Global global,int *nrealmut,int *nbinmut)
{
    if (global.nreal!=0)
    {
        real_mutate_ind(ind, global, nrealmut);
    }
    if (global.nbin!=0)
    {
        bin_mutate_ind(ind, global, nbinmut);
    }
    return;
}

/* Routine for binary mutation of an individual */
void bin_mutate_ind (individual *ind, Global global,int *nbinmut)
{
    int j, k;
    double prob;
    for (j=0; j<global.nbin; j++)
    {
        for (k=0; k<global.nbits[j]; k++)
        {
            prob = randomperc();
            if (prob <=global.pmut_bin)
            {
                if (ind->gene[j][k] == 0)
                {
                    ind->gene[j][k] = 1;
                }
                else
                {
                    ind->gene[j][k] = 0;
                }
                nbinmut+=1;
            }
        }
    }
    return;
}

/* Routine for real polynomial mutation of an individual */
void real_mutate_ind (individual *ind, Global global,int *nrealmut)
{
    int j;
    double rnd, delta1, delta2, mut_pow, deltaq;
    double y, yl, yu, val, xy;
    for (j=0; j<global.nreal; j++)
    {
        if (randomperc() <= global.pmut_real)
        {
            y = ind->xreal[j];
            yl = global.min_realvar[j];
            yu = global.max_realvar[j];
            delta1 = (y-yl)/(yu-yl);
            delta2 = (yu-y)/(yu-yl);
            rnd = randomperc();
            mut_pow = 1.0/(global.eta_m+1.0);
            if (rnd <= 0.5)
            {
                xy = 1.0-delta1;
                val = 2.0*rnd+(1.0-2.0*rnd)*(pow(xy,(global.eta_m+1.0)));
                deltaq =  pow(val,mut_pow) - 1.0;
            }
            else
            {
                xy = 1.0-delta2;
                val = 2.0*(1.0-rnd)+2.0*(rnd-0.5)*(pow(xy,(global.eta_m+1.0)));
                deltaq = 1.0 - (pow(val,mut_pow));
            }
            y = y + deltaq*(yu-yl);
            if (y<yl)
                y = yl;
            if (y>yu)
                y = yu;
            ind->xreal[j] = y;
            nrealmut+=1;
        }
    }
    return;
}
