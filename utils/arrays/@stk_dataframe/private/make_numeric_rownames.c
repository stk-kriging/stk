/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright  (C) 2013 SUPELEC                                            *
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

#include "string.h"
#include "stk_mex.h"

#define ROWNUM   prhs[0]
#define ROWNAMES plhs[0]

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *rownum;
    size_t n;
    int i, t;
    char buffer[2048]; /* FIXME: provide our own cross-platform snprintf ? */ 

    /*--- Check number of input/output arguments --------------------------------*/
    
    if (nrhs != 1)
        mexErrMsgTxt ("Incorrect number of input arguments (should be 1).");
    
    if (nlhs > 1)
        mexErrMsgTxt ("Incorrect number of output arguments (should be 1).");
    
    /*--- Read row numbers ------------------------------------------------------*/
    
    if (!mxIsDoubleVector (ROWNUM))
        mexErrMsgTxt("Input argument should be a vector of class double.");
    
    rownum = mxGetPr (ROWNUM);
    n = mxGetNumberOfElements (ROWNUM);

    /*--- Which column are we trying to set ? -----------------------------------*/
    
    ROWNAMES = mxCreateCellMatrix (n, 1);
    
    for (i = 0; i < n; i ++)
    {
        t = rownum[i];
	if (((double) t) != rownum[i])
	  mexErrMsgTxt("Row numbers should be integers.");
	
	sprintf (buffer, "%d", t);
	mxSetCell (ROWNAMES, i, mxCreateString (buffer));
    }
}
