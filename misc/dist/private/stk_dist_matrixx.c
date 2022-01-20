/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2015 CentraleSupelec                                     *
 *    Copyright (C) 2011, 2012 SUPELEC                                       *
 *                                                                           *
 *    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>           *
 *              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>      *
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

static void distance1(double* x, double* h, size_t nx, size_t dim)
{
  size_t i, j, k1, k2;
  double diff, lambda;

  for (i = 0; i < nx; i++) {

    /* put a zero on the diagonal */
    h[i*(nx+1)] = 0.0;

    for (j = i+1; j < nx; j++) {

      /* compute distance between x[i,:] and x[j,:] */
      lambda = 0.0;
      for (k1 = i, k2 = j; k1 < dim * nx; k1 += nx, k2 += nx)
      {
        diff = x[k1] - x[k2];
        lambda += diff * diff;
      }

      /* store the result in h, twice for symmetry */
      h[i+nx*j] = sqrt(lambda);
      h[j+nx*i] = h[i+nx*j];

    }
  }
}


mxArray* compute_distance_xx(const mxArray* x)
{
  size_t d, n;
  mxArray* h;

  if(!stk_is_realmatrix(x))
    mexErrMsgTxt("The input should be a real-valued double-precision array.");

  /* Read the size of the input argument */
  n = mxGetM(x);
  d = mxGetN(x);

  /* Create a matrix for the return argument */
  h = mxCreateDoubleMatrix(n, n, mxREAL);

  /* Do the actual computations in a subroutine */
  distance1(mxGetPr(x), mxGetPr(h), n, d);

  return h;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  if (nlhs > 1)   /* Check number of output arguments */
      mexErrMsgTxt("Too many output arguments.");

  if (nrhs != 1)  /* Check number of input arguments */
      mexErrMsgTxt("Incorrect number of input arguments.");
      
  plhs[0] = compute_distance_xx(prhs[0]);  
}
