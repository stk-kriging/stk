/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
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


static void distance2(double* x, double* y, double* h, int nx, int ny, int dim)
{
  int i, j, kx, ky;
  double diff, lambda;

  for (i = 0; i < nx; i++) {
    for (j = 0; j < ny; j++) {

      /* compute distance between x[i,:] and y[j,:] */
      lambda = 0.0;
      for (kx = i, ky = j; kx < dim * nx; kx += nx, ky += ny)
      {
        diff = x[kx] - y[ky];
        lambda += diff * diff;
      }

      /* store the result in h */
      h[i+nx*j] = sqrt(lambda);

    }
  }
}


mxArray* compute_distance_xy(const mxArray* x, const mxArray* y)
{
  unsigned int d, mx, my;
  mxArray* h;

  if((!stk_is_realmatrix(x)) || (!stk_is_realmatrix(y)))
    mexErrMsgTxt("Input arguments should be real-valued double-precision array.");

  /* Check that the input arguments have the same number of columns */
  if (mxGetN(y) != (d = mxGetN(x)))
    mexErrMsgTxt("Both input arguments should have the same number of columns.");

  /* Read the size (number of lines) of each input argument */
  mx = mxGetM(x);
  my = mxGetM(y);

  /* Create a matrix for the return argument */
  h = mxCreateDoubleMatrix(mx, my, mxREAL);

  /* Do the actual computations in a subroutine */
  distance2(mxGetPr(x), mxGetPr(y), mxGetPr(h), mx, my, d);

  return h;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  if (nlhs > 1)  /* Check number of output arguments */
    mexErrMsgTxt("Too many output arguments.");
  
  if (nrhs != 2)  /* Check number of input arguments */
    mexErrMsgTxt("Incorrect number of input arguments.");
      
  plhs[0] = compute_distance_xy(prhs[0], prhs[1]); 
}
