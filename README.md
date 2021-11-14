# STK: a Small (Matlab/Octave) Toolbox for Kriging

[![license](https://img.shields.io/github/license/stk-kriging/stk?style=plastic)](COPYING)
[![last commit](https://img.shields.io/github/last-commit/stk-kriging/stk/master)](https://github.com/stk-kriging/stk/commits/main)
[![unit tests](https://github.com/stk-kriging/stk/actions/workflows/run-unit-tests.yml/badge.svg)](https://github.com/stk-kriging/stk/actions?query=workflow%3Arun-unit-tests++)

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

   Authors:      See AUTHORS.md file

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

   Copyright:    Large portions are Copyright (C) 2011-2014 SUPELEC
                 and Copyright (C) 2015-2019 CentraleSupelec.
                 See individual copyright notices for more details.

   License:      GNU General Public License, version 3 (GPLv3).
                 See COPYING for the full license.

   URL:          <http://sourceforge.net/projects/kriging>


## One toolbox, two flavours

The STK toolbox comes in two flavours:

 * an "all purpose" release, which is suitable for use both with
   [GNU Octave](http://www.gnu.org/software/octave/)
   and with [Matlab](www.mathworks.com/products/matlab/).
 * an Octave package, for people who want to install and use STK as a
   regular [Octave package](http://www.gnu.org/software/octave/doc/interpreter/Packages.html#Packages).

Hint: if you're not sure about the version that you have...

 * the "all purpose" release has this file (`README.md`) and the `stk_init`
   function (`stk_init.m`) in the top-level directory,
 * the Octave package has a `DESCRIPTION` file in the top-level directory
   and this file in the `doc/` subdirectory.


## Quick Start

### Quick start with the "all purpose" release (Matlab/Octave)

Download and unpack an archive of the "all purpose" release from the
[STK project](https://sourceforge.net/projects/kriging/)
[file release system](https://sourceforge.net/projects/kriging/files/)
on SourceForge.

Run `stk_init.m` in either Octave or Matlab.

After that, you should be able to run the examples located in the `examples`
directory.  All of them are scripts, the file name of which starts with
the `stk_example_` prefix.

For instance, type `stk_example_kb03` to run the third example in the "Kriging
basics" series.

### Quick start with the Octave package release (Octave only)

Assuming that you have a working Internet connection, typing `pkg install -forge stk`
(from within Octave) will automatically download the latest STK package tarball from the
[Octave Forge](http://octave.sourceforge.net/stk/index.html)
[file release system](https://sourceforge.net/projects/octave/files/)
on SourceForge and install it for you.

Alternatively, if you want to install an older (or beta) release, you can download
the tarball from either the STK project FRS or the Octave Forge FRS, and install it
with `pkg install FILENAME.tar.gz`.

After that, you can load STK using `pkg load stk`.

To check that STK is properly loaded, try for instance `stk_example_kb03` to run
the third example in the "Kriging basics" series.


## Requirements and recommendations

### Common requirement

   Your installation must be able to compile C mex files.

### Requirements and recommendations for use with GNU Octave

   The STK is tested to work with GNU Octave 3.8.2 or newer, but
   should probably also work with Octave 3.8.0 and 3.8.1.

   Older versions of Octave (<= 3.6.2) are no longer supported, and
   are known to contain bugs that prevent some STK functions from
   working properly.


### Requirements and recommendations for use with Matlab

   The STK works with Matlab R2009b or newer.

   The Optimization Toolbox is recommended.

   The Parallel Computing Toolbox is optional.


## Content

   By publishing this toolbox, the  idea is to provide a convenient and
   flexible research tool for  working with kriging-based methods.  The
   code of the  toolbox is meant to be  easily understandable, modular,
   and reusable.  By  way of illustration, it is very  easy to use this
   toolbox for implementing the EGO algorithm [1].
   Besides, this toolbox  can serve  as a basis for  the implementation
   of  advanced algorithms such as Stepwise Uncertainty Reduction (SUR)
   algorithms [2].

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

### References

[1] D. R. Jones, M. Schonlau, and William J. Welch. *Efficient global
optimization of expensive black-box functions*.  Journal of Global
Optimization, 13(4):455-492, 1998.

[2] J. Bect, D. Ginsbourger, L. Li, V. Picheny, and E. Vazquez.
*Sequential design of computer experiments for the estimation of a
probability of failure*.  Statistics and Computing, pages 1-21, 2011.
DOI: 10.1007/s11222-011-9241-4.


## Ways to get help, report bugs, ask for new features...

   Use the "help" mailing-list:

   <kriging-help@lists.sourceforge.net>
   <https://sourceforge.net/p/kriging/mailman>

   to ask for help on STK, and the ticket manager:

   <https://github.com/stk-kriging/stk/issues>

   to report bugs or ask for new features (do not hesitate to do so!).
