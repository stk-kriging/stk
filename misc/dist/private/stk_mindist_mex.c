/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright  (C) 2012 SUPELEC                                            *
 *    Author:    Julien Bect <julien.bect@supelec.fr>                        *
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

#define X_IN   prhs[0]  /* input argument  */
#define H_OUT  plhs[0]  /* output argument */

static double compute_mindist(double* x, int nx, int dim)
{
  int i, j, k1, k2;
  double diff, dist_squared, mindist_squared;

  mindist_squared = -1;

  for (i = 0; i < nx; i++) {
    for (j = i+1; j < nx; j++) {

      /* compute distance between x[i,:] and x[j,:] */
      dist_squared = 0.0;
      for (k1 = i, k2 = j; k1 < dim * nx; k1 += nx, k2 += nx) {
        diff = x[k1] - x[k2];
        dist_squared += diff * diff;
      }

      /* update mindist_squared */
      if ((dist_squared < mindist_squared) || (mindist_squared < 0))
	mindist_squared = dist_squared;
    }
  }

  return sqrt(mindist_squared);
}



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  unsigned int dim, mx;

  if (nlhs > 1)
      mexErrMsgTxt("Too many output arguments.");

  if (nrhs != 1)
      mexErrMsgTxt("Incorrect number of input arguments (should be 1).");

  if (mxIsComplex(X_IN))
      mexErrMsgTxt("The input argument cannot be complex.");

  if (!mxIsDouble(X_IN))
      mexErrMsgTxt("The input argument must be of class 'double'.");

  /* Read the size of the input argument */
  mx = mxGetM(X_IN);
  dim = mxGetN(X_IN);

  if (mx < 2)
    {
      /* return an empty matrix if the input has less than two lines */
      H_OUT = mxCreateDoubleMatrix(0, 0, mxREAL);
    }
  else
    {
      if (dim == 0)
	{
	  /* return zero distance if the matrix has no columns */
	  H_OUT = mxCreateDoubleScalar(0.0);
	}
      else
	{
	  /* otherwise, do the actual computations in a subroutine */
	  H_OUT = mxCreateDoubleScalar(compute_mindist(mxGetPr(X_IN), mx, dim));
	}
    }

}
