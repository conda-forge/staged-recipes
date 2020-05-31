/* -------------------------------------------------------------------------------
 *
 * NSGA-II (Non-dominated Sorting Genetic Algorithm - II)
 *
 *  current version only works with continous design variables treated as reals
 *  no provisions for binary specification or integer/discrete variable handling
 *
 *  nvar - number of variables
 *  ncon - number of constraints
 *  nobj - number of objectives
 *  f -
 *  x -
 *  g -
 *  nfeval -
 *  xl -
 *  xu -
 *  popsize - population size (a multiple of 4)
 *  ngen    - number of generations
 *  pcross_real - probability of crossover of real variable (0.6-1.0)
 *  pmut_real   - probablity of mutation of real variables (1/nreal)
 *  eta_c - distribution index for crossover (5-20) must be > 0
 *  eta_m - distribution index for mutation (5-50) must be > 0
 *  pcross_bin - probability of crossover of binary variable (0.6-1.0)
 *  pmut_bin - probability of mutation of binary variables (1/nbits)
 *  seed    - seed value must be in (0,1)
 *
 *
 *  Output files
 *
 *  - initial_pop.out: contains initial population data
 *  - final_pop.out: contains final population data
 *  - all_pop.out: containts generation population data
 *  - best_pop.out: contains best solutions
 *  - params.out: contains input parameters information
 *  -   .out: contains runtime information
 *
 * ----------------------------------------------------------------------------
 *
 *  References:
 *  -----------
 *
 *  - Deb K., Agrawal S., Pratap A., and Meyarivan T., A Fast and Elitist
 *      multi-objective Genetic Algorithm: NSGA-II, IEEE Transactions on
 *      Evolutionary Computation (IEEE-TEC), 2002, Vol. 6, No. 2, pp 182-197
 *
 * ----------------------------------------------------------------------------
 *
 *  Usage:
 *  ------
 *
 *
 * ----------------------------------------------------------------------------
 *
 *  Copyrights:
 *  -----------
 *
 *  - Original NSGA-II implementation: (C) Dr. Kalyanmoy Deb 2005
 *  - Randon Number Generator: (C) Dr. David E. Goldberg 1986
 *
 * ----------------------------------------------------------------------------*/


/* -------------------------------------------------------------------------------
 * includefiles
 * ---------------------------------------------------------------------------- */
# include "nsga2.h"


/* -------------------------------------------------------------------------------
 * NSGA2
 * ---------------------------------------------------------------------------- */
int nsga2(int nvar, int ncon, int nobj, double f[], double x[], double g[],
    int nfeval, double xl[], double xu[],   int popsize, int ngen,
    double pcross_real, double pmut_real, double eta_c, double eta_m,
    double pcross_bin, double pmut_bin, int printout, double seed, int xinit)
{
    // declaration of local variables and structures
    int i, j;
    int nreal, nbin, *nbits, bitlength;
    double *min_realvar, *max_realvar;
    double *min_binvar, *max_binvar;
    int *nbinmut, *nrealmut, *nbincross, *nrealcross;

    Global global;

    population *parent_pop;
    population *child_pop;
    population *mixed_pop;

    // "random" numbers seed
    if (seed==0)
    {
        // use of clock to generate "random" seed
        time_t seconds;
        seconds=time(NULL);
        seed=seconds;
    }

    // Files
    FILE *fpt1;
    FILE *fpt2;
    FILE *fpt3;
    FILE *fpt4;
    FILE *fpt5;
    FILE *fpt6;
    if (printout >= 1)
    {
        fpt1 = fopen("nsga2_initial_pop.out","w");
        fpt2 = fopen("nsga2_final_pop.out","w");
        fpt3 = fopen("nsga2_best_pop.out","w");
        if (printout == 2)
        {
            fpt4 = fopen("nsga2_all_pop.out","w");
        }
        fpt5 = fopen("nsga2_params.out","w");
        fpt6 = fopen("nsga2_run.out","w");
        fprintf(fpt1,"# This file contains the data of initial population\n");
        fprintf(fpt2,"# This file contains the data of final population\n");
        fprintf(fpt3,"# This file contains the data of final feasible population (if found)\n");
        if (printout == 2)
        {
            fprintf(fpt4,"# This file contains the data of all generations\n");
        }
        fprintf(fpt5,"# This file contains information about inputs as read by the program\n");
        fprintf(fpt6,"# This file contains runtime information\n");
    }

    // Input Handling
    nreal = nvar;   // number of real variables
    nbin = 0;       // number of binary variables

    min_realvar = (double *)malloc(nreal*sizeof(double));
    max_realvar = (double *)malloc(nreal*sizeof(double));

    j = 0;
    for (i=0; i<nvar; i++)
    {
        min_realvar[j] = xl[i];
        max_realvar[j] = xu[i];
        j += 1;
    }

    if (nbin != 0)
    {
        nbits = (int *)malloc(nbin*sizeof(int));
        min_binvar = (double *)malloc(nbin*sizeof(double));
        max_binvar = (double *)malloc(nbin*sizeof(double));
    }

    bitlength = 0;
    if (nbin!=0)
    {
        for (i=0; i<nbin; i++)
        {
            bitlength += nbits[i];
        }
    }

    // Performing Initialization
    if (printout >= 1)
    {
        fprintf(fpt5,"\n Population size = %d",popsize);
        fprintf(fpt5,"\n Number of generations = %d",ngen);
        fprintf(fpt5,"\n Number of objective functions = %d",nobj);
        fprintf(fpt5,"\n Number of constraints = %d",ncon);
        fprintf(fpt5,"\n Number of variables = %d",nvar);
        fprintf(fpt5,"\n Number of real variables = %d",nreal);
        if (nreal!=0)
        {
            for (i=0; i<nreal; i++)
            {
                fprintf(fpt5,"\n Lower limit of real variable %d = %e",i+1,min_realvar[i]);
                fprintf(fpt5,"\n Upper limit of real variable %d = %e",i+1,max_realvar[i]);
            }
            fprintf(fpt5,"\n Probability of crossover of real variable = %e",pcross_real);
            fprintf(fpt5,"\n Probability of mutation of real variable = %e",pmut_real);
            fprintf(fpt5,"\n Distribution index for crossover = %e",eta_c);
            fprintf(fpt5,"\n Distribution index for mutation = %e",eta_m);
        }
        fprintf(fpt5,"\n Number of binary variables = %d",nbin);
        if (nbin!=0)
        {
            for (i=0; i<nbin; i++)
            {
                fprintf(fpt5,"\n Number of bits for binary variable %d = %d",i+1,nbits[i]);
                fprintf(fpt5,"\n Lower limit of binary variable %d = %e",i+1,min_binvar[i]);
                fprintf(fpt5,"\n Upper limit of binary variable %d = %e",i+1,max_binvar[i]);
            }
            fprintf(fpt5,"\n Probability of crossover of binary variable = %e",pcross_bin);
            fprintf(fpt5,"\n Probability of mutation of binary variable = %e",pmut_bin);
        }
        fprintf(fpt5,"\n Seed for random number generator = %e",seed);

        fprintf(fpt1,"# of objectives = %d, # of constraints = %d, # of real_var = %d, # of bits of bin_var = %d, constr_violation, rank, crowding_distance\n",nobj,ncon,nreal,bitlength);
        fprintf(fpt2,"# of objectives = %d, # of constraints = %d, # of real_var = %d, # of bits of bin_var = %d, constr_violation, rank, crowding_distance\n",nobj,ncon,nreal,bitlength);
        fprintf(fpt3,"# of objectives = %d, # of constraints = %d, # of real_var = %d, # of bits of bin_var = %d, constr_violation, rank, crowding_distance\n",nobj,ncon,nreal,bitlength);
        if (printout == 2)
        {
            fprintf(fpt4,"# of objectives = %d, # of constraints = %d, # of real_var = %d, # of bits of bin_var = %d, constr_violation, rank, crowding_distance\n",nobj,ncon,nreal,bitlength);
        }
    }

    //
    global.nreal = nreal;
    global.nbin = nbin;
    global.nobj = nobj;
    global.ncon = ncon;
    global.popsize = popsize;
    global.pcross_real = pcross_real;
    global.pcross_bin = pcross_bin;
    global.pmut_real = pmut_real;
    global.pmut_bin = pmut_bin;
    global.eta_c = eta_c;
    global.eta_m = eta_m;
    global.ngen = ngen;
    global.nbits = nbits;
    global.min_realvar = min_realvar;
    global.max_realvar = max_realvar;
    global.min_binvar = min_binvar;
    global.max_binvar = max_binvar;
    global.bitlength = bitlength;

    //
    nbinmut = 0;
    nrealmut = 0;
    nbincross = 0;
    nrealcross = 0;
    parent_pop = (population *)malloc(sizeof(population));
    child_pop = (population *)malloc(sizeof(population));
    mixed_pop = (population *)malloc(sizeof(population));
    allocate_memory_pop (parent_pop, popsize, global);
    allocate_memory_pop (child_pop, popsize, global);
    allocate_memory_pop (mixed_pop, 2*popsize, global);
    randomize(seed);
    initialize_pop (parent_pop, global);

    //
    if (xinit!=0)
    {
      i=0;
      for (j=0; j<nreal; j++)
      {
          parent_pop->ind[i].xreal[j] = x[j];
      }
    }

    // First Generation
    if (printout >= 1)
    {
        fprintf(fpt6,"\n\n Initialization done, now performing first generation");
    }
    decode_pop(parent_pop, global);
    evaluate_pop(parent_pop, global);
    assign_rank_and_crowding_distance (parent_pop, global);
    if (printout >= 1)
    {
        report_pop (parent_pop, fpt1, global);
        if (printout == 2)
        {
            fprintf(fpt4,"# gen = 1\n");
            report_pop(parent_pop,fpt4, global);
        }

        fprintf(fpt6,"\n gen = 1");

        fflush(fpt1);
        fflush(fpt2);
        fflush(fpt3);
        if (printout == 2)
        {
            fflush(fpt4);
        }
        fflush(fpt5);
        fflush(fpt6);
    }
    fflush(stdout);

    // Iterate Generations
    for (i=2; i<=ngen; i++)
    {
        selection(parent_pop, child_pop, global, nrealcross, nbincross);
        mutation_pop(child_pop, global, nrealmut, nbinmut);
        decode_pop(child_pop, global);
        evaluate_pop(child_pop, global);
        merge (parent_pop, child_pop, mixed_pop, global);
        fill_nondominated_sort (mixed_pop, parent_pop, global);

        /* Comment following three lines if information for all
        generations is not desired, it will speed up the execution */
        if (printout >= 1)
        {
            if (printout == 2)
            {
                fprintf(fpt4,"# gen = %i\n",i);
                report_pop(parent_pop,fpt4, global);
                fflush(fpt4);
            }
            fprintf(fpt6,"\n gen = %i",i);
            fflush(fpt6);
        }
    }

    // Output
    if (printout >= 1)
    {
        fprintf(fpt6,"\n Generations finished");
        report_pop(parent_pop,fpt2, global);
        report_feasible(parent_pop,fpt3, global);

        if (nreal!=0)
        {
            fprintf(fpt5,"\n Number of crossover of real variable = %i",nrealcross);
            fprintf(fpt5,"\n Number of mutation of real variable = %i",nrealmut);
        }
        if (nbin!=0)
        {
            fprintf(fpt5,"\n Number of crossover of binary variable = %i",nbincross);
            fprintf(fpt5,"\n Number of mutation of binary variable = %i",nbinmut);
        }
        fflush(stdout);
        fflush(fpt1);
        fflush(fpt2);
        fflush(fpt3);
        if (printout == 2)
        {
            fflush(fpt4);
        }
        fflush(fpt5);
        fflush(fpt6);
        fclose(fpt1);
        fclose(fpt2);
        fclose(fpt3);
        if (printout == 2)
        {
            fclose(fpt4);
        }
        fclose(fpt5);

    }

    //
    for (i=0; i<popsize; i++)
    {
        if (parent_pop->ind[i].constr_violation == 0.0 && parent_pop->ind[i].rank==1)
        {
            for (j=0; j<nobj; j++)
            {
                f[j] = parent_pop->ind[i].obj[j];
            }
            if (ncon!=0)
            {
                for (j=0; j<ncon; j++)
                {
                    g[j] = parent_pop->ind[i].constr[j];
                }
            }
            if (nreal!=0)
            {
                for (j=0; j<nreal; j++)
                {
                    x[j] = parent_pop->ind[i].xreal[j];
                }
            }
            break;
        }
    }

    //
    if (nreal!=0)
    {
        free (min_realvar);
        free (max_realvar);
    }
    if (nbin!=0)
    {
        free (min_binvar);
        free (max_binvar);
        free (nbits);
    }
    deallocate_memory_pop (parent_pop, popsize, global);
    deallocate_memory_pop (child_pop, popsize, global);
    deallocate_memory_pop (mixed_pop, 2*popsize, global);
    free (parent_pop);
    free (child_pop);
    free (mixed_pop);

    //
    if (printout >= 1)
    {
        fprintf(fpt6,"\n Routine successfully exited \n");
        fflush(fpt6);
        fclose(fpt6);
    }

    return (0);
}
