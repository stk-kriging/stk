% STK_CHOLCOV  [STK internal]
%
% CALL: C = stk_cholcov (A, ...)
%
%    returns the result of chol (A, ...) when this succeeds. If chol fails,
%    then a small amount of "regularization noise" is added to the diagonal
%    of A, in order to make chol succeed (see the code for details).
%
% NOTE: why this function ?
%
%    This is a first (rough) attempt at solving numerical problems that
%    arise when chol is used with a covariance matrix that is semi-positive
%    definite, or positive definite with some very small eigenvalues. See
%    tickets #3, #4 and #13 on Sourceforge:
%
%       https://sourceforge.net/p/kriging/tickets/3/
%       https://sourceforge.net/p/kriging/tickets/4/
%       https://sourceforge.net/p/kriging/tickets/13/
%
% See also: chol

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (http://sourceforge.net/projects/kriging)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

function C = stk_cholcov (A, varargin)

% try to use a plain "chol"
[C, p] = chol (A, varargin{:});

if p > 0,
    
    epsi = eps;
    u = diag (diag (A));
    
    while p > 0,
        
        if epsi > 1,  % avoids infinite while loops
            if ~ all (isfinite (A(:)))
                errmsg = 'A contains NaNs or Infs.';
            else
                errmsg = 'A is not even close to positive definite';
            end
            stk_error (errmsg, 'InvalidArgument');
        end
        
        epsi = epsi * 10;
        
        [C, p] = chol (A + epsi * u);
        
    end
    
    warning ('STK:stk_cholcov:AddingRegularizationNoise', sprintf ...
        ('Adding a little bit of noise to help chol succeed (epsi = %.2e)', epsi));
    
end

end % function

%#ok<*SPWRN>
