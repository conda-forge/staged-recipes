/* -------------------------------------------------------------------------------
 *
 *  Header File for nsga2.c
 *  
 * ---------------------------------------------------------------------------- */ 

# ifndef _GLOBAL_H_
# define _GLOBAL_H_

# define INF 1.0e14
# define EPS 1.0e-14
# define E  2.71828182845905
# define PI 3.14159265358979

/* -------------------------------------------------------------------------------
 * Includes
 * ---------------------------------------------------------------------------- */
# include <stdio.h>
# include <stdlib.h>
# include <math.h>
# include <time.h>

# include "rand.h"

/* -------------------------------------------------------------------------------
 * Structures
 * ---------------------------------------------------------------------------- */
typedef struct
{
    int rank;
    double constr_violation;
    double *xreal;
    int **gene;
    double *xbin;
    double *obj;
    double *constr;
    double crowd_dist;
}
individual;

typedef struct
{
    individual *ind;
}
population;

typedef struct lists
{
    int index;
    struct lists *parent;
    struct lists *child;
}
list;

typedef struct
{
	int nreal;
	int nbin;
	int nobj;
	int ncon;
	int popsize;
	double pcross_real;
	double pcross_bin;
	double pmut_real;
	double pmut_bin;
	double eta_c;
	double eta_m;
	int ngen;
	int nbinmut;
	int nrealmut;
	int nbincross;
	int nrealcross;
	int *nbits;
	double *min_realvar;
	double *max_realvar;
	double *min_binvar;
	double *max_binvar;
	int bitlength;	
}
Global;



/* -------------------------------------------------------------------------------
 * Headers
 * ---------------------------------------------------------------------------- */
int nsga2(int nvar, int ncon, int nobj, double f[], double x[], double g[], int nfeval, double xl[], double xu[],	int popsize, int ngen, double pcross_real, double pmut_real, double eta_c, double eta_m, double pcross_bin, double pmut_bin, int printout, double seed, int xinit);

void allocate_memory_pop (population *pop, int size, Global global);
void allocate_memory_ind (individual *ind, Global global);
void deallocate_memory_pop (population *pop, int size, Global global);
void deallocate_memory_ind (individual *ind, Global global);

double maximum (double a, double b);
double minimum (double a, double b);

void crossover (individual *parent1, individual *parent2, individual *child1, individual *child2, Global global, int *nrealcross, int *nbincross);
void realcross (individual *parent1, individual *parent2, individual *child1, individual *child2, Global global, int *nrealcross);
void bincross (individual *parent1, individual *parent2, individual *child1, individual *child2, Global global, int *nbincross);

void assign_crowding_distance_list (population *pop, list *lst, int front_size, Global global);
void assign_crowding_distance_indices (population *pop, int c1, int c2, Global global);
void assign_crowding_distance (population *pop, int *dist, int **obj_array, int front_size, Global global);

void decode_pop (population *pop, Global global);
void decode_ind (individual *ind, Global global);

int check_dominance (individual *a, individual *b, Global global);

void evaluate_pop (population *pop, Global global);
void evaluate_ind (individual *ind, Global global);

void fill_nondominated_sort (population *mixed_pop, population *new_pop, Global global);
void crowding_fill (population *mixed_pop, population *new_pop, int count, int front_size, list *cur, Global global);

void initialize_pop (population *pop, Global global);
void initialize_ind (individual *ind, Global global);

void insert (list *node, int x);
list* delnode (list *node);

void merge(population *pop1, population *pop2, population *pop3, Global global);
void copy_ind (individual *ind1, individual *ind2, Global global);

void mutation_pop (population *pop, Global global, int *nrealmut, int *nbinmut);
void mutation_ind (individual *ind, Global global, int *nrealmut, int *nbinmut);
void bin_mutate_ind (individual *ind, Global global, int *nbinmut);
void real_mutate_ind (individual *ind, Global global, int *nrealmut);

//void nsga2func (int nreal, int nbin, int nobj, int ncon, double *xreal, double *xbin, int **gene, double *obj, double *constr);

void assign_rank_and_crowding_distance (population *new_pop, Global global);

void report_pop (population *pop, FILE *fpt, Global global);
void report_feasible (population *pop, FILE *fpt, Global global);
//void report_ind (individual *ind, FILE *fpt);

void quicksort_front_obj(population *pop, int objcount, int obj_array[], int obj_array_size);
void q_sort_front_obj(population *pop, int objcount, int obj_array[], int left, int right);
void quicksort_dist(population *pop, int *dist, int front_size);
void q_sort_dist(population *pop, int *dist, int left, int right);

void selection (population *old_pop, population *new_pop, Global global, int *nrealcross, int *nbincross);
individual* tournament (individual *ind1, individual *ind2, Global global);

# endif
