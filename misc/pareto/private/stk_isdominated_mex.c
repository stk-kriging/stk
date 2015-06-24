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

/* mimic ismember's syntax */
#define ARGIN_A       prhs[0]  /* n x d, double  */
#define ARGIN_B       prhs[1]  /* k x d, double  */
#define ARGOUT_ISDOM  plhs[0]  /* n x 1, logical */
#define ARGOUT_DRANK  plhs[1]  /* n x 1, double  */

/* IMPORTANT: the rows of B are assumed to be    */
/*            SORTED in the LEXICAL ORDER        */

void mexFunction
(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]
)
{
    int i, n, k, d, *tmp_drank;
    double *xa, *xb, *drank;
    mxLogical *isdom;

    /*--- Check number of input/output arguments --------------------*/

    if (nrhs != 2)  /* Check number of input arguments */
        mexErrMsgTxt ("Incorrect number of input arguments.");

    if (nlhs > 2)   /* Check number of output arguments */
        mexErrMsgTxt ("Too many output arguments.");

    /*--- Check input types -----------------------------------------*/

    if (! stk_is_realmatrix (ARGIN_A))
        mexErrMsgTxt ("The first input argument should be a "
                      "real-valued double-precision array.");
    xa = mxGetPr (ARGIN_A);

    if (! stk_is_realmatrix (ARGIN_B))
        mexErrMsgTxt ("The second input argument should be a "
                      "real-valued double-precision array.");
    xb = mxGetPr (ARGIN_B);

    /*--- Read dimensions -------------------------------------------*/

    n = (int) mxGetM (ARGIN_A);
    d = (int) mxGetN (ARGIN_A);
    k = (int) mxGetM (ARGIN_B);

    if (d != mxGetN (ARGIN_B))
        mexErrMsgTxt ("The two input arguments should have the "
                      "same number of columns");

    /*--- Create arrays ---------------------------------------------*/

    ARGOUT_ISDOM = mxCreateLogicalMatrix (n, 1);
    isdom = mxGetLogicals (ARGOUT_ISDOM);

    tmp_drank = (int *) mxCalloc (n, sizeof (int));

    /*--- Find dominated rows ---------------------------------------*/

    is_dominated (xa, xb, isdom, tmp_drank, n, k, d);

    if (nlhs > 1) {
        ARGOUT_DRANK = mxCreateDoubleMatrix (n, 1, mxREAL);
        drank = mxGetPr (ARGOUT_DRANK);
        for (i = 0; i < n; i++)
            drank[i] = (double) (1 + tmp_drank[i]);
    }

    /*--- Cleanup --------------------------------------------------*/

    mxFree (tmp_drank);
}
