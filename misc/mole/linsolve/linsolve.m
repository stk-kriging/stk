## Copyright (C) 2013 Nir Krakauer
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{x} =} linsolve (@var{A}, @var{b})
## @deftypefnx {Function File} {@var{x} =} linsolve (@var{A}, @var{b}, @var{opts})
## @deftypefnx {Function File} {[@var{x}, @var{R}] =} linsolve (@dots{})
## Solve the linear system @code{A*x = b}.
##
## With no options, this function is equivalent to the left division operator
## @w{(@code{x = A \ b})} or the matrix-left-divide function
## @w{(@code{x = mldivide (A, b)})}.
##
## Octave ordinarily examines the properties of the matrix @var{A} and chooses
## a solver that best matches the matrix.  By passing a structure @var{opts}
## to @code{linsolve} you can inform Octave directly about the matrix @var{A}.
## In this case Octave will skip the matrix examination and proceed directly
## to solving the linear system.
##
## @strong{Warning:} If the matrix @var{A} does not have the properties
## listed in the @var{opts} structure then the result will not be accurate
## AND no warning will be given.  When in doubt, let Octave examine the matrix
## and choose the appropriate solver as this step takes little time and the
## result is cached so that it is only done once per linear system.
##
## Possible @var{opts} fields (set value to true/false):
##
## @table @asis
## @item LT
##   @var{A} is lower triangular
##
## @item UT
##   @var{A} is upper triangular
##
## @item UHESS
##   @var{A} is upper Hessenberg (currently makes no difference)
##
## @item SYM
##   @var{A} is symmetric or complex Hermitian (currently makes no difference)
##
## @item POSDEF
##   @var{A} is positive definite
##
## @item RECT
##   @var{A} is general rectangular (currently makes no difference)
##
## @item TRANSA
##   Solve @code{A'*x = b} by @code{transpose (A) \ b}
## @end table
##
## The optional second output @var{R} is the inverse condition number of
## @var{A} (zero if matrix is singular).
## @seealso{mldivide, matrix_type, rcond}
## @end deftypefn

## Author: Nir Krakauer <nkrakauer@ccny.cuny.edu>

## STK notes:
##  * This version of linsolve.m comes from revision b66f068e4468 of Octave's
##    hg repository (changeset by Nir Krakauer on 2013-09-26, 09:38:51)
##  * The only change that has been made is the introduction of a tolerance
##    in the first assert of the first unit test, that's all !

function [x, R] = linsolve (A, b, opts)

  if (nargin < 2 || nargin > 3)
    print_usage ();
  endif

  if (! (isnumeric (A) && isnumeric (b)))
    error ("linsolve: A and B must be numeric");
  endif

  ## Process any opts
  if (nargin > 2)
    if (! isstruct (opts))
      error ("linsolve: OPTS must be a structure");
    endif
    trans_A = false;
    if (isfield (opts, "TRANSA") && opts.TRANSA)
      trans_A = true;
      A = A';
    endif
    if (isfield (opts, "POSDEF") && opts.POSDEF)
      A = matrix_type (A, "positive definite");
    endif  
    if (isfield (opts, "LT") && opts.LT)
      if (trans_A)
        A = matrix_type (A, "upper");
      else
        A = matrix_type (A, "lower");
      endif
    endif
    if (isfield (opts, "UT") && opts.UT)
      if (trans_A)
        A = matrix_type (A, "lower");
      else
        A = matrix_type (A, "upper");
      endif
    endif        
  endif

  x = A \ b;

  if (nargout > 1)
    if (issquare (A))
      R = rcond (A);
    else
      R = 0;
    endif
  endif
endfunction # linsolve


%!test
%! n = 4;
%! A = triu (rand (n));
%! x = rand (n, 1);
%! b = A' * x;
%! opts.UT = true;
%! opts.TRANSA = true;
%! assert (linsolve (A, b, opts), A' \ b, 1e-12);

%!error linsolve ()
%!error linsolve (1)
%!error linsolve (1,2,3)
%!error <A and B must be numeric> linsolve ({1},2)
%!error <A and B must be numeric> linsolve (1,{2})
%!error <OPTS must be a structure> linsolve (1,2,3)
