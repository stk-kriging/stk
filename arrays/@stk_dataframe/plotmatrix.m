% @STK_DATAFRAME/PLOTMATRIX [overload base function]
%
% See also: plotmatrix

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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

function varargout = plotmatrix (varargin)

% Parse the list of input arguments
[h_axes, x, y, linespec] = parse_args_ (varargin{:});

% Read x argument
if isa (x, 'stk_dataframe')
    x_data = double (x);
    x_colnames = x.colnames;
else
    x_data = x;
    x_colnames = {};
end
nx = size (x_data, 2);

varargout = cell (1, max (nargout, 2));
if isempty (y)
    
    y_colnames = x_colnames;
    ny = nx;
    
    [varargout{:}] = plotmatrix (h_axes, x_data, linespec{:});
    
else
    
    % Read y argument
    if isa (y, 'stk_dataframe')
        y_data = double (y);
        y_colnames = y.colnames;
    else
        y_data = double (y);
        y_colnames = {};
    end
    ny = size (y_data, 2);
    
    [varargout{:}] = plotmatrix (h_axes, x_data, y_data, linespec{:});
    
end

hh = varargout{2};
varargout = varargout(1:nargout);

if ~ isempty (x_colnames)
    for i = 1:nx
        stk_xlabel (hh(ny, i), x_colnames{i}, 'interpreter', 'none');  % CG#10
    end
end

if ~ isempty (y_colnames)
    for j = 1:ny
        stk_ylabel (hh(j, 1), y_colnames{j}, 'interpreter', 'none');  % CG#10
    end
end


end % function


function [h_axes, x, y, linespec] = parse_args_ (varargin)

% Extract axis handle (if it is present)
[h_axes, varargin, n_argin] = stk_plot_getaxesarg (varargin{:});

switch n_argin
    
    case 0
        stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
        
    case 1
        x = varargin{1};
        y = [];
        linespec = {};
        
    case 2
        if ischar (varargin{2})
            x = varargin{1};
            y = [];
            linespec = varargin(2);
        else
            x = varargin{1};
            y = varargin{2};
            linespec = {};
        end
        
    case 3
        x = varargin{1};
        y = varargin{2};
        linespec = varargin(3);
        
    otherwise
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
        
end % switch

end % function
