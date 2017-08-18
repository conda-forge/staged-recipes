/*
A very simple example using lp_solve, with the following problem:
    Objective function
    min: -9 C1 -10 C2;
    Constraints
    R1: -0 <= +C1 <= 10;
    +C1 -C2 = 0;
To compile using GCC:
    $ gcc demo2.c -o demo2 -llpsolve55
*/

#include "lp_lib.h"

int demo()
{
    lprec *lp;
    int j;
    int num_cols = 2;
    int ret;
    
    int *colno;
    REAL *row;
    
    colno = (int *)malloc(sizeof(*colno) * num_cols);
    row = (REAL *)malloc(sizeof(*row) * num_cols);
    
    lp = make_lp(0, num_cols);
    
    set_add_rowmode(lp, TRUE); /* makes building the model faster if it is done rows by row */
    
    colno[0] = 1;
    colno[1] = 2;
    j = 2;
    
    row[0] = 1;
    row[1] = 0;
    add_constraintex(lp, j, row, colno, LE, 10);
    
    set_rh_range(lp, 1, 10);
    
    row[0] = 1;
    row[1] = -1;
    add_constraintex(lp, j, row, colno, EQ, 0);
    
    set_add_rowmode(lp, FALSE); /* rowmode should be turned off again when done building the model */
    
    /* set objective function */
    row[0] = -9.0;
    row[1] = -10.0;
    
    set_obj_fnex(lp, 2, row, colno);
    
    /* object direction is minimise */
    set_minim(lp);
    
    /* print problem to stdout */
    write_LP(lp, stdout);

    set_verbose(lp, IMPORTANT);

    printf("\n");

    ret = solve(lp);
    printf("Status: %i\n", ret);

    printf("Objective value: %f\n", get_objective(lp));

    get_variables(lp, row);
    for(j = 0; j < num_cols; j++)
    {
        printf("%s: %f\n", get_col_name(lp, j + 1), row[j]);
    }

    
    if(lp != NULL)
    {
        delete_lp(lp);
    }
    
    return 0;
}

int main()
{
    return demo();
}

