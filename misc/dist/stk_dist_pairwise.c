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


static void distance3(double* x, double* y, double* h, int n, int dim)
{
  int i, j, k;
  double diff, lambda;

  for (i = 0; i < n; i++) {

    /* compute distance between x[i,:] and y[j,:] */
    lambda = 0.0;
    for (k = i; k < dim * n; k += n)
      {
        diff = x[k] - y[k];
        lambda += diff * diff;
      }
    
    /* store the result in h */
    h[i] = sqrt(lambda);
    
  }
}


mxArray* compute_distance_xy_pairwise(const mxArray* x, const mxArray* y)
{
  unsigned int d, n;
  mxArray* h;

  if((!stk_is_realmatrix(x)) || (!stk_is_realmatrix(y)))
    mexErrMsgTxt("Input arguments should be real-valued double-precision array.");

  /* Check that the input arguments have the same number of columns */
  if (mxGetN(y) != (d = mxGetN(x)))
    mexErrMsgTxt("Both input arguments should have the same number of columns.");

  /* Check that the input arguments have the same number of rows */
  if (mxGetM(y) != (n = mxGetM(x)))
    mexErrMsgTxt("Both input arguments should have the same number of rows.");

  /* Create a matrix for the return argument */
  h = mxCreateDoubleMatrix(n, 1, mxREAL);

  /* Do the actual computations in a subroutine */
  distance3(mxGetPr(x), mxGetPr(y), mxGetPr(h), n, d);

  return h;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  if (nlhs > 1)  /* Check number of output arguments */
    mexErrMsgTxt("Too many output arguments.");
  
  if (nrhs != 2)  /* Check number of input arguments */
    mexErrMsgTxt("Incorrect number of input arguments.");
      
  plhs[0] = compute_distance_xy_pairwise(prhs[0], prhs[1]); 
}
