/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2015, 2016 CentraleSupelec                               *
 *                                                                           *
 *    Author:  Julien Bect  <julien.bect@centralesupelec.fr>                 *
 *                                                                           *
 *    Based on the file wfg.h from WFG 1.10 by Lyndon While, Lucas           *
 *    Bradstreet, Luigi Barone, released under the GPLv2+ licence. The       *
 *    original copyright notice is:                                          *
 *                                                                           *
 *       Copyright (C) 2010 Lyndon While, Lucas Bradstreet                   *
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

#ifndef ___WFG_H___
#define ___WFG_H___

typedef double OBJECTIVE;

typedef struct
{
    int n;
    OBJECTIVE *objectives;
}
POINT;

typedef struct
{
    int nPoints;
    int nPoints_alloc;  /* must *not* be changed */
    int n;
    int n_alloc;        /* must *not* be changed */
    POINT *points;
}
FRONT;

double wfg_compute_hv (FRONT* ps);

void wfg_alloc (int maxm, int maxn);
void wfg_free (int maxm, int maxn);

void wfg_front_init (FRONT* front, int nb_points, int nb_objectives);
void wfg_front_destroy (FRONT* front);
void wfg_front_resize (FRONT* f, int nb_points, int nb_objectives);


/*****************************************/
/* RLIST structure & associated funtions */
/*****************************************/

typedef struct
{
    int allocated_size;  /* maximal number of rectangles     */
    int size;            /* current number of rectangles     */
    int n;               /* dimension (number of objectives) */
    double **xmin;       /* lower bounds                     */
    double *xmin_data;   /* lower bounds (one block)         */
    double **xmax;       /* upper bounds                     */
    double *xmax_data;   /* upper bounds (one block)         */  
    int *sign;           /* inclusion/exclusion              */
}
RLIST;

/* wfg_compute_decomposition: similar to wfg_compute_hv, but */
/*   returns a decomposition of the dominated region into    */
/*   hyper-rectangles (instead of its hyper-volume)          */
void wfg_compute_decomposition (FRONT* ps, RLIST* Rlist);

/* Memory management */
RLIST* Rlist_alloc (int alloc_size, int n);
void Rlist_extend (RLIST* Rlist, int k, int* p_Ridx);
void Rlist_free (RLIST* Rlist);


#endif
