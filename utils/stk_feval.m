% STK_FEVAL evaluates a function at given evaluation points.
%
% CALL: Z = stk_feval(F, X)
%
%    evaluates the function F on the evaluation points X. F can be either a
%    function handle or a function name (string). X can be either a matrix or a
%    structure whose field 'a' contains the actual values. In both cases, Z will
%    be a structure whose field 'a' contains the responses.
%
% CALL: Z = stk_feval(F, X, DISPLAY_PROGRESS)
%
%    displays progress messages if DISPLAY_PROGRESS is true. This is especially
%    useful if each evaluation of F requires a significant computation time.
%
% EXAMPLE:
%       f = @(x)( -(0.7*x+sin(5*x+1)+0.1*sin(10*x)) );
%       xt = stk_sampling_regulargrid(100, 1, [0; 1]);
%       yt = stk_feval( f, xt );
%       plot(xt.a, yt.a);
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

function z = stk_feval(f, x, progress_msg)

stk_narginchk(2, 3);

if isstruct(x), xdata = x.a; else xdata = x; end
if nargin < 3, progress_msg = false; end

[n,d] = size(xdata);
if d == 0,
    error('zero-dimensional inputs are not allowed.');
end

if n == 0, % no input => no output
    
    zdata = zeros(0, 1);
    
else % at least one input point
    
    zdata = zeros(n, 1);
    for i = 1:n,
        if progress_msg, fprintf('feval %d/%d... ', i, n); end
        zdata(i) = feval(f, xdata(i,:));
        if progress_msg, fprintf('done.\n'); end
    end
    
end

z = struct('a', zdata);

end % function stk_feval


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared f xt
%!  f = @(x)( -(0.7*x+sin(5*x+1)+0.1*sin(10*x)) );
%!  xt = stk_sampling_regulargrid(20, 1, [0; 1]);

%!error  yt = stk_feval();
%!error  yt = stk_feval(f);
%!test   yt = stk_feval(f, xt);
%!test   yt = stk_feval(f, xt, false);
%!error  yt = stk_feval(f, xt, false, pi^2);

%!test
%!  N = 15;
%!  xt = stk_sampling_regulargrid(N, 1, [0; 1]);
%!  yt = stk_feval(f, xt);
%!  assert(isstruct(yt) && isfield(yt, 'a') && isequal(size(yt.a), [N 1]));
