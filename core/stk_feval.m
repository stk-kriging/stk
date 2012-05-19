% STK_FEVAL evaluates a function at given locations points
%
% CALL: z = stk_feval(f, x, progress_msg)
%       f = function handle
%       x = structure whose field 'a' contains the evaluations points
%       z = structure whose field 'a" contains the evaluations results
%       progress_msg = display progress messages ? (default: false)
%
% STK_FEVAL passes the evaluations points x.a to the function f and returns
% the result in z.a. The function f must comply with the convention of the
% STK for the factors; that is, x.a is a NxDIM matrix and f should return a
% column vector.
%
% EXAMPLE:
%       f = @(x)( -(0.7*x+sin(5*x+1)+0.1*sin(10*x)) );
%       xt.a = linspace ( 0, 1, 100 );
%       yt = stk_feval( f, xt );
%       plot(xt.a, yt.a);
%

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging/
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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

if isstruct(x), xdata = x.a; else xdata = x; end
if nargin < 3, progress_msg = false; end

[n,d] = size(xdata);
if d == 0,
    error('zero-dimensional inputs are not allowed.');
end

if n == 0, % no input => no output
    
    zdata = zeros(0,1);
    
else % at least one input point
    
    zdata = zeros(n,1);
    for i = 1:n,
        if progress_msg, fprintf('feval %d/%d... ', i, n); end
        zdata(i) = feval( f, xdata(i,:) );
        if progress_msg, fprintf('done.\n'); end
    end
    
end

z = struct( 'a', zdata );
