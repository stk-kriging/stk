/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2014 SUPELEC                                             *
 *                                                                           *
 *    Author:  Julien Bect  <julien.bect@centralesupelec.fr>                 *
 *                                                                           *
 * Copying Permission Statement                                              *
 *                                                                           *
 *    This file is part of                                                   *
 *                                                                           *
 *            STK: a Small (Matlab/Octave) Toolbox for Kriging               *
 *               (http://sourceforge.net/projects/kriging)                   *
 *                                                                           *
 *    STK is free software: you can redistribute it and/or modify it under   *
 *    the terms of the GNU General Public License as published by the Free   *
 *    Software Foundation,  either version 3  of the License, or  (at your   *
 *    option) any later version.                                             *
 *                                                                           *
 *    STK is distributed  in the hope that it will  be useful, but WITHOUT   *
 *    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY   *
 *    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public   *
 *    License for more details.                                              *
 *                                                                           *
 *    You should  have received a copy  of the GNU  General Public License   *
 *    along with STK.  If not, see <http://www.gnu.org/licenses/>.           *
 *                                                                           *
 ****************************************************************************/

#ifndef ___LEXICAL_SORT_H___
#define ___LEXICAL_SORT_H___

/* assumes that types SCALAR and LOGICAL are defined */

struct T {
    int pos;
    int stride;
    int dim;
    const SCALAR *data;
};


/*--------------------------------------------------------------*/

void lexical_sort
(SCALAR *x, int *idx, int n, int d);

int pareto_find
(SCALAR *x, int *idx1, int* idx2, int n, int d);

void is_dominated
(const SCALAR *xa, const SCALAR *xb, LOGICAL *isdom,
 int *drank, int n, int k, int d);

int __lexical_cmp__
(const void *_x, const void *_y);

int __is_dominated__
(const struct T *x, const struct T *y);

void __init_tab__
(const SCALAR *x, struct T *tab, int n, int d);


/*--------------------------------------------------------------*/

int __lexical_cmp__ (const void *_x, const void *_y)
{
    int j, n, d;
    const SCALAR *px, *py;
    const struct T *x, *y;

    /* Cast to const struct T* */
    x = (const struct T*) _x;
    y = (const struct T*) _y;

    /* Pointers to the actual data */
    px = x->data;
    py = y->data;

    /* We ASSUME that x and y have the same dim and stride */
    d = x->dim;
    n = x->stride;

    for (j = 0; j < d; j ++, px += n, py += n) {
        if ((*px) < (*py))
            return -1;  /* x < y */
        else if ((*px) > (*py))
            return +1;  /* y > x */
    }

    return 0; /* x == y */
}

/*--------------------------------------------------------------*/

/* Is x dominated by y ?     */
/*   note: SMALLER is better */

int __is_dominated__ (const struct T *x, const struct T *y)
{
    int j, nx, ny, d, any_xgty;
    const SCALAR *px, *py;

    /* Pointers to the actual data */
    px = x->data;
    py = y->data;

    d = x->dim;
    nx = x->stride;
    ny = y->stride;

    any_xgty = 0;  /* flag: 1 if we have seen at least one component
                          in y that is strictly better (smaller) */

    for (j = 0; j < d; j ++, px += nx, py += ny) {
        if ((*px) < (*py))
            return 0;  /* y does not dominate x */
        else if ((*px) > (*py))
            any_xgty = 1;
    }

    return any_xgty;
}

/*--------------------------------------------------------------*/

/* TODO: templated versions, to handle integer types, single, etc. */

void lexical_sort (SCALAR *x, int *idx, int n, int d)
{
    struct T *tab;
    int i;

    /* Prepare tab for sorting */
    tab = (struct T *) malloc (n * sizeof (struct T));
    __init_tab__ (x, tab, n, d);

    /* Sort using qsort() from the standard library */
    qsort (tab, n, sizeof (struct T), __lexical_cmp__);

    /* Fill output list */
    for (i = 0; i < n; i++)
        idx[i] = tab[i].pos;

    free (tab);
}

/*--------------------------------------------------------------*/

/* TODO: templated versions, to handle integer types, single, etc. */

int pareto_find (SCALAR *x, int *ndpos, int *drank, int n, int d)
{
    /* ndpos: liste de taille n
     *
     *       ndpos[i] = position in x of the i^th non-dominated point
     *                  (i^th in the lexical order)  0 <= i < k
     *
     *       ndpos[i] = -1   for all i > k
     *
     * drank: another list of length n
     *
     *       drank[i] = rank (in the lexical order, between 0 and k) of
     *                  the first dominating point if x[i, :] is dominated
     *
     *       drank[i] = -1 if x[i, :] is not dominated
     *
     * Both lists are assumed to have been allocated by the caller.
     *
     * Note: all indices are 0-based in this function.
     */

    struct T *tab;
    int i, ii, k, pos;

    /* Prepare tab for sorting */
    tab = (struct T *) malloc (n * sizeof (struct T));
    __init_tab__ (x, tab, n, d);

    /* Sort using qsort() from the standard library */
    qsort (tab, n, sizeof (struct T), __lexical_cmp__);

    /* Fill ndpos and drank with -1 */
    for (i = 0; i < n; i++) {
        ndpos[i] = -1;
        drank[i] = -1;
    }

    /* Remove dominated points                                  */
    /*   i : rank of current point. Start at the SECOND element */
    for (i = 1; i < n; i++)
        for (ii = 0; ii < i; ii++)
            if ((tab[ii].pos >= 0) &&
                    (__is_dominated__ (tab + i, tab + ii))) {
                drank[tab[i].pos] = ii;
                tab[i].pos = - 1;
                break;
            }

    /* Note: at this stage, drank contains the rank of the first
     *       dominating point in the FULL (sorted) list of points */

    /* Fill ndpos */
    k = 0;
    for (i = 0; i < n; i++) {
        pos = tab[i].pos;
        if (pos >= 0) {  /* indicates a non-dominated point */
            ndpos[k] = pos;
            tab[i].pos = k;
            k ++;
        }
    }

    /* Adjust drank to the final list of non-dominated points */
    for (i = 0; i < n; i++)
        if (drank[i] != -1 )
            drank[i] = tab[drank[i]].pos;

    free (tab);

    return k;
}

/*--------------------------------------------------------------*/

void is_dominated (const SCALAR *xa, const SCALAR *xb,
                   LOGICAL *isdom, int *drank,
                   int n, int k, int d)
{
    int i, j, b;
    struct T T1, T2;
    SCALAR xa1;

    T1.pos = 0; /* unused */
    T1.stride = n;
    T1.dim = d;

    T2.pos = 0; /* unused */
    T2.stride = k;
    T2.dim = d;

    for (i = 0; i < n; i++) {

        b = 0;             /* not dominated, until proved otherwise */
        T1.data = xa + i;  /* pointer to the current row            */
        xa1 = xa[i];       /* first element of the current row      */

        for (j = 0; j < k; j++) {

            /* xb is assumed to be LEXICALLY SORTED => as soon as the
            first element becomes bigger than xa1, we know that
             the current row is not dominated */
            if (xb[j] > xa1)
                break;

            T2.data = xb + j;
            if (__is_dominated__ (&T1, &T2)) {
                b = 1;
                break;
            }
        }

        if (b) {
            drank[i] = j;
            isdom[i] = (LOGICAL) 1;
        } else {
            drank[i] = -1;
            isdom[i] = (LOGICAL) 0;
        }
    }
}

/*--------------------------------------------------------------*/

void __init_tab__ (const SCALAR *x, struct T *tab, int n, int d)
{
    int i;

    /* Fill in array to be sorted */
    for (i = 0; i < n; i++) {
        tab[i].pos   = i;
        tab[i].data   = x + i;
        tab[i].dim    = d;
        tab[i].stride = n;
    }

}

#endif
