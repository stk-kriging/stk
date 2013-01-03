% STK_FEVAL evaluates a function at given evaluation points.
%
% CALL: Z = stk_feval(F, X)
%       F = function handle
%       X = matrix or structure (see below)
%       Z = structure whose field 'a' contains the evaluations results
%
%    evaluates the function F on the evaluation points X. F can be either a
%    function handle or a function name (string). X can be either a matrix or a
%    structure whose field 'a' contains the actual values. In both cases, Z will
%    be a structure that contains the responses.
%
% CALL: Z = stk_feval(F, X, DISPLAY_PROGRESS)
%
%    displays progress messages if DISPLAY_PROGRESS is true. This is especially
%    useful if each evaluation of F requires a significant computation time.
%
% EXAMPLE:
%       f = @(x)( -(0.7*x+sin(5*x+1)+0.1*sin(10*x)) );
%       xt.a = linspace ( 0, 1, 100 );
%       zt = stk_feval( f, xt );
%       plot(xt.a, zt.a);
%
% See also feval

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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
%
function z = stk_feval(f, x, progress_msg)

stk_narginchk(2, 3);

if ~isstruct(x), x.a = x; end % we assume that x is a matrix here
if nargin < 3, progress_msg = false; end

[n, d] = size(x.a);

if d == 0,
    error('zero-dimensional inputs are not allowed.');
end

if n > 0, % at least one input point
    
    z.a = zeros(n,1);
    for i = 1:n,
        if progress_msg, fprintf('feval %d/%d... ', i, n); end
        z.a(i) = feval( f, x.a(i,:) );
        if progress_msg, fprintf('done.\n'); end
    end
    
end