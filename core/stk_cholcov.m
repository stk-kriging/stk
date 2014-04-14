% STK_CHOLCOV computes the Cholesky factorization of a covariance matrix
%
% CALL: C = stk_cholcov (A, ...)
%
%   returns the result of chol (A, ...) when this succeeds. If chol fails,
%   then a small amount of "regularization noise" is added to the diagonal
%   of A, in order to make chol succeed (see the code for details).
%
% See also: chol

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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
    
        epsi = epsi * 10;
        
        warning ('STK:stk_cholcov:AddingRegularizationNoise', sprintf ...
            ('Adding a little bit of noise to help chol succeed (epsi = %.2e)', epsi));
        
        [C, p] = chol (A + epsi * u);
        
    end
    
end

end % function stk_cholcov

%#ok<*SPWRN>
