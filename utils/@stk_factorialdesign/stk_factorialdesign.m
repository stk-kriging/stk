% STK_FACTORIALDESIGN [FIXME: missing doc...]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect  <julien.bect@supelec.fr>

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

function x = stk_factorialdesign(levels, varargin)

% number of factors
d = length(levels);

if ~iscell(levels) || (numel(levels) ~= d)
    errmsg = 'Expecting a "flat" cell array as first argument.';
    stk_error(errmsg, 'TypeMismatch');
end

% number of levels per factor
nlevels = zeros(1, d);

for j = 1:d,    
    if ~isnumeric(levels{j}),
        errmsg = 'Only numeric factors are currently supported.';
        stk_error(errmsg, 'TypeMismatch');
    end
    nlevels(j) = length(levels{j});
    if numel(levels{j}) ~= nlevels(j),
        errmsg = 'A VECTOR of levels is expected for each factor.';
        stk_error(errmsg, 'IncorrectSize');
    end
end

% number of points
n = prod(nlevels);

% coordinate arrays
if d == 1,
    coord = levels;
else
    coord = cell(1, d);
    [coord{:}] = ndgrid(levels{:});
end

% design matrix
xdata = zeros(n, d);
for j = 1:d,
    xdata(:, j) = coord{j}(:);
end

% base dataframe
df = stk_dataframe(xdata, varargin{:});

% "factorial design" object
x = struct('coord', {coord});
x = class(x, 'stk_factorialdesign', df);

end % function stk_factorialdesign
