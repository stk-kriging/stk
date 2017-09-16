% STK_HRECT creates an hyper-rectangle object
%
% CALL: B = stk_hrect (D)
% CALL: B = stk_hrect (D, COLNAMES)
%
%   creates an object representing a D-dimensional unit hypercube, [0; 1] ^ D.
%
%   The second (optional) argument can be used to provide variable names.
%
% CALL: B = stk_hrect (X)
% CALL: B = stk_hrect (X, COLNAMES)
%
%   creates an object representing a D-dimensional hyperrectangle with lower
%   bounds X(1, :) and upper bounds X(2, :). The input X must be a 2xD
%   numerical array.
%
% NOTE: class hierarchy
%
%   An stk_hrect object is two-row stk_dataframe object, with row names
%   'lower_bounds' and 'upper_bounds'.
%
% See also: stk_dataframe, stk_boundingbox

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

function s = stk_hrect (arg1, colnames)

if nargin > 2
    
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
    
elseif nargin == 0  % Default constructor
    
    df = stk_dataframe ();
    s = class (struct (), 'stk_hrect', df);
    return
    
elseif isa (arg1, 'stk_hrect')  % arg1 is already an stk_hrect object: copy
    
    s = arg1;
    
else  % create a new stk_hrect object
    
    % NOTE: the following test uses (prod (size (arg1)) == 1) instead of
    % isscalar because isscalar (x) means (numel (x) == 1) in Octave 3.8.2
    % and therefore always returns true for stk_dataframe objects.
    
    if (prod (size (arg1)) == 1)  % arg1 is the dimension of the input space
        % => create a default hyper-rectangle [0; 1]^d, with d = arg1
        
        d = arg1;
        box_data = repmat ([0; 1], 1, d);
        box_colnames = {};
        
    else
        
        if isa (arg1, 'stk_dataframe')
            box_colnames = get (arg1, 'colnames');
        else
            box_colnames = {};
        end
        
        box_data = double (arg1);
        d = size (box_data, 2);
        
        if (~ isequal (size (box_data), [2 d]))
            stk_error ('Invalid size: should be 2 x dim.', 'IncorrectSize');
        end
    end
    
    if (~ all (box_data(1, :) <= box_data(2, :)))
        stk_error ('Invalid bounds', 'InvalidBounds');
    end
    
    df = stk_dataframe (box_data, ...
        box_colnames, {'lower_bounds', 'upper_bounds'});
    s = class (struct (), 'stk_hrect', df);
    
end

% column names
if nargin > 1
    s.stk_dataframe = set (s.stk_dataframe, 'colnames', colnames);
end

end % function

%#ok<*PSIZE>


%!test stk_test_class ('stk_hrect')

%!shared dom
%!test dom = stk_hrect ([-1; 1], {'x'});
%!assert (isequal (dom.colnames, {'x'}))
%!assert (isequal (dom.rownames, {'lower_bounds'; 'upper_bounds'}))
%!assert (isequal (dom.data, [-1; 1]))
