% STK_OPTIONS_SET sets the value of one or all STK options.

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function opts = stk_options_set(varargin)

persistent options

if isempty(options)    
    options = init_options();    
end

switch nargin
    
    case 0, % nothing to do, just return the output
        
    case 2,
        options.(varargin{1}) = varargin{2};

    case 3,
        options.(varargin{1}).(varargin{2}) = varargin{3};
        
    otherwise
        stk_error('Incorrect number of input arguments.', 'SyntaxError');
        
end

opts = options;

end % function stk_options_set


function opts = init_options()

opts = struct();

opts.stk_sf_matern.min_size_for_parallelization = 1e5;
opts.stk_sf_matern.min_block_size = 1e3;

opts.stk_dataframe.disp_format = 'basic'; % 'basic' or 'verbose'
opts.stk_dataframe.disp_spstr = '    ';

end % function init_options
