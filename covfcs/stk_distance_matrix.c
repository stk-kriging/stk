/*=================================================================
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2004 The MathWorks, Inc.
 *
 *=================================================================*/

#include <math.h>
#include "mex.h"

/* Input Arguments */

#define	X_IN	prhs[0]
#define	Y_IN	prhs[1]

/* Output Arguments */

#define	H_OUT	plhs[0]

static void distance(double x[], double	y[], double h[], int nx, int ny, int dim)
{
    int i,j, kx, ky;
    double diff,lambda;
    
    for (i = 0; i < nx; i++)
        for (j = 0; j < ny; j++)
    {
        lambda = 0.0;
        for (kx=0, ky=0; kx < dim*nx; kx += nx, ky += ny)
        {
            
            diff = x[i+kx] - y[j+ky];
            lambda += diff*diff;
        }
        h[i+nx*j] = sqrt(lambda);
    }
    return;
}

void mexFunction( int nlhs, mxArray *plhs[],
int nrhs, const mxArray*prhs[] )

{
  /* input args */
    double *x_in, *y_in;
  /* output args */
    double *h;
    
    unsigned int mx,nx,my,ny;
    
  /* Check for proper number of arguments */
    
    if (nrhs != 2) {
        mexErrMsgTxt("Two input arguments required.");
    } else if (nlhs > 1) {
        mexErrMsgTxt("Too many output arguments.");
    }
    
  /* Check the dimensions of X and Y. */
    
    mx = mxGetM(X_IN);
    nx = mxGetN(X_IN);
    my = mxGetM(Y_IN);
    ny = mxGetN(Y_IN);
    if (!mxIsDouble(X_IN) || mxIsComplex(X_IN) ||
    !mxIsDouble(Y_IN) || mxIsComplex(Y_IN) ||
    (nx != ny)) {
        mexErrMsgTxt("BUG !");
    }
    
  /* Create a matrix for the return argument */
    H_OUT = mxCreateDoubleMatrix(mx, my, mxREAL);
    
  /* Assign pointers to the various parameters */
    h = mxGetPr(H_OUT);
    
    x_in = mxGetPr(X_IN);
    y_in = mxGetPr(Y_IN);
    
  /* Do the actual computations in a subroutine */
    distance(x_in, y_in, h, mx, my, nx);
    return;
    
}


