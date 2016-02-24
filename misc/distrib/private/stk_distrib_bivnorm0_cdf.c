/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright (C) 2014 Supelec                                             *
 *                                                                           *
 *    Author:  Julien Bect  <julien.bect@centralesupelec.fr>                 *
 *                                                                           *
 *    Based on mvndstpack.f by Yihong Ge and Alan Genz                       *
 *     (see original copyright notice below)                                 *
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

double bvu (double h, double k, double rho);
double mvnphi (double z);

#define MAX(a,b) ((a) >= (b) ? (a) : (b))
#define BIGNUM 40.0  /* this is BIG for a normal deviate */

#define ARGIN_UPPER   prhs[0]  /* n x 2 */
#define ARGIN_RHO     prhs[1]  /* n x 1 */
#define ARGOUT_PROBA  plhs[0]  /* n x 1 */
#define ARGOUT_QROBA  plhs[1]  /* n x 1 */

void mexFunction
(
  int nlhs, mxArray *plhs[],
  int nrhs, const mxArray *prhs[]
)
{
  size_t n;  int i;  double *u1, *u2, *rho, *proba, *qroba;
  double q01, q10, q11;
  mxArray *mxProba, *mxQroba;

  /*--- check number of input / output arguments -------------------------*/

  if (nrhs != 2)
    {
      mexErrMsgTxt ("Incorrect number of input arguments.");
    }

  if (nlhs > 2)
    {
      mexErrMsgTxt ("Too many output arguments.");
    }

  /*--- check input arguments types -------------------------------------*/

  if ((! stk_is_realmatrix (ARGIN_UPPER)) || (mxGetN (ARGIN_UPPER) != 2))
    {
      mexErrMsgTxt ("Input argument #1 (upper) should be a real "
                    "double-precision matrix with two columns.");
    }

  if ((! stk_is_realmatrix (ARGIN_RHO)) || (mxGetN (ARGIN_RHO) != 1))
    {
      mexErrMsgTxt ("Input argument #2 (rho) should be a real "
                    "double-precision column vector.");
    }

  n = mxGetM (ARGIN_UPPER);

  if (mxGetM (ARGIN_RHO) != n)
    {
      mexErrMsgTxt ("Input arguments #1 (upper) and #2 (rho) should "
                    "have the same number of rows");
    }

  /*--- prepare the output argument --------------------------------------*/

  mxProba = mxCreateDoubleMatrix (n, 1, mxREAL);
  mxQroba = mxCreateDoubleMatrix (n, 1, mxREAL);

  /*--- get pointers to the actual data ----------------------------------*/

  u1    = mxGetPr (ARGIN_UPPER);
  u2    = u1 + n;
  rho   = mxGetPr (ARGIN_RHO);
  proba = mxGetPr (mxProba);
  qroba = mxGetPr (mxQroba);

  /*--- compute probabilities --------------------------------------------*/

  for (i = 0; i < n; i++)
    {
      if ((u1[i] < - BIGNUM) || (u2[i] < - BIGNUM))
	{
	  proba[i] = 0.0;
	  qroba[i] = 1.0;
	}
      else if (u1[i] > BIGNUM)
	{
	  if (u2[i] < 0)
	    {
	      proba[i] = mvnphi (u2[i]);
	      qroba[i] = 1 - proba[i];
	    }
	  else
	    {
	      qroba[i] = mvnphi (- u2[i]);
	      proba[i] = 1 - qroba[i];
	    }
	}
      else if (u2[i] > BIGNUM)
	{
	  if (u1[i] < 0)
	    {
	      proba[i] = mvnphi (u1[i]);
	      qroba[i] = 1 - proba[i];
	    }
	  else
	    {
	      qroba[i] = mvnphi (- u1[i]);
	      proba[i] = 1 - qroba[i];
	    }
	}
      else if ((u1[i] < 0) || (u2[i] < 0))
	{
	  proba[i] = bvu (- u1[i], - u2[i], rho[i]);
	  qroba[i] = 1 - proba[i];
	}
      else
	{
	  q11 = bvu (u1[i], u2[i], rho[i]);
	  q10 = (mvnphi (- u1[i])) - q11;  q10 = MAX(q10, 0);
	  q01 = (mvnphi (- u2[i])) - q11;  q01 = MAX(q01, 0);
	  qroba[i] = q11 + q01 + q10;
	  proba[i] = 1 - qroba[i];
	}
    }

  /*--- the end ----------------------------------------------------------*/

  ARGOUT_PROBA = mxProba;

  if (nlhs > 1)
    ARGOUT_QROBA = mxQroba;
  else
    mxDestroyArray (mxQroba);

}


/**************************************************************************
 *                                                                        *
 * The following code has been obtained by translating the Fortran code   *
 * mvndstpack.f to C using f2c (version 20100827) and then extracting and *
 * manually cleaning up the relevant functions.                           *
 *                                                                        *
 * mvndstpack.f was obtained by HTTP on 2014/12/09 from:                  *
 *                                                                        *
 *   http://www.math.wsu.edu/faculty/genz/software/fort77/mvtdstpack.f    *
 *                                                                        *
 * It is distributed under the following ("modified BSD") licence:        *
 *                                                                        *
 * Copyright (C) 2013, Alan Genz,  All rights reserved.                   *
 *                                                                        *
 * Redistribution and use in source and binary forms, with or without     *
 * modification, are permitted provided the following conditions are met: *
 *   1. Redistributions of source code must retain the above copyright    *
 *      notice, this list of conditions and the following disclaimer.     *
 *   2. Redistributions in binary form must reproduce the above copyright *
 *      notice, this list of conditions and the following disclaimer in   *
 *      the documentation and/or other materials provided with the        *
 *      distribution.                                                     *
 *   3. The contributor name(s) may not be used to endorse or promote     *
 *      products derived from this software without specific prior        *
 *      written permission.                                               *
 *                                                                        *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    *
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      *
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS      *
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE         *
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,    *
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,   *
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS  *
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND *
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR  *
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF USE *
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   *
 *                                                                        *
 **************************************************************************/

/**************************************************************************
 *                                                                        *
 *   A function for computing bivariate normal probabilities              *
 *                                                                        *
 *       Yihong Ge                                                        *
 *       Department of Computer Science and Electrical Engineering        *
 *       Washington State University                                      *
 *       Pullman, WA 99164-2752                                           *
 *                                                                        *
 *   and                                                                  *
 *                                                                        *
 *       Alan Genz                                                        *
 *       Department of Mathematics                                        *
 *       Washington State University                                      *
 *       Pullman, WA 99164-3113                                           *
 *       Email : alangenz@wsu.edu                                         *
 *                                                                        *
 * double bvu (double h, double k, double *r__)                           *
 *                                                                        *
 * Calculate the probability that X > h and Y > k for a standard          *
 * bivariate Gaussian vector (X, Y) with correlation coefficient *r__     *
 *                                                                        *
 **************************************************************************/

double bvu (double h, double k, double rho)
{
  static struct
  {
    double e_1[3];
    double fill_2[7];
    double e_3[6];
    double fill_4[4];
    double e_5[10];
  }
  equiv_122 =
  {
    .1713244923791705, .3607615730481384,
    .4679139345726904, {0}, .04717533638651177, .1069393259953183,
    .1600783285433464, .2031674267230659, .2334925365383547,
    .2491470458134029, {0}, .01761400713915212,
    .04060142980038694, .06267204833410906, .08327674157670475,
    .1019301198172404, .1181945319615184, .1316886384491766,
    .1420961093183821, .1491729864726037, .1527533871307259
  };

#define w ((double *)&equiv_122)

  static struct
  {
    double e_1[3];
    double fill_2[7];
    double e_3[6];
    double fill_4[4];
    double e_5[10];
  }
  equiv_123 =
  {
    -.9324695142031522, -.6612093864662647,
    -.238619186083197, {0}, -.9815606342467191, -.904117256370475,
    -.769902674194305, -.5873179542866171, -.3678314989981802,
    -.1252334085114692, {0}, -.9931285991850949,
    -.9639719272779138, -.9122344282513259, -.8391169718222188,
    -.7463319064601508, -.636053680726515, -.5108670019508271,
    -.3737060887154196, -.2277858511416451, -.07652652113349733
  };

#define x ((double *)&equiv_123)

  /* System generated locals */
  int i__1;
  double d__1, d__2;

  /* Local variables */
  double a, b, c__, d__;
  int i__, lg, ng;
  double as;
  double bs, hk, hs, sn, rs, xs, bvn, asr;  

  /*     Gauss Legendre Points and Weights, N =  6 */
  /*     Gauss Legendre Points and Weights, N = 12 */
  /*     Gauss Legendre Points and Weights, N = 20 */

  if (fabs(rho) < .3f)
    {
      ng = 1;
      lg = 3;
    }
  else if (fabs(rho) < .75f)
    {
      ng = 2;
      lg = 6;
    }
  else
    {
      ng = 3;
      lg = 10;
    }

  hk = h * k;
  bvn = 0.;

  if (fabs(rho) < .925f)
    {
      hs = (h * h + k * k) / 2;
      asr = asin(rho);
      i__1 = lg;
      for (i__ = 1; i__ <= i__1; ++i__)
        {
          sn = sin(asr * (x[i__ + ng * 10 - 11] + 1) / 2);
          bvn += w[i__ + ng * 10 - 11] * exp((sn * hk - hs) / (1 - sn * sn));
          sn = sin(asr * (-x[i__ + ng * 10 - 11] + 1) / 2);
          bvn += w[i__ + ng * 10 - 11] * exp((sn * hk - hs) / (1 - sn * sn));
        }
      d__1 = -h;
      d__2 = -k;
      bvn = bvn * asr / 12.566370614359172 + mvnphi(d__1) * mvnphi(d__2);
    }
  else
    {
      if (rho < 0.)
        {
          k = -k;
          hk = -hk;
        }

      if (fabs(rho) < 1.)
        {
          as = (1 - rho) * (rho + 1);
          a = sqrt(as);

          /* Computing 2nd power */
          d__1 = h - k;
          bs = d__1 * d__1;
          c__ = (4 - hk) / 8;
          d__ = (12 - hk) / 16;
          bvn = a * exp(-(bs / as + hk) / 2)
                * (1 - c__ * (bs - as)
                   * (1 - d__ * bs / 5) / 3 + c__ * d__ * as * as / 5);

          if (hk > -160.)
            {
              b = sqrt(bs);
              d__1 = -b / a;
              bvn -= exp(-hk / 2) * sqrt(6.283185307179586) * mvnphi(d__1)
                     * b * (1 - c__ * bs * (1 - d__ * bs / 5) / 3);
            }

          a /= 2;
          i__1 = lg;
          for (i__ = 1; i__ <= i__1; ++i__)
            {
              /* Computing 2nd power */
              d__1 = a * (x[i__ + ng * 10 - 11] + 1);
              xs = d__1 * d__1;
              rs = sqrt(1 - xs);

              bvn += a * w[i__ + ng * 10 - 11]
                     * (exp(-bs / (xs * 2) - hk / (rs + 1))
                        / rs - exp(-(bs / xs + hk) / 2)
                        * (c__ * xs * (d__ * xs + 1) + 1));

              /* Computing 2nd power */
              d__1 = -x[i__ + ng * 10 - 11] + 1;
              xs = as * (d__1 * d__1) / 4;
              rs = sqrt(1 - xs);

              /* Computing 2nd power */
              d__1 = rs + 1;
              bvn += a * w[i__ + ng * 10 - 11] * exp(-(bs / xs + hk) / 2) *
                     (exp(-hk * xs / (d__1 * d__1 * 2)) / rs - (c__ * xs *
                         (d__ * xs + 1) + 1));
            }

          bvn = -bvn / 6.283185307179586;
        }

      if (rho > 0.)
        {
          d__1 = - MAX(h,k);
          bvn += mvnphi(d__1);
        }
      else
        {
          bvn = -bvn;
          if (k > h)
            {
              if (h < 0.)
                {
                  bvn = bvn + mvnphi(k) - mvnphi(h);
                }
              else
                {
                  d__1 = - h;
                  d__2 = - k;
                  bvn = bvn + mvnphi(d__1) - mvnphi(d__2);
                }
            }
        }
    }

  return bvn;

} /* bvu */


/**************************************************************************
 *                                                                        *
 *     Normal distribution probabilities accurate to 1d-15.               *
 *     Reference: J.L. Schonfelder, Math Comp 32(1978), pp 1232-1240.     *
 *                                                                        *
 **************************************************************************/

double mvnphi (double z)
{
  static double a[44] =
  {
    .610143081923200417926465815756,
    -.434841272712577471828182820888,.176351193643605501125840298123,
    -.060710795609249414860051215825,.017712068995694114486147141191,
    -.004321119385567293818599864968,8.54216676887098678819832055e-4,
    -1.2715509060916274262889394e-4,1.1248167243671189468847072e-5,
    3.13063885421820972630152e-7,-2.70988068537762022009086e-7,
    3.0737622701407688440959e-8,2.515620384817622937314e-9,
    -1.02892992132031912759e-9,2.9944052119949939363e-11,
    2.605178968726693629e-11,-2.634839924171969386e-12,
    -6.43404509890636443e-13,1.12457401801663447e-13,
    1.7281533389986098e-14,-4.264101694942375e-15,
    -5.45371977880191e-16,1.58697607761671e-16,2.0899837844334e-17,
    -5.900526869409e-18,-9.41893387554e-19,2.1497735647e-19,
    4.6660985008e-20,-7.243011862e-21,-2.387966824e-21,1.91177535e-22,
    1.20482568e-22,-6.72377e-25,-5.747997e-24,-4.28493e-25,
    2.44856e-25,4.3793e-26,-8.151e-27,-3.089e-27,9.3e-29,1.74e-28,
    1.6e-29,-8e-30,-2e-30
  };

  /* Builtin functions */
  double exp(double);

  /* Local variables */
  double b;
  int i__;
  double p, t, bm, bp, xa;

  xa = fabs(z) / 1.414213562373095048801688724209;

  if (xa > 100.)
    {
      p = 0.;
    }
  else
    {
      t = (xa * 8 - 30) / (xa * 4 + 15);
      bm = 0.;
      b = 0.;

      for (i__ = 24; i__ >= 0; --i__)
        {
          bp = b;
          b = bm;
          bm = t * b - bp + a[i__];
        }

      p = exp(-xa * xa) * (bm - bp) / 4;
    }

  if (z > 0.)
    {
      p = 1 - p;
    }

  return p;

} /* mvnphi */
