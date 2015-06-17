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

double compute_hv (mxArray* f, FRONT *buffer)
{
  int i, j;             /* loop indices */
  int nb_points;        /* number of points */
  int nb_objectives;    /* number of objectives */
  double *data;         /* pointer to input data */
  double hv, t;         /* hypervolume */

  nb_points = mxGetM (f);
  if (nb_points == 0)
      return 0.0;

  nb_objectives = mxGetN (f);
  data = mxGetPr (f);

  if (nb_objectives == 0)
    {
      return 0.0;
    }
  else if (nb_objectives == 1)
    {
        /* one objective: return the max */
        hv = 0;
        for (i = 0; i < nb_points; i++)
          {
            t = data[i];
            if (t > hv)  hv = t;
          }
        return hv;
    }
  else /* two ore more objectives */
    {
      wfg_front_resize (buffer, nb_points, nb_objectives);

      for (i = 0; i < nb_points; i++)
        for (j = 0; j < nb_objectives; j++)
          buffer->points[i].objectives[j] = data[j * nb_points + i];

      return wfg_compute_hv (buffer);
    }
}

#define Y_IN    prhs[0]
#define HV_OUT  plhs[0]

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int i;                /* loop indices */
  mxArray **fronts;     /* fronts, as mxArray objects */
  FRONT buffer;         /* front structure, as expected by WFG */
  int nb_fronts;        /* number of Pareto fronts */
  int nb_points;        /* number of points in a given front */
  int nb_objectives;    /* number of objectives for a given front */
  int maxm = 0;         /* maximum number of points in a front */
  int maxn = 0;         /* maximum number of objectives        */
  double *hv;           /* computed hyper-volumes */
  int must_free_fronts; /* flag: do we need to free 'fronts' ? */

  if (nlhs > 1)   /* Check number of output arguments */
    mexErrMsgTxt ("Too many output arguments.");

  if (nrhs != 1)  /* Check number of input arguments */
    mexErrMsgTxt ("Incorrect number of input arguments.");

  if (stk_is_realmatrix (Y_IN))
    {
      nb_fronts = 1;
      fronts = (mxArray**) prhs;
      must_free_fronts = 0;
    }
  else if (mxIsCell (Y_IN))
    {
      nb_fronts = mxGetNumberOfElements (Y_IN);
      fronts = (mxArray**) mxMalloc (sizeof (mxArray*) * nb_fronts);
      for (i = 0; i < nb_fronts; i++)
        fronts[i] = mxGetCell (Y_IN, i);
      must_free_fronts = 1;
    }
  else
    {
      mexErrMsgTxt ("Incorrect input type: cell or double expected.");
    }

  /*--- Prepare fronts for WFG -----------------------------------------------*/

  for (i = 0; i < nb_fronts; i++)
    {
      nb_points = mxGetM (fronts[i]);
      if (nb_points > maxm) maxm = nb_points;

      nb_objectives = mxGetN (fronts[i]);
      if (nb_objectives > maxn) maxn = nb_objectives;
    }

  wfg_front_init (&buffer, maxm, maxn);


  /*--- Allocate memory ------------------------------------------------------*/

  /* Allocate memory for WFG */
  wfg_alloc (maxm, maxn);

  /* Allocate memory for the output argument */
  if (nb_fronts == 1)
    {
      HV_OUT = mxCreateDoubleScalar (1);
    }
  else
    {
      HV_OUT = mxCreateNumericArray (mxGetNumberOfDimensions (Y_IN),
        mxGetDimensions (Y_IN), mxDOUBLE_CLASS, mxREAL);
    }
  hv = mxGetPr (HV_OUT);

  /*--- Compute hyper-volumes ------------------------------------------------*/

  for (i = 0; i < nb_fronts; i++)
    hv[i] = compute_hv (fronts[i], &buffer);


  /*--- Free memory ----------------------------------------------------------*/

  wfg_free (maxm, maxn);

  wfg_front_destroy (&buffer);

  if (must_free_fronts)
    mxFree (fronts);
}
