/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2015 CentraleSupelec                                     *
 *    Copyright (C) 2012, 2013 SUPELEC                                       *
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

#ifndef ___STK_MEX_H___
#define ___STK_MEX_H___

#include <math.h>
#include "mex.h"

#if (defined __STDC_VERSION__) && (__STDC_VERSION__ >= 199901L)
#   include <stdbool.h>
#else
#   ifndef bool
#      define bool int
#   endif
#   ifndef true
#      define true 1
#   endif
#   ifndef false
#      define false 0
#   endif
#endif

int stk_is_realmatrix(const mxArray* x)
{
  if (mxIsComplex(x) || !mxIsDouble(x))
    return 0;

  if (mxGetNumberOfDimensions(x) != 2)
    return 0;

  return 1;
}

int mxIsDoubleVector (const mxArray* x)
{
  size_t m, n;

  if (! stk_is_realmatrix (x))
    return 0;
  
  m = mxGetM (x);
  n = mxGetN (x);

  return ((m == 1) && (n > 0)) || ((n == 1) && (m > 0));
}  

void mxReplaceField
(mxArray* S, mwIndex index, const char* fieldname, const mxArray* value)
{
  mxArray *tmp, *value_copy;

  tmp = mxGetField(S, index, fieldname);
  if (tmp != NULL)
    mxDestroyArray(tmp);

  value_copy = mxDuplicateArray(value);
  if (value_copy == NULL)
    mexErrMsgTxt("mxDuplicateArray: not enough free heap "
		 "space to create the mxArray");
  
  mxSetField(S, index, fieldname, value_copy);
}

#define  STK_OK                0
#define  STK_ERROR            -1
#define  STK_ERROR_DOMAIN      1
#define  STK_ERROR_OOM         2
#define  STK_ERROR_SANITY      3

int mxReadScalar_int(const mxArray* x, int* n)
{
  double t;

  if (mxGetNumberOfElements(x) != 1)
    return STK_ERROR;
  
  if (mxIsComplex(x) || !mxIsDouble(x))
    return STK_ERROR;

  t = mxGetScalar(x);
  *n = (int) t;

  return ((((double) *n) == t) ? STK_OK : STK_ERROR);
}

#endif
