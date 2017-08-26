% AXIS [overload base function]

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
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

function varargout = axis (varargin)

[h_axes, varargin, nargin] = stk_plot_getaxesarg (varargin{:});

varargout = cell (1, nargout);
labels = {};

for i = 1:nargin
    a = varargin{i};
    if isa (a, 'stk_hrect')
        df = a.stk_dataframe;
        
        % Check number of columns
        d = size (df, 2);
        if (d < 2) || (d > 4)
            stk_error ('axis support 2, 3 or 4 columns only.', 'IncorrectSize');
        end
        
        % Convert to vector: [XMIN XMAX YMIN YMAX ...]
        varargin{i} = reshape (double (df), 1, 2 * d);
        
        % Get labels
        tmp = get (df, 'colnames');
        if ~ isempty (tmp)
            labels = tmp(1:(min (3, d)));
        end
    end
end

[varargout{:}] = axis (h_axes, varargin{:});

% Add labels if available
if (~ isempty (labels))
    stk_xlabel (h_axes, labels{1}, 'interpreter', 'none');  % CG#10
    stk_ylabel (h_axes, labels{2}, 'interpreter', 'none');  % CG#10
    if (length (labels) > 2)
        stk_zlabel (h_axes, labels{3}, 'interpreter', 'none');  % CG#10
    end
end

end % function
