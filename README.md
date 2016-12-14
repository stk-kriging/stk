
# STK: a Small (Matlab/Octave) Toolbox for Kriging

This README file is part of

*STK: a Small (Matlab/Octave) Toolbox for Kriging*  
<http://sourceforge.net/projects/kriging>

STK is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation,  either version 3  of the License, or  (at your
option) any later version.

STK is distributed  in the hope that it will  be useful, but WITHOUT
ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
License for more details.

You should  have received a copy  of the GNU  General Public License
along with STK.  If not, see <http://www.gnu.org/licenses/>.


## General information

   Version:      See stk_version.m

   Authors:      See AUTHORS file

   Maintainers:  Julien Bect <julien.bect@centralesupelec.fr>
                 and Emmanuel Vazquez <emmanuel.vazquez@centralesupelec.fr>

   Description:  The STK is a (not so) Small Toolbox for Kriging. Its
                 primary focus is on the interpolation/regression
                 technique known as kriging, which is very closely related
                 to Splines and Radial Basis Functions, and can be
                 interpreted as a non-parametric Bayesian method using a
                 Gaussian Process (GP) prior. The STK also provides tools
                 for the sequential and non-sequential design of
                 experiments. Even though it is, currently, mostly geared
                 towards the Design and Analysis of Computer Experiments
                 (DACE), the STK can be useful for other applications
                 areas (such as Geostatistics, Machine Learning,
                 Non-parametric Regression, etc.).

   Copyright:    Large portions are Copyright (C) 2011-2014 SUPELEC.
                 See individual copyright notices for more details.

   License:      GNU General Public License, version 3 (GPLv3).
                 See COPYING for the full license.

   URL:          <http://sourceforge.net/projects/kriging>


## Quick Start

   Run stk_init.m in Matlab(TM) or GNU Octave.

   Once the STK  is properly initialized,  you should be able to run the
   examples located in the 'examples' directory.


## Requirements and recommendations

### Requirements and recommendations for use with GNU Octave

   The STK works with GNU Octave 3.2.2 or newer.

   Note that  the STK relies on some mex files  that are compiled during
   the initialization.  Thus,  your installation must be able to compile
   mex files.  In Debian 6.0 (Squeeze)  or  gNewSense 3.0 (Parkes),  for
   instance,  this means installing octave3.2-headers in addition to the
   base octave3.2 package.

   The sqp() function  internally relies on  the GLPK library,  which is
   shipped with most (but not all) versions of Octave.  The STK will not
   start if GLPK is not installed.

### Requirements and recommendations for use with Matlab

   The STK works with Matlab R2007a or newer.

   The Optimization Toolbox is recommended.

   The Parallel Computing Toolbox is optional.


## Content

   This toolbox is called the Small (Matlab/Octave) Toolbox for Kriging
   (STK). Note that  the STK is meant to be  compatible with Octave and
   Matlab(TM), and  can be automatically configured  with both software
   products. However,  some optional features, such  as the possibility
   to use  parallel computing in  some functions, are not yet available
   when using Octave.

   The STK is free software and  is released under the terms of the GNU
   General Public License, version 3, as published by the Free Software
   Foundation,   and   is   made   available   at   the   web   address
   <http://kriging.sourceforge.net>.

   By publishing this toolbox, the  idea is to provide a convenient and
   flexible research tool for  working with kriging-based methods.  The
   code of the  toolbox is meant to be  easily understandable, modular,
   and reusable.  By  way of illustration, it is very  easy to use this
   toolbox  for implementing  the EGO  algorithm  (Jones et al. 98).
   Besides, this toolbox  can serve as a basis  for  the implementation
   of  advanced  algorithms  such  as  Stepwise  Uncertainty  Reduction
   algorithms (see, e.g., Bect et al. 2010).

   The toolbox consists of three parts:

   1. The  first part is the  implementation of a  number of covariance
      functions, and tools to  compute covariance vectors and matrices.
      The structure  of the STK  makes it possible  to use any  kind of
      covariances:  stationary  or  non-stationary covariances,  aniso-
      tropic covariances, generalized  covariances, etc.

   2. The  second part  is the implementation  of a REMAP  procedure to
      estimate the parameters of the covariance. This makes it possible
      to  deal with generalized  covariances and  to take  into account
      prior knowledge about the parameters of the covariance.

   3. The third part consists of prediction procedures.  In its current
      form,  the STK has been optimized  to deal with  moderately large
      data sets.


## References

   J. Bect, D. Ginsbourger, L. Li, V. Picheny, and E. Vazquez.
   Sequential design of computer experiments for the estimation of a
   probability of failure.  Statistics and Computing, pages 1-21, 2011.
   DOI: 10.1007/s11222-011-9241-4.

   D. R. Jones, M. Schonlau, and William J. Welch. Efficient global
   optimization of expensive black-box functions.  Journal of Global
   Optimization, 13(4):455-492, 1998.


## Ways to get help, report bugs, ask for new features...

   Use the "help" mailing-list:

   <kriging-help@lists.sourceforge.net>
   <https://sourceforge.net/p/kriging/mailman>

   to ask for help on STK, and the ticket manager:

   <https://sourceforge.net/p/kriging/tickets>

   to report bugs or ask for new features.
