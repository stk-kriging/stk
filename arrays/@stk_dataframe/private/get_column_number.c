/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright  (C) 2013 SUPELEC                                            *
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

#include "string.h"
#include "stk_mex.h"

#define ICOL_INFO     -5           /* will be a -4 in the end */
#define ICOL_ROWNAMES -4           /* will be a -3 in the end */
#define ICOL_COLNAMES -3           /* will be a -2 in the end */
#define ICOL_ENTIRE_DATAFRAME -2   /* will be a -1 in the end */

int get_column_number(const mxArray* mxColNames, char* s)
{
    size_t ncol, cmax, c;
    char** colnames;
    mxArray* tmp;
    int icol, found;
    
    if (strcmp (s, "info") == 0)
        return ICOL_INFO;
    
    if (strcmp (s, "rownames") == 0)
        return ICOL_ROWNAMES;
    
    if (strcmp (s, "colnames") == 0)
        return ICOL_COLNAMES;
    
    ncol = mxGetNumberOfElements(mxColNames);
    if (ncol == 0) {
        if (strcmp(s, "a") == 0 || strcmp(s, "data") == 0) /* LEGACY: .a */
            return ICOL_ENTIRE_DATAFRAME;
        mexErrMsgTxt("The dataframe has no column names.");
    }
    
    icol = -1;
    
    /* Read colum names and compare with s. We stop when the first
     match is found, assuming that we are dealing with a
     well-formed dataframe without duplicated column names. */
    
    colnames = (char**) mxCalloc(ncol, sizeof(char*));
    for (c = 0; c < ncol; c++)
    {
        tmp = mxGetCell(mxColNames, c);
        if (tmp == NULL)
            mexErrMsgTxt("Error while reading column names (mxGetCell).");
        
        colnames[c] = mxArrayToString(tmp);
        if (colnames[c] == NULL)
            mexErrMsgTxt("Error while reading column names (mxArrayToString).");
        
        if (strcmp(colnames[c], s) == 0)
        {
            icol = (int) c;
            break;
        }
    }
    
    /* Maximum c such that colnames[c] must be freed */
    found = (icol != -1);
    cmax = ((found) ? (c) : (ncol - 1));
    
    /* Deal with special cases, in particular LEGACY cases,
       if no exact match has been found */
    if (!found)
    {
        if (strcmp(s, "data") == 0)
        {
            icol = ICOL_ENTIRE_DATAFRAME;
        }
        else if (strcmp(s, "a") == 0)
        {
            for (c = 0; c < ncol; c++)
                if (strcmp(colnames[c], "mean") == 0)
                {
                icol = (int) c;
                break;
                }
            
            if (icol == -1)
            {
                icol = ICOL_ENTIRE_DATAFRAME;
                mexWarnMsgIdAndTxt("STK:subsref_dot:Legacy",
                        "There is no variable named 'a'.\n"
                        " => Assuming that you're an old STK user"
                        " trying to get the entire dataframe.");
            }
            else
            {
                mexWarnMsgIdAndTxt("STK:subsref_dot:Legacy",
                        "There is no variable named 'a'.\n"
                        " => Assuming that you're an old STK user"
                        " trying to get the kriging mean.");
            }
        }
        else if (strcmp(s, "v") == 0)
        {
            for (c = 0; c < ncol; c++)
                if (strcmp(colnames[c], "var") == 0)
                {
                icol = (int) c;
                break;
                }
            
            if (icol != -1)
                mexWarnMsgIdAndTxt("STK:subsref_dot:Legacy",
                        "There is no variable named 'v'.\n"
                        " => Assuming that you're an old STK user"
                        " trying to get the kriging variance.");
        }
    }
    
    /* ERROR if no corresponding column can be found */
    if (icol == -1)
        mexErrMsgIdAndTxt("STK:subsref_dot:UnknownVariable",
                "There is no variable named %s.", s);
    
    /* Free memory used for column names. */
    for (c = 0; c <= cmax; c++)
        mxFree(colnames[c]);
    mxFree(colnames);
    
    return icol;
}


#define COLNAMES_IN   prhs[0]
#define PROPNAME_IN   prhs[1]
#define ICOL_OUT      plhs[0]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    char *s;
    int icol;
    
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
    
    /*--- Which column are we trying to set ? -----------------------------------*/
    
    icol = get_column_number(COLNAMES_IN, s);
    ICOL_OUT = mxCreateDoubleScalar (icol + 1);
    
    mxFree(s);
}
