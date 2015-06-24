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

#include "stk_mex.h"

typedef double SCALAR;
typedef mxLogical LOGICAL;
#include "pareto.h"

#define ARGIN_X       prhs[0]
#define ARGOUT_NDPOS  plhs[0]
#define ARGOUT_DRANK  plhs[1]

void mexFunction
(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]
)
{
    int i, k, n, d, *tmp_ndpos, *tmp_drank;
    double *x, *ndpos, *drank;

    if (nrhs != 1)  /* Check number of input arguments */
        mexErrMsgTxt ("Incorrect number of input arguments.");

    if (nlhs > 3)   /* Check number of output arguments */
        mexErrMsgTxt ("Too many output arguments.");

    if (! stk_is_realmatrix (ARGIN_X))
        mexErrMsgTxt ("The input should be a real-valued "
                      "double-precision array.");

    /* Read input argument */
    n = mxGetM (ARGIN_X);
    d = mxGetN (ARGIN_X);
    x = mxGetPr (ARGIN_X);

    /* Create a temporary arrays */
    tmp_ndpos = (int *) mxCalloc (n, sizeof (int));
    tmp_drank = (int *) mxCalloc (n, sizeof (int));

    /* PRUNE */
    k = pareto_find (x, tmp_ndpos, tmp_drank, n, d);

    /* ARGOUT #1: position of non-dominated points, in lexical order */
    ARGOUT_NDPOS = mxCreateDoubleMatrix (k, 1, mxREAL);
    ndpos = mxGetPr (ARGOUT_NDPOS);
    for (i = 0; i < k; i++)
        ndpos[i] = (double) (1 + tmp_ndpos[i]);

    /* ARGOUT #2: rank of first dominating point */
    if (nlhs > 1) {
        ARGOUT_DRANK = mxCreateDoubleMatrix (n, 1, mxREAL);
        drank = mxGetPr (ARGOUT_DRANK);
        for (i = 0; i < n; i++)
            drank[i] = (double) (1 + tmp_drank[i]);
    }

    /* Cleanup */
    mxFree (tmp_ndpos);
    mxFree (tmp_drank);
}
