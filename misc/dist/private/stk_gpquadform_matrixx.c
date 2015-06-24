/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2013 SUPELEC                                             *
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


static void gpquadform_matrixx
(
 double* x, double* rx2, double* h, int n, int dim
 )
{
  int i, j, k1, k2;
  double diff, lambda;

  for (i = 0; i < (n - 1); i++)
    {
      /* put a zero on the diagonal */
      h[i * (n + 1)] = 0.0;

      for (j = (i + 1); j < n; j++)
	{
	  /* compute distance between x[i,:] and x[j,:] */
	  lambda = 0.0;
	  for (k1 = i, k2 = j; k1 < dim * n; k1 += n, k2 += n)
	    {
	      diff = x[k1] - x[k2];
	      lambda += (diff * diff) / (rx2[k1] + rx2[k2]);
	    }
	  /* store the result in h */
	  h[i + n * j] = lambda;
	  h[j + n * i] = lambda;
	}
    }
}


mxArray* compute_gpquadform_matrixx
(
 const mxArray* x,
 const mxArray* rx
 )
{
  unsigned int k, d, mx;
  double u, *p, *rx2;
  mxArray *h;

  if((!stk_is_realmatrix(x))  || (!stk_is_realmatrix(rx)))
    mexErrMsgTxt("Input arguments should be real-valued double-precision array.");

  d = mxGetN(x);
  mx = mxGetM(x);
  
  /* Check that the all input arguments have the same number of columns */
  if ((mxGetM(rx) != mx) || (mxGetN(rx) != d))
    mexErrMsgTxt("x and rx should have the same size.");
   
  /* Compute rx^2 */
  rx2 = mxCalloc(mx * d, sizeof(double));  p = mxGetPr(rx);
  for(k = 0; k < mx * d; k++) 
    {
      u = p[k];
      if(u <= 0)
	mexErrMsgTxt("rx should have (strictly) positive entries.");
      rx2[k] = u * u;
    }

  /* Create a matrix for the return argument */
  h = mxCreateDoubleMatrix(mx, mx, mxREAL);

  /* Do the actual computations in a subroutine */
  gpquadform_matrixx(mxGetPr(x), rx2, mxGetPr(h), mx, d);

  /* Free allocated memory */
  mxFree(rx2);

  return h;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  if (nlhs > 1)  /* Check number of output arguments */
    mexErrMsgTxt("Too many output arguments.");
  
  if (nrhs != 2)  /* Check number of input arguments */
    mexErrMsgTxt("Incorrect number of input arguments.");
      
  plhs[0] = compute_gpquadform_matrixx(prhs[0], prhs[1]); 
}
