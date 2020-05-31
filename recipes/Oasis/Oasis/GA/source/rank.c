/* Rank assignment routine */

# include <stdio.h>
# include <stdlib.h>
# include <math.h>

# include "nsga2.h"
# include "rand.h"

/* Function to assign rank and crowding distance to a population of size pop_size*/
void assign_rank_and_crowding_distance (population *new_pop, Global global)
{
    int flag;
    int i;
    int end;
    int front_size;
    int rank=1;
    list *orig;
    list *cur;
    list *temp1, *temp2;
    orig = (list *)malloc(sizeof(list));
    cur = (list *)malloc(sizeof(list));
    front_size = 0;
    orig->index = -1;
    orig->parent = NULL;
    orig->child = NULL;
    cur->index = -1;
    cur->parent = NULL;
    cur->child = NULL;
    temp1 = orig;
    for (i=0; i<global.popsize; i++)
    {
        insert (temp1,i);
        temp1 = temp1->child;
    }
    do
    {
        if (orig->child->child == NULL)
        {
            new_pop->ind[orig->child->index].rank = rank;
            new_pop->ind[orig->child->index].crowd_dist = INF;
            break;
        }
        temp1 = orig->child;
        insert (cur, temp1->index);
        front_size = 1;
        temp2 = cur->child;
        temp1 = delnode (temp1);
        temp1 = temp1->child;
        do
        {
            temp2 = cur->child;
            do
            {
                end = 0;
                flag = check_dominance (&(new_pop->ind[temp1->index]), &(new_pop->ind[temp2->index]), global);
                if (flag == 1)
                {
                    insert (orig, temp2->index);
                    temp2 = delnode (temp2);
                    front_size--;
                    temp2 = temp2->child;
                }
                if (flag == 0)
                {
                    temp2 = temp2->child;
                }
                if (flag == -1)
                {
                    end = 1;
                }
            }
            while (end!=1 && temp2!=NULL);
            if (flag == 0 || flag == 1)
            {
                insert (cur, temp1->index);
                front_size++;
                temp1 = delnode (temp1);
            }
            temp1 = temp1->child;
        }
        while (temp1 != NULL);
        temp2 = cur->child;
        do
        {
            new_pop->ind[temp2->index].rank = rank;
            temp2 = temp2->child;
        }
        while (temp2 != NULL);
        assign_crowding_distance_list (new_pop, cur->child, front_size, global);
        temp2 = cur->child;
        do
        {
            temp2 = delnode (temp2);
            temp2 = temp2->child;
        }
        while (cur->child !=NULL);
        rank+=1;
    }
    while (orig->child!=NULL);
    free (orig);
    free (cur);
    return;
}
