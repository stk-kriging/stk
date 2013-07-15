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

#ifndef ___STK_MEX_H___
#define ___STK_MEX_H___

#include <math.h>
#include "mex.h"

int stk_is_realmatrix(const mxArray* x)
{
  if (mxIsComplex(x) || !mxIsDouble(x))
    return 0;

  if (mxGetNumberOfDimensions(x) != 2)
    return 0;

  return 1;
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

#endif
