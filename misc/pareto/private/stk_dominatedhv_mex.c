/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2015-2017 CentraleSupelec                                *
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

#include "stk_mex.h"
#include "wfg.h"


/* We assume in this file that OBJECTIVE is the same as double */

double compute_hv (mxArray* f, FRONT *buffer)
{
  size_t i, j;           /* loop indices */
  size_t nb_points;      /* number of points */
  size_t nb_objectives;  /* number of objectives */
  double *data;          /* pointer to input data */
  double hv, t;          /* hypervolume */

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


void compute_decomposition (mxArray* f, FRONT *buffer,
                            mxArray** sign, mxArray** xmin, mxArray** xmax)
{
  size_t i, j;           /* loop indices */
  size_t nb_points;      /* number of points */
  size_t nb_objectives;  /* number of objectives */
  size_t rect_alloc;     /* initial number of rectangles */
  double t;              /* aux variables */
  double *data;          /* pointer to input data */
  RLIST* Rlist;          /* list of hyper-rectangles */
  double *sign_data, *xmin_data, *xmax_data;

  nb_points = mxGetM (f);
  nb_objectives = mxGetN (f);
  data = mxGetPr (f);

  if (nb_objectives == 0)
    {
      if (nb_points > 0)
        mexErrMsgTxt ("nb_objectives == 0 and nb_points > 0: Undefined behaviour.");
      
      *sign = mxCreateDoubleMatrix (0, 0, mxREAL);
      *xmin = mxCreateDoubleMatrix (0, 0, mxREAL);
      *xmax = mxCreateDoubleMatrix (0, 0, mxREAL);
    }
  else if (nb_points == 0)
    {
      *sign = mxCreateDoubleMatrix (0, 1, mxREAL);
      *xmin = mxCreateDoubleMatrix (0, nb_objectives, mxREAL);
      *xmax = mxCreateDoubleMatrix (0, nb_objectives, mxREAL);
    }
  else if (nb_objectives == 1)
    {
      t = data[0];

      for (i = 1; i < nb_points; i++)
        t = ((data[i] > t) ? data[i] : t);

      *sign = mxCreateDoubleMatrix (1, 1, mxREAL);
      *xmin = mxCreateDoubleMatrix (1, 1, mxREAL);
      *xmax = mxCreateDoubleMatrix (1, 1, mxREAL);

      (mxGetPr (*sign))[0] = 1.0;
      (mxGetPr (*xmin))[0] = 0.0;
      (mxGetPr (*xmax))[0] = t;
   }
  else /* two ore more objectives */
    {
      wfg_front_resize (buffer, nb_points, nb_objectives);

      for (i = 0; i < nb_points; i++)
        for (j = 0; j < nb_objectives; j++)
          buffer->points[i].objectives[j] = data[j * nb_points + i];

      /* Rule of thumb: allocate initially for
         ((2 ^ nb_objectives) * nb_points) rectangles */
      rect_alloc = nb_objectives;
      for (i = 0; i < nb_objectives; i++)
        rect_alloc *= 2;

      Rlist = Rlist_alloc (rect_alloc, nb_objectives);

      wfg_compute_decomposition (buffer, Rlist);

      *sign = mxCreateDoubleMatrix (Rlist->size, 1, mxREAL);
      *xmin = mxCreateDoubleMatrix (Rlist->size, nb_objectives, mxREAL);
      *xmax = mxCreateDoubleMatrix (Rlist->size, nb_objectives, mxREAL);

      sign_data = mxGetPr (*sign);
      xmin_data = mxGetPr (*xmin);
      xmax_data = mxGetPr (*xmax);

      /* TODO: optimize using transposed arrays for xmin, xmax
               (mxArrays + internally in the Rlist structure) */
      for (i = 0; i < Rlist->size; i++)
        {
          sign_data[i] = (double) Rlist->sign[i];
          for (j = 0; j < nb_objectives; j++)
            {
              xmin_data[j * Rlist->size + i] = Rlist->xmin[i][j];
              xmax_data[j * Rlist->size + i] = Rlist->xmax[i][j];
            }
        }

      Rlist_free (Rlist);
    }
}


#define Y_IN              prhs[0]
#define DO_DECOMPOSITION  prhs[1]
#define HV_OUT            plhs[0]

static const char* field_names[] = {"sign", "xmin", "xmax"};

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  size_t i;               /* loop indices */
  mxArray **fronts;       /* fronts, as mxArray objects */
  bool do_decomposition;  /* do the decomposition or just return the volume ? */
  FRONT buffer;           /* front structure, as expected by WFG */
  size_t nb_fronts;       /* number of Pareto fronts */
  size_t nb_points;       /* number of points in a given front */
  size_t nb_objectives;   /* number of objectives for a given front */
  size_t maxm = 0;        /* maximum number of points in a front */
  size_t maxn = 0;        /* maximum number of objectives        */
  double *hv;             /* computed hyper-volumes */
  bool must_free_fronts;  /* flag: do we need to free 'fronts' ? */
  mxArray* sign;          /* temp array of signs (do_decomposition = true) */
  mxArray* xmin;          /* temp array of lower bounds (do_decomposition = true) */
  mxArray* xmax;          /* temp array of upper bounds (do_decomposition = true) */

  if (nlhs > 1)   /* Check number of output arguments */
    mexErrMsgTxt ("Too many output arguments.");

  if (nrhs != 2)  /* Check number of input arguments */
    mexErrMsgTxt ("Incorrect number of input arguments.");

  if (stk_is_realmatrix (Y_IN))
    {
      nb_fronts = 1;
      fronts = (mxArray**) prhs;
      must_free_fronts = false;
    }
  else if (mxIsCell (Y_IN))
    {
      nb_fronts = mxGetNumberOfElements (Y_IN);
      fronts = (mxArray**) mxMalloc (sizeof (mxArray*) * nb_fronts);
      for (i = 0; i < nb_fronts; i++)
        fronts[i] = mxGetCell (Y_IN, i);
      must_free_fronts = true;
    }
  else
    {
      mexErrMsgTxt ("Incorrect type for argin #1: cell or double expected.");
      nb_fronts = 0;             /* avoids unitialized variable warning */
      fronts = NULL;             /* idem */
      must_free_fronts = false;  /* idem */
    }

  if (mxIsLogicalScalar (DO_DECOMPOSITION))
    {
      do_decomposition = (bool) *mxGetLogicals (DO_DECOMPOSITION);
    }
  else
    {
      mexErrMsgTxt ("Incorrect type for argin #2: logical scalar expected.");
      do_decomposition = false;  /* avoids unitialized variable warning */
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

  /* Allocate memory for WFG */
  wfg_alloc (maxm, maxn);


  /*--- Compute hyper-volumes or decomposition -------------------------------*/

  if (do_decomposition)
    {
      if (nb_fronts == 1)
        {
          HV_OUT = mxCreateStructMatrix (1, 1, 3, field_names);
        }
      else
        {
          HV_OUT = mxCreateStructArray (mxGetNumberOfDimensions (Y_IN),
                                        mxGetDimensions (Y_IN), 3, field_names);
        }

      for (i = 0; i < nb_fronts; i++)
        {
          compute_decomposition (fronts[i], &buffer, &sign, &xmin, &xmax);
          mxSetFieldByNumber (HV_OUT, i, 0, sign);
          mxSetFieldByNumber (HV_OUT, i, 1, xmin);
          mxSetFieldByNumber (HV_OUT, i, 2, xmax);
        }
    }
  else
    {
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

      for (i = 0; i < nb_fronts; i++)
        hv[i] = compute_hv (fronts[i], &buffer);
    }


  /*--- Free memory ----------------------------------------------------------*/

  wfg_free (maxm, maxn);

  wfg_front_destroy (&buffer);

  if (must_free_fronts)
    mxFree (fronts);
}
