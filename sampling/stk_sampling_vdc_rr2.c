/*****************************************************************************
 *                                                                           *
 *                  Small (Matlab/Octave) Toolbox for Kriging                *
 *                                                                           *
 * Copyright Notice                                                          *
 *                                                                           *
 *    Copyright  (C) 2013 Alexandra Krauth, Elham Rahali & SUPELEC           *
 *                                                                           *
 *    Authors:  Julien Bect       <julien.bect@supelec.fr>                   *
 *              Alexandra Krauth  <alexandrakrauth@gmail.com>                *
 *              Elham Rahali      <elham.rahali@gmail.com>                   *
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

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "stk_mex.h"
#include "primes.h"


/*****************************************************************************
 *                                                                           *
 *  Main function: compute N terms of the j^th RR2-scrambled vdC sequence    *
 *                                                                           *
 *  Reference:  Ladislav Kocis and William J. Whiten (1997)                  *
 *              Computational investigations of lowdiscrepancy sequences.    *
 *              ACM Transactions on Mathematical Software, 23(2):266-294.    *
 *                                                                           *
 ****************************************************************************/

int vanDerCorput_RR2(unsigned int b, unsigned int n, double *h);

#define  N_IN   prhs[0]
#define  D_IN   prhs[1]
#define  X_OUT  plhs[0]

void mexFunction
(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int n_, j_, r;
  unsigned int n, j;
  double *h;
  mxArray* xdata;

  /*--- Read input arguments -----------------------------------------------*/

  if(nrhs != 2)
    mexErrMsgIdAndTxt("STK:stk_sampling_vdc_rr2:nrhs", "Two inputs required.");

  if ((mxReadScalar_int(N_IN, &n_) != 0) || (n_ <= 0))
    mexErrMsgIdAndTxt("STK:stk_sampling_vdc_rr2:IncorrectArgument", 
		      "First argument (n) must be a strictly positive "
		      "scalar integer.");
  
  n = (unsigned int) n_;

  if ((mxReadScalar_int(D_IN, &j_) != 0) || (j_ <= 0))
    mexErrMsgIdAndTxt("STK:stk_sampling_vdc_rr2:IncorrectArgument", 
		      "Second argument (j) must be a scrictly positive "
		      "scalar integer.");

  j = (unsigned int) j_;

  if (j > PRIMES_TABLE_SIZE)
    mexErrMsgIdAndTxt("STK:stk_sampling_vdc_rr2:IncorrectArgument", 
		      "Second argument (d) must be smaller than %d.",
		      PRIMES_TABLE_SIZE);
  
  /*--- Do the actual computations in a subroutine -------------------------*/

  xdata = mxCreateDoubleMatrix(n, 1, mxREAL);
  h = mxGetPr(xdata);
  
  if ((r = vanDerCorput_RR2(primes_table[j - 1], n, h)) != STK_OK)
    mexErrMsgIdAndTxt("STK:stk_sampling_vdc_rr2:Sanity", 
		      "vanDerCorput_RR2() failed with error code %d.", r);
  
  /*--- Create output dataframe --------------------------------------------*/

  if ((r = mexCallMATLAB(1, &X_OUT, 1, &xdata, "stk_dataframe")) != 0)
    mexErrMsgIdAndTxt("STK:stk_sampling_vdc_rr2:Sanity", 
		      "mexCallMATLAB() failed with error code %d.", r);

}


/*****************************************************************************
 *                                                                           *
 *   Subfunctions                                                            *
 *                                                                           *
 ****************************************************************************/

int     compute_nb_digits(unsigned int n, unsigned int b);
double  radical_inverse(int *digits, unsigned int nb_digits, unsigned int b);
int     next_Mersenne_number(unsigned int b);
int     construct_permutRR(unsigned int b, int* permut);
int     construct_permutRR_Mersenne(unsigned int b, int* permut);


/*****************************************************************************
 *                                                                           *
 * void vanDerCorput_RR2(unsigned int b, unsigned int N, double *result)     *
 *                                                                           *
 * Compute N terms of the RR2-scrambled van der Corput sequence in base b.   *
 *                                                                           *
 ****************************************************************************/

int vanDerCorput_RR2
(unsigned int b, unsigned int N, double *result)
{
  int i, j, c, nb_digits_max, nb_digits, quotient;
  int *permut, *digits, *s_digits;
    
  /*--- Check input arguments ----------------------------------------------*/

  if (N == 0)
    return STK_OK; /* we successfully did... nothing... */

  if (b == 0) /* 0 is not a prime */
    return STK_ERROR_DOMAIN;
  
  /*--- Allocate temporary arrays ------------------------------------------*/

  /* Create arrays to store base-b representations
     (note: N is the biggest integer that we'll have to represent) */
  if ((nb_digits_max = compute_nb_digits(N, b)) == -1)
    return STK_ERROR_SANITY;
  if ((digits = (int*) mxCalloc(nb_digits_max, sizeof(int))) == NULL)
    return STK_ERROR_OOM;
  if ((s_digits = (int*) mxCalloc(nb_digits_max, sizeof(int))) == NULL)
    return STK_ERROR_OOM;

  /* Create the permutation array */    
  if ((permut = (int*) mxCalloc(b, sizeof(int))) == NULL)
    return STK_ERROR_OOM;
  construct_permutRR(b, permut);

  /*--- Compute N terms in the base-b of the sequence ----------------------*/
    
  nb_digits = 1;      /* number of digits required to represent 1 in base b */
  c = b;              /* number of iterations before we increment nb_digits */
    
  /* note: the first term is always zero, that's why we start at i = 1 */
    
  for (i = 1; i < N; i++)
    {

      if ((--c) == 0) /* we need to increase the number of digits */
        {
          nb_digits++;
          c = i * (b - 1);
        }

      /* Compute the representation of i in base b 
         (no need to fill with zeros at the end) */
      quotient = i;
      j = 0;
      while (quotient > 0)
        {
          digits[j] = quotient % b;
          quotient = quotient / b;
          j++;
        }
        
      /* Scramble the digits */
      for(j = 0; j < nb_digits; j++)
        s_digits[j] = permut[digits[j]];

      /* Compute the i^th term using the radical inverse function */
      result[i] = radical_inverse(s_digits, nb_digits, b);

    }

  /*--- Free temporary arrays ----------------------------------------------*/

  mxFree(digits);
  mxFree(s_digits);
  mxFree(permut);
  
  return STK_OK;
}


/*****************************************************************************
 *                                                                           *
 * void construct_permutRR(unsigned int b, int* pi_b)                        *
 *                                                                           *
 * Compute N terms of the RR2-scrambled van der Corput sequence in base b.   *
 *                                                                           *
 ****************************************************************************/

int construct_permutRR
(unsigned int b, int* pi_b)
{
  int i, j, b_max, *pi_b_max;

  /* Find the smallest number of the form 2^k - 1 (Mersenne number) that is 
     greater than or equal to b. This number is not necessarily prime. */

  b_max = next_Mersenne_number(b);

  /* Create an auxiliary permutation of {0, 1, ..., b_max - 1} */

  if ((pi_b_max = mxCalloc(b_max, sizeof(int))) == NULL)
    return STK_ERROR_OOM;

  construct_permutRR_Mersenne(b_max, pi_b_max);

  /* Trim pi_b_max to get pi_b (note: the first element is always 0) */

  j = 1;
  for (i = 1; i < b; i++)
    {
      while (pi_b_max[j] > (b - 1))
	j++;
      pi_b[i] = pi_b_max[j++];
    }

  mxFree(pi_b_max);
}


/*****************************************************************************
 *                                                                           *
 * int construct_permutRR_Mersenne(unsigned int b, int *permut)              *
 *                                                                           *
 * Construct the "reverse radix" permutation in the case where b is a        *
 * Mersenne number.                                                          *
 *                                                                           *
 * Note: careful, we do not actually check that b is a Mersenne number       *
 *                                                                           *
 ****************************************************************************/

int construct_permutRR_Mersenne
(unsigned int b, int *permut)
{
  int i, j, direct, reversed, digits;
  
  if ((digits = compute_nb_digits(b - 1, 2)) == -1)
    return STK_ERROR_SANITY;
  
  permut[0] = 0;

  for (i = 1; i < b; i++)
    {
      direct = i;
      reversed = 0;
      for(j = 0; j < digits; j++)
	{
	  reversed <<= 1;
	  reversed += (direct & 01);
	  direct >>= 1;
	}        
      permut[i] = reversed;
    }  
}


/*****************************************************************************
 *                                                                           *
 * int compute_nb_digits(unsigned int n, unsigned int b)                     *
 *                                                                           *
 * Compute the number of digits required to represent n in base b.           *
 *                                                                           *
 ****************************************************************************/     
 
int compute_nb_digits
(unsigned int n, unsigned int b)
{
  int nb_digits, quotient;

  if ((b <= 0) || (n <= 0))
    return -1;

  nb_digits = 0;
  quotient = n;
  
  while (quotient > 0)
    {
      nb_digits++;
      quotient = quotient / b;
    }

  return nb_digits;
}


/*****************************************************************************
 *                                                                           *
 * double radical_inverse                                                    *
 * (int *digits, unsigned int nb_digits, unsigned int b)                     *
 *                                                                           *
 * Apply the base-b radical inverse transform to a number given through its  *
 * base-b representation                                                     *
 *                                                                           *
 ****************************************************************************/     

double radical_inverse
(int *digits, unsigned int nb_digits, unsigned int b)
{
  int i, b_pow_inv;
  double sum;
 
  b_pow_inv = 1;
  sum = 0;

  for (i = 0; i < nb_digits; i++)
    {
      b_pow_inv *= b;
      sum += ((double) digits[i]) / ((double)b_pow_inv);
    }

  return sum;
}


/*****************************************************************************
 *                                                                           *
 * int next_Mersenne_number(unsigned int b)                                  *
 *                                                                           *
 * Compute the first integer bigger than b that is of the form               *
 *                                                                           *
 *    2^k - 1,    with k an integer                                          *
 *                                                                           *
 ****************************************************************************/     

int next_Mersenne_number
(unsigned int b)
{
  int m = 0;
  
  while (m < b)
    {
      m <<= 1;
      m += 1;
    }

  return m;
}


