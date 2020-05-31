/* Routine for mergeing two populations */

# include <stdio.h>
# include <stdlib.h>
# include <math.h>

# include "nsga2.h"
# include "rand.h"

/* Routine to merge two populations into one */
void merge(population *pop1, population *pop2, population *pop3, Global global)
{
    int i, k;
    for (i=0; i<global.popsize; i++)
    {
        copy_ind (&(pop1->ind[i]), &(pop3->ind[i]), global);
    }
    for (i=0, k=global.popsize; i<global.popsize; i++, k++)
    {
        copy_ind (&(pop2->ind[i]), &(pop3->ind[k]), global);
    }
    return;
}

/* Routine to copy an individual 'ind1' into another individual 'ind2' */
void copy_ind (individual *ind1, individual *ind2, Global global)
{
    int i, j;
    ind2->rank = ind1->rank;
    ind2->constr_violation = ind1->constr_violation;
    ind2->crowd_dist = ind1->crowd_dist;
    if (global.nreal!=0)
    {
        for (i=0; i<global.nreal; i++)
        {
            ind2->xreal[i] = ind1->xreal[i];
        }
    }
    if (global.nbin!=0)
    {
        for (i=0; i<global.nbin; i++)
        {
            ind2->xbin[i] = ind1->xbin[i];
            for (j=0; j<global.nbits[i]; j++)
            {
                ind2->gene[i][j] = ind1->gene[i][j];
            }
        }
    }
    for (i=0; i<global.nobj; i++)
    {
        ind2->obj[i] = ind1->obj[i];
    }
    if (global.ncon!=0)
    {
        for (i=0; i<global.ncon; i++)
        {
            ind2->constr[i] = ind1->constr[i];
        }
    }
    return;
}
