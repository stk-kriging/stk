/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2011 SUPELEC                                             *
 *    Version: 1.0                                                           *
 *    Authors: Julien Bect <julien.bect@supelec.fr>                          *
 *             Emmanuel Vazquez <emmanuel.vazquez@supelec.fr>                *
 *    URL:     http://sourceforge.net/projects/kriging/                      *
 *                                                                           *
 * Copying Permission Statement                                              *
 *                                                                           *
 *    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for   *
 *    Kriging.                                                               *
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

#include <math.h>
#include "mex.h"

/* Input Arguments */
#define X_IN prhs[0]
#define Y_IN prhs[1]

/* Output Arguments */
#define H_OUT plhs[0]

static void distance1(double* x, double* h, int nx, int dim)
{
  int i, j, k1, k2;
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

mxArray* compute_distance_xx(const mxArray* x)
{
  unsigned int dim, mx;
  mxArray* h;

  if (mxIsComplex(x))
    {
      mexErrMsgTxt("The input argument cannot be complex.");
    }

  if (!mxIsDouble(x))
    {
      mexErrMsgTxt("The input argument must be of class 'double'.");
    }

  /* Read the size of the input argument */
  mx = mxGetM(x);
  dim = mxGetN(x);

  /* Create a matrix for the return argument */
  h = mxCreateDoubleMatrix(mx, mx, mxREAL);

  /* Do the actual computations in a subroutine */
  distance1(mxGetPr(x), mxGetPr(h), mx, dim);

  return h;
}

mxArray* compute_distance_xy(const mxArray* x, const mxArray* y)
{
  unsigned int dim, mx, my;
  mxArray* h;

  if (mxIsComplex(x) || mxIsComplex(y))
    {
      mexErrMsgTxt("Complex arguments are not allowed.");
    }

  if (!mxIsDouble(x) || !mxIsDouble(y))
    {
      mexErrMsgTxt("Input arguments must be of class 'double'.");
    }

  /* Check that the input arguments have the same number of columns */
  if (mxGetN(y) != (dim = mxGetN(x)))
    {
      mexErrMsgTxt("Both input arguments should have the same number of columns.");
    }

  /* Read the size (number of lines) of each input argument */
  mx = mxGetM(x);
  my = mxGetM(y);

  /* Create a matrix for the return argument */
  h = mxCreateDoubleMatrix(mx, my, mxREAL);

  /* Do the actual computations in a subroutine */
  distance2(mxGetPr(x), mxGetPr(y), mxGetPr(h), mx, my, dim);

  return h;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
  if (nlhs > 1)  /* Check number of output arguments */
    {
      mexErrMsgTxt("Too many output arguments.");
    }

  if (nrhs == 1)  /* Branch according to the number of input arguments */
    {
      H_OUT = compute_distance_xx(X_IN);
    } 
  else if (nrhs == 2) 
    {
      H_OUT = compute_distance_xy(X_IN, Y_IN);
    } 
  else 
    {
      mexErrMsgTxt("Incorrect number of input arguments.");
    }
}
