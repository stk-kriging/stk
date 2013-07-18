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
#define VALUE_IN      prhs[2]
#define DATAFRAME_OUT plhs[0]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  char *s;
  mxArray *data, *colnames, *tmp;
  int icol;
  size_t nrow, ncol;
  double *src, *dst;

  /*--- Check number of input/output arguments --------------------------------*/

  if (nrhs != 3)
    mexErrMsgTxt("Incorrect number of input arguments (should be 2).");

  if (nlhs > 1)
    mexErrMsgTxt("Incorrect number of output arguments (should be 1).");

  /*--- Read property name ----------------------------------------------------*/

  if (!mxIsChar(PROPNAME_IN))
    mexErrMsgTxt("PropertyName argument should be of class 'char'.");
  
  s = mxArrayToString(PROPNAME_IN);

  if(s == NULL)
    mexErrMsgTxt("mxArrayToString failed to process PropertyName argument.");
  
  /*--- Get data, nrow, ncol --------------------------------------------------*/
  
  data = mxGetField(DATAFRAME_IN, 0, "data");
  if(data == NULL)
    mexErrMsgTxt("Unable to get field 'data'.");

  nrow = mxGetM(data);
  ncol = mxGetN(data);
  
  /*--- Prepare output dataframe ----------------------------------------------*/
  
  DATAFRAME_OUT = mxDuplicateArray(DATAFRAME_IN);
  
  /*--- Parse PropertyName ----------------------------------------------------*/

  if (strcmp(s, "rownames") == 0)
    {
      if (!mxIsCell(VALUE_IN))
	mexErrMsgTxt("PropertyValue should be a cell array of strings.");
      
      mxReplaceField(DATAFRAME_OUT, 0, "rownames", VALUE_IN);
    }
  else
    {
      if (strcmp(s, "colnames") == 0)
        {
	  if (!mxIsCell(VALUE_IN))
	    mexErrMsgTxt("PropertyValue should be a cell array of strings.");

	  mxReplaceField(DATAFRAME_OUT, 0, "vnames", VALUE_IN);         
        }
      else
        {
	  /* Which column are we trying to set ? */
	  colnames = mxGetField(DATAFRAME_OUT, 0, "vnames");
          icol = (double) get_column_number(colnames, s);
	  
	  /* Get the 'data' field of the output dataframe */
	  data = mxGetField(DATAFRAME_OUT, 0, "data");
	  if(data == NULL)
	    mexErrMsgTxt("Unable to get field 'data'.");

          if (icol == -2)
            {
              /* Special case: setting the entire dataframe at once */
	      src = mxGetPr(VALUE_IN);
	      dst = mxGetPr(data);
	      memcpy(dst, src, nrow * ncol * sizeof(double));	      
            }
          else
            {
              /* General case: icol is a column index */
              if (icol >= ncol)
                {
                  mexErrMsgTxt("What the hell !?!?");
                }
              else
                {
                  src = mxGetPr(VALUE_IN);
                  dst = mxGetPr(data) + nrow * icol;
                  memcpy(dst, src, nrow * sizeof(double));
                }
            }
        }
    }

  mxFree(s);
}
