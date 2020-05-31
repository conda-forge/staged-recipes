/* Data initializtion routines */

# include <stdio.h>
# include <stdlib.h>
# include <math.h>

# include "nsga2.h"
# include "rand.h"

/* Function to initialize a population randomly */
void initialize_pop (population *pop, Global global)
{
    int i;
    for (i=0; i<global.popsize; i++)
    {
        initialize_ind (&(pop->ind[i]),global);
    }
    return;
}

/* Function to initialize an individual randomly */
void initialize_ind (individual *ind, Global global)
{
    int j, k;
    if (global.nreal!=0)
    {
        for (j=0; j<global.nreal; j++)
        {
            ind->xreal[j] = rndreal (global.min_realvar[j], global.max_realvar[j]);
        }
    }
    if (global.nbin!=0)
    {
        for (j=0; j<global.nbin; j++)
        {
            for (k=0; k<global.nbits[j]; k++)
            {
                if (randomperc() <= 0.5)
                {
                    ind->gene[j][k] = 0;
                }
                else
                {
                    ind->gene[j][k] = 1;
                }
            }
        }
    }
    return;
}
