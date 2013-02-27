/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2013 SUPELEC                                             *
 *                                                                           *
 *    Author:  Julien Bect  <julien.bect@supelec.fr>                         *
 *                                                                           *
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

#include "stk_mex.h"


static void gpquadfrom_matrixy
(
 double* x, double* y, double* rx2, double* ry2, 
 double* h, int nx, int ny, int dim
 )
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
        lambda += (diff * diff) / (rx2[kx] + ry2[ky]);
      }

      /* store the result in h */
      h[i + nx * j] = lambda;

    }
  }
}


mxArray* compute_gpquadfrom_matrixy
(
 const mxArray* x,
 const mxArray* y,
 const mxArray* rx,
 const mxArray* ry
 )
{
  unsigned int k, d, mx, my;
  double u, *p, *rx2, *ry2;
  mxArray *h;

  if((!stk_is_realmatrix(x))  || (!stk_is_realmatrix(y)) ||
     (!stk_is_realmatrix(rx)) || (!stk_is_realmatrix(ry)))
    mexErrMsgTxt("Input arguments should be real-valued double-precision array.");
  
  /* Check that the all input arguments have the same number of columns */
  d = mxGetN(x);
  if ((mxGetN(y) != d) || (mxGetN(rx) != d) || (mxGetN(ry) != d))
    mexErrMsgTxt("All input arguments should have the same number of columns.");

  /* Check that rx and ry have the appropriate number of rows */
  if (mxGetM(rx) != (mx = mxGetM(x)))
    mexErrMsgTxt("x and rx should have the same number of rows.");
  if (mxGetM(ry) != (my = mxGetM(y)))
    mexErrMsgTxt("y and ry should have the same number of rows.");
  
  /* Compute rx^2 */
  rx2 = mxCalloc(mx * d, sizeof(double));  p = mxGetPr(rx);
  for(k = 0; k < mx * d; k++) 
    {
      u = p[k];
      if(u <= 0)
	mexErrMsgTxt("rx should have (strictly) positive entries.");
      rx2[k] = u * u;
    }

  /* Compute ry^2 */
  ry2 = mxCalloc(my * d, sizeof(double));  p = mxGetPr(ry);
  for(k = 0; k < my * d; k++) 
    {
      u = p[k];
      if(u <= 0)
	mexErrMsgTxt("ry should have (strictly) positive entries.");
      ry2[k] = u * u;
    }

  /* Create a matrix for the return argument */
  h = mxCreateDoubleMatrix(mx, my, mxREAL);

  /* Do the actual computations in a subroutine */
  gpquadfrom_matrixy(mxGetPr(x), mxGetPr(y), rx2, ry2, mxGetPr(h), mx, my, d);

  /* Free allocated memory */
  mxFree(rx2);
  mxFree(ry2);

  return h;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  if (nlhs > 1)  /* Check number of output arguments */
    mexErrMsgTxt("Too many output arguments.");
  
  if (nrhs != 4)  /* Check number of input arguments */
    mexErrMsgTxt("Incorrect number of input arguments.");
      
  plhs[0] = compute_gpquadfrom_matrixy(prhs[0], prhs[1], prhs[2], prhs[3]); 
}
