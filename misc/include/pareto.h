/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2014 SUPELEC                                             *
 *    Author:    Julien Bect  <julien.bect@supelec.fr>                       *
 *    URL:       http://sourceforge.net/projects/kriging/                    *
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

/* assumes that type SCALAR is defined */

struct T {
  int pos;
  int stride;
  int dim;
  SCALAR *data;
};


/*--------------------------------------------------------------*/

void lexical_sort (SCALAR *x, int *idx, int n, int d);
int pareto_find (SCALAR *x, int *idx1, int* idx2, int n, int d);

int lexical_cmp (const void *_x, const void *_y);
int is_dominated (const struct T *x, const struct T *y);
void init_tab (SCALAR *x, struct T *tab, int n, int d);


/*--------------------------------------------------------------*/

int lexical_cmp (const void *_x, const void *_y)
{
  int j, n, d;  SCALAR *px, *py;  const struct T *x, *y;

  /* Cast to const struct T* */
  x = (const struct T*) _x;  y = (const struct T*) _y;

  /* Pointers to the actual data */
  px = x->data;  py = y->data;

  /* We ASSUME that x and y have the same dim and stride */
  d = x->dim;  n = x->stride;

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

int is_dominated (const struct T *x, const struct T *y)
{
  int j, n, d, any_xgty;  SCALAR *px, *py;

  /* Pointers to the actual data */
  px = x->data;  py = y->data;

  /* We ASSUME that x and y have the same dim and stride */
  d = x->dim;  n = x->stride;

  any_xgty = 0;  /* flag: 1 if we have seen at least one component
                          in y that is strictly better (smaller) */

  for (j = 0; j < d; j ++, px += n, py += n) {
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
  struct T *tab;  int i;

  /* Prepare tab for sorting */
  tab = (struct T *) malloc (n * sizeof (struct T));
  init_tab (x, tab, n, d);

  /* Sort using qsort() from the standard library */
  qsort (tab, n, sizeof (struct T), lexical_cmp);

  /* Fill output list */
  for (i = 0; i < n; i++)
    idx[i] = tab[i].pos;

  free (tab);
}

/*--------------------------------------------------------------*/

/* TODO: templated versions, to handle integer types, single, etc. */

int pareto_find (SCALAR *x, int *idx1, int* idx2, int n, int d)
{
  /* idx1: liste de taille n
   *
   *       idx1[i] = position in x of the i^th non-dominated point
   *                 (i^th in the lexical order)  0 <= i < k
   *
   *       idx1[i] = -1   for all i > k
   *
   * idx2: another list of length n
   * 
   *       idx2[i] = rank (in the lexical order, between 0 and k) of
   *                 the first dominating point if x[i, :] is dominated
   *
   *       idx2[i] = -1 if x[i, :] is not dominated
   *
   * Both lists are assumed to have been allocated by the caller.
   *
   * Note: all indices are 0-based in this function.   
   */
    
  struct T *tab;  int i, ii, k, pos;

  /* Prepare tab for sorting */
  tab = (struct T *) malloc (n * sizeof (struct T));
  init_tab (x, tab, n, d);

  /* Sort using qsort() from the standard library */
  qsort (tab, n, sizeof (struct T), lexical_cmp);

  /* Fill idx1 and idx2 with -1 */
  for (i = 0; i < n; i++) {
      idx1[i] = -1;  idx2[i] = -1; }
  
  /* Remove dominated points                                  */
  /*   i : rank of current point. Start at the SECOND element */  
  for (i = 1; i < n; i++)
    for (ii = 0; ii < i; ii++)
      if ((tab[ii].pos >= 0) && (is_dominated (tab + i, tab + ii))) {
          idx2[tab[i].pos] = ii;  tab[i].pos = - 1;  break; }

  /* Note: at this stage, idx2 contains the rank of the first 
   *       dominating point in the FULL (sorted) list of points */

  /* Fill idx1 */
  k = 0;
  for (i = 0; i < n; i++) {
      pos = tab[i].pos;
      if (pos >= 0) {  /* indicates a non-dominated point */
          idx1[k] = pos;  tab[i].pos = k;  k ++; }}
  
  /* Adjust idx2 to the final list of non-dominated points */
  for (i = 0; i < n; i++)
      if (idx2[i] != -1 )
          idx2[i] = tab[idx2[i]].pos;
   
  free (tab);
  
  return k;
}

/*--------------------------------------------------------------*/

void init_tab (SCALAR *x, struct T *tab, int n, int d)
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
