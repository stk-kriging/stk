/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2015 CentraleSupelec                                     *
 *    Copyright (C) 2013 SUPELEC                                             *
 *                                                                           *
 *    Author:  Julien Bect  <julien.bect@centralesupelec.fr>                 *
 *                                                                           *
 * Copying Permission Statement                                              *
 *                                                                           *
 *    This file is part of                                                   *
 *                                                                           *
 *            STK: a Small (Matlab/Octave) Toolbox for Kriging               *
 *               (https://github.com/stk-kriging/stk/)                   *
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


static void gpquadform_pairwise
(
 double* x, double* y, double* rx, double* ry, 
 double* h, size_t m, size_t dim
 )
{
  size_t i, kx, ky;
  double diff, lambda, rxi, ryi;

  for (i = 0; i < m; i++)
    {
      /* compute distance between x[i,:] and y[i,:] */
      lambda = 0.0;
      for (kx = i, ky = i; kx < dim * m; kx += m, ky += m)
      {
        diff = x[kx] - y[ky];
	rxi = rx[kx];
	ryi = ry[ky];
        lambda += (diff * diff) / (rxi * rxi + ryi * ryi);
      }

      /* store the result in h */
      h[i] = lambda;
    }
}


mxArray* compute_qxy_matrixy
(
 const mxArray* x,
 const mxArray* y,
 const mxArray* rx,
 const mxArray* ry
 )
{
  size_t d, m;
  mxArray *h;

  if((!stk_is_realmatrix(x))  || (!stk_is_realmatrix(y)) ||
     (!stk_is_realmatrix(rx)) || (!stk_is_realmatrix(ry)))
    mexErrMsgTxt("Input arguments should be real-valued double-precision array.");
  
  /* Check that the all input arguments have the same number of columns */
  d = mxGetN(x);
  if ((mxGetN(y) != d) || (mxGetN(rx) != d) || (mxGetN(ry) != d))
    mexErrMsgTxt("All input arguments should have the same number of columns.");

  /* Read the number of rows of x and y */
  if (mxGetM(y) != (m = mxGetM(x)))
    mexErrMsgTxt("x and y should have the same number of rows.");
  
  /* Check that rx and ry have the appropriate number of rows */
  if (mxGetM(rx) != m)
    mexErrMsgTxt("x and rx should have the same number of rows.");
  if (mxGetM(ry) != m)
    mexErrMsgTxt("y and ry should have the same number of rows.");
  
  /* Create a matrix for the return argument */
  h = mxCreateDoubleMatrix(m, 1, mxREAL);

  /* Do the actual computations in a subroutine */
  gpquadform_pairwise(mxGetPr(x), mxGetPr(y), mxGetPr(rx), mxGetPr(ry), mxGetPr(h), m, d);

  return h;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  if (nlhs > 1)  /* Check number of output arguments */
    mexErrMsgTxt("Too many output arguments.");
  
  if (nrhs != 4)  /* Check number of input arguments */
    mexErrMsgTxt("Incorrect number of input arguments.");
      
  plhs[0] = compute_qxy_matrixy(prhs[0], prhs[1], prhs[2], prhs[3]); 
}
