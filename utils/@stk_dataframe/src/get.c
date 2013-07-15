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
#include "get_column_number.h"

#define DATAFRAME_IN  prhs[0]
#define PROPNAME_IN   prhs[1]
#define OUTPUT        plhs[0]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  char *s;
  mxArray *data, *colnames;
  int icol;
  size_t m, n;
  double *src, *dst;

  /*--- Check number of input/output arguments --------------------------------*/

  if (nrhs != 2)
    mexErrMsgTxt("Incorrect number of input arguments (should be 2).");

  if (nlhs > 1)
    mexErrMsgTxt("Incorrect number of output arguments (should be 1).");

  /*--- Read property name ----------------------------------------------------*/

  if (!mxIsChar(PROPNAME_IN))
    mexErrMsgTxt("PropertyName argument should be of class 'char'.");
  
  s = mxArrayToString(PROPNAME_IN);
  
  if(s == NULL)
    mexErrMsgTxt("mxArrayToString failed to process PropertyName argument.");

  /*--- Parse PropertyName ----------------------------------------------------*/

  if (strcmp(s, "rownames") == 0)
    {
      OUTPUT = mxGetField(DATAFRAME_IN, 0, "rownames");
    }
  else
    {
      colnames = mxGetField(DATAFRAME_IN, 0, "vnames");

      if (strcmp(s, "colnames") == 0)
        {
          OUTPUT = colnames;
        }
      else
        {
          data = mxGetField(DATAFRAME_IN, 0, "data");
          if(data == NULL)
            mexErrMsgTxt("Unable to get field 'data' from the first argument.");

          icol = (double) get_column_number(colnames, s);

          if (icol == -2)
            {
              /* Special case: return the entire array */
              OUTPUT = data;
            }
          else
            {
              /* General case: icol is a column index */
              m = mxGetM(data);
              n = mxGetN(data);
              if (icol >= n)
                {
                  mexErrMsgTxt("What the hell !?!?");
                }
              else
                {
                  OUTPUT = mxCreateDoubleMatrix(m, 1, mxREAL);
                  src = mxGetPr(data) + m * icol;
                  dst = mxGetPr(OUTPUT);
                  memcpy(dst, src, m * sizeof(double));
                }
            }
        }
    }

  mxFree(s);
}
