/* Routines to decode the population */

# include <stdio.h>
# include <stdlib.h>
# include <math.h>

# include "nsga2.h"
# include "rand.h"

/* Function to decode a population to find out the binary variable values based on its bit pattern */
void decode_pop (population *pop, Global global)
{
    int i;
    if (global.nbin!=0)
    {
        for (i=0; i<global.popsize; i++)
        {
            decode_ind (&(pop->ind[i]),global);
        }
    }
    return;
}

/* Function to decode an individual to find out the binary variable values based on its bit pattern */
void decode_ind (individual *ind, Global global)
{
    int j, k;
    int sum;
    if (global.nbin!=0)
    {
        for (j=0; j<global.nbin; j++)
        {
            sum=0;
            for (k=0; k<global.nbits[j]; k++)
            {
                if (ind->gene[j][k]==1)
                {
                    sum += pow(2,global.nbits[j]-1-k);
                }
            }
            ind->xbin[j] = global.min_binvar[j] + (double)sum*(global.max_binvar[j] - global.min_binvar[j])/(double)(pow(2,global.nbits[j])-1);
        }
    }
    return;
}
