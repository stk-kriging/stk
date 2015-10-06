/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2015 CentraleSupelec                                     *
 *    Copyright (C) 2012 SUPELEC                                             *
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

#define X_IN           prhs[0]     /* input argument #1  */
#define Y_IN           prhs[1]     /* input argument #2  */
#define FILLDIST_OUT   plhs[0]     /* output argument #1 */
#define ARGMAX_OUT     plhs[1]     /* output argument #2 */

static double compute_filldist
(
 double* x, size_t nx, 
 double* y, size_t ny,
 size_t dim, 
 size_t* argmax
 )
{
  size_t i, j, k1, k2, j_max;
  double diff, sqdist_max, sqdist_j, sqdist_ij;

  j_max = 0;
  sqdist_max = 0.0;

  for (j = 0; j < ny; j++) {

    sqdist_j = 0;  /* prevents a "may be uninitialized" warning */

    /* Compute the sqdist from y(j, :) to the set x */    
    for (i = 0; i < nx; i++) {
      /* Compute the sqdist from y(j, :) to x(i, :) */
      sqdist_ij = 0.0;
      for (k1 = i, k2 = j; k1 < dim * nx; k1 += nx, k2 += ny) {
        diff = x[k1] - y[k2];
        sqdist_ij += diff * diff;
      }
      /* Update sqdist_j */
      if ((i == 0) || (sqdist_ij < sqdist_j))
	sqdist_j = sqdist_ij;
    }
    
    /* Update sqdist_max */
    if (sqdist_j > sqdist_max) {
      j_max = j;
      sqdist_max = sqdist_j;
    }

  }
  
  *argmax = j_max;
  return sqrt(sqdist_max);
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  size_t mx, my, dim, argmax;
  double filldist, *px, *py;

  if (nlhs > 2)
      mexErrMsgTxt("Too many output arguments.");

  if (nrhs != 2)
      mexErrMsgTxt("Incorrect number of input arguments (should be 2).");

  if (mxIsComplex(X_IN) || mxIsComplex(Y_IN))
      mexErrMsgTxt("The input arguments cannot be complex.");

  if ((!mxIsDouble(X_IN)) || (!mxIsDouble(Y_IN)))
      mexErrMsgTxt("The input argument must be of class 'double'.");

  /* Read the size of the input arguments */
  mx = mxGetM(X_IN);
  my = mxGetM(Y_IN);
  dim = mxGetN(X_IN);

  if ((mx == 0) || (my == 0) || (dim == 0))
    mexErrMsgTxt("The input arguments should not be empty.");

  if (mxGetN(Y_IN) != dim)
    mexErrMsgTxt("The input arguments must have the same number of columns.");

  /* Do the actual computations in a subroutine */
  px = mxGetPr(X_IN);  py = mxGetPr(Y_IN);
  filldist = compute_filldist(px, mx, py, my, dim, &argmax);

  /* Return the results as Matlab objects */
  FILLDIST_OUT = mxCreateDoubleScalar(filldist);
  if (nlhs == 2)
    ARGMAX_OUT = mxCreateDoubleScalar(((double)argmax) + 1);
}
