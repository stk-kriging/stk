/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2015 CentraleSupelec                                     *
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
#include "wfg.h"

/* We assume in this file that OBJECTIVE is the same as double */

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int i, j, k;          /* loop indices */
  mxArray **mx_fronts;  /* fronts, as mxArray objects */
  FRONT *fronts;        /* fronts, as expected by WFG */
  int nb_fronts;        /* number of Pareto fronts */
  int nb_points;        /* number of points in a given front */
  int nb_objectives;    /* number of objectives for a given front */
  int maxm = 0;         /* maximum number of points in a front */
  int maxn = 0;         /* maximum number of objectives        */
  double *hv;           /* computed hyper-volumes */
  double *data;         /* pointer to input data */

  if (nlhs > 1)   /* Check number of output arguments */
    mexErrMsgTxt ("Too many output arguments.");
  
  if (nrhs != 1)  /* Check number of input arguments */
    mexErrMsgTxt ("Incorrect number of input arguments.");
  
  if (stk_is_realmatrix (prhs[0]))
    {
      nb_fronts = 1;
      mx_fronts = (mxArray**) prhs;
    }
  else if (mxIsCell (prhs[0]))
    {
      mexErrMsgTxt ("Not Implemented yet.");
    }
  else
    {
      mexErrMsgTxt ("Incorrect input type: cell or double expected.");
    }


  /*--- Prepare fronts for WFG ------------------------------------------------*/

  fronts = (FRONT*) mxMalloc (sizeof (FRONT) * nb_fronts);
  for (i = 0; i < nb_fronts; i++)
    {
      nb_points = mxGetM (mx_fronts[i]);
      if (nb_points > maxm) maxm = nb_points;

      nb_objectives = mxGetN (mx_fronts[i]);
      if (nb_objectives > maxn) maxn = nb_objectives;
           
      fronts[i].nPoints = nb_points;
      fronts[i].n = nb_objectives;
      fronts[i].points = (POINT*) mxMalloc (sizeof (POINT) * nb_points);
      
      for (j = 0; j < nb_points; j++)
	{
	  fronts[i].points[j].objectives = (double*)
	    mxMalloc (sizeof (double) * nb_objectives);
	  data = mxGetPr (mx_fronts[i]);
	  for (k = 0; k < nb_objectives; k++)
	    fronts[i].points[j].objectives[k] = data[k * nb_points + j];
	}
    }


  /*--- Allocate memory -------------------------------------------------------*/

  /* Allocate memory for WFG */
  wfg_alloc (maxm, maxn);

  /* Allocate memory for the output argument */
  plhs[0] = mxCreateDoubleMatrix (nb_fronts, 1, mxREAL);
  hv = mxGetPr (plhs[0]);


  /*--- Compute hyper-volumes -------------------------------------------------*/

  for (i = 0; i < nb_fronts; i++)
    hv[i] = wfg_compute_hv (fronts[i]);


  /*--- Free memory -----------------------------------------------------------*/

  wfg_free (maxm, maxn);

  for (i = 0; i < nb_fronts; i++)
    {     
      for (j = 0; j < nb_points; j++)
	mxFree (fronts[i].points[j].objectives);
      mxFree (fronts[i].points);
    }
  mxFree (fronts);

}
