/* Memory allocation and deallocation routines */

# include <stdio.h>
# include <stdlib.h>
# include <math.h>

# include "nsga2.h"
# include "rand.h"

/* Function to allocate memory to a population */
void allocate_memory_pop (population *pop, int size, Global global)
{
    int i;
    pop->ind = (individual *)malloc(size*sizeof(individual));
    for (i=0; i<size; i++)
    {
        allocate_memory_ind (&(pop->ind[i]), global);
    }
    return;
}

/* Function to allocate memory to an individual */
void allocate_memory_ind (individual *ind, Global global)
{
    int j;
    if (global.nreal != 0)
    {
        ind->xreal = (double *)malloc(global.nreal*sizeof(double));
    }
    if (global.nbin != 0)
    {
        ind->xbin = (double *)malloc(global.nbin*sizeof(double));
        ind->gene = (int **)malloc(global.nbin*sizeof(int));
        for (j=0; j<global.nbin; j++)
        {
            ind->gene[j] = (int *)malloc(global.nbits[j]*sizeof(int));
        }
    }
    ind->obj = (double *)malloc(global.nobj*sizeof(double));
    if (global.ncon != 0)
    {
        ind->constr = (double *)malloc(global.ncon*sizeof(double));
    }
    return;
}

/* Function to deallocate memory to a population */
void deallocate_memory_pop (population *pop, int size, Global global)
{
    int i;
    for (i=0; i<size; i++)
    {
        deallocate_memory_ind (&(pop->ind[i]), global);
    }
    free (pop->ind);
    return;
}

/* Function to deallocate memory to an individual */
void deallocate_memory_ind (individual *ind, Global global)
{
    int j;
    if (global.nreal != 0)
    {
        free(ind->xreal);
    }
    if (global.nbin != 0)
    {
        for (j=0; j<global.nbin; j++)
        {
            free(ind->gene[j]);
        }
        free(ind->xbin);
        free(ind->gene);
    }
    free(ind->obj);
    if (global.ncon != 0)
    {
        free(ind->constr);
    }
    return;
}
