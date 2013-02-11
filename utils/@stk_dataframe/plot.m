% PLOT [FIXME: missing doc...]

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

function plot(x, z, varargin)

stk_narginchk(2, inf);

if isa(x, 'stk_dataframe')
    xx = double(x);
    xvarnames = x.vnames;
else
    xx = x;
    xvarnames = {'x'};
end

if size(xx, 2) > 1,
    stk_error('Incorrect size for argument x.', 'IncorrectSize');
end

if isa(z, 'stk_dataframe')
    zz = double(z);
    zvarnames = z.vnames;
else
    zz = z;
    nb_responses = size(z, 2);
    zvarnames = cell(1, nb_responses);
    for j = 1:nb_responses,
        zvarnames{j} = sprintf('z%d', j);
    end
end

plot(xx, zz, varargin{:});

xlabel(xvarnames{1}, 'FontWeight', 'bold');
ylabel(zvarnames{1}, 'FontWeight', 'bold');

end % function plot
