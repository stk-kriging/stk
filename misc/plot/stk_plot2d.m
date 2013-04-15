% STK_PLOT2D is a wrapper for 2D {surf|contour|pcolor|mesh}-type plots
%
% FIXME: documentation
%
% See also: stk_example_kb03

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Authors:  Julien Bect           <julien.bect@supelec.fr>
%              Valentin Resseguier   <valentin.resseguier@gmail.com>

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

function stk_plot2d(plotfun, x, arg3, varargin)


%%% Check input arguments

if ~isa(x, 'stk_factorialdesign')
    errmsg = 'x should be an stk_factorialdesign object.';
    stk_error(errmsg, 'IncorrectArgument');
end

dim = size(x, 2);

if dim ~= 2,
    errmsg = 'stk_plot2d only works for two-dimensional factor spaces.';
    stk_error(errmsg, 'IncorrectArgument');
end


%%% Deal with various possible types for the 'z' argument

if ischar(arg3) || isa(arg3, 'function_handle')
    z = double(stk_feval(arg3, x));
else
    z = double(arg3);
end


%%% Do the actual plotting job

[xx1, xx2] = ndgrid(x);

plotfun(xx1, xx2, reshape(z, size(xx1)), varargin{:});

xlabel('x_1', 'FontWeight', 'bold');
ylabel('x_2', 'FontWeight', 'bold');

if ismember(func2str(plotfun), {'surf', 'pcolor'}),
    shading('interp');
end


end % function stk_plot2d
