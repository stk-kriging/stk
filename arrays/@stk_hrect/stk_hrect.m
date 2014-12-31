% STK_HRECT ... [FIXME: Document me !]

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function s = stk_hrect (arg1, colnames)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if isa (arg1, 'stk_hrect')  % arg1 is already an stk_hrect object: copy
    
    s = arg1;
    
else  % create a new stk_hrect object
    
    % NOTE: the following test uses (prod (size (arg1)) == 1) instead of
    % isscalar because isscalar (x) means (numel (x) == 1) in Octave 3.8.2
    % and therefore always returns true for stk_dataframe objects.
    
    if (prod (size (arg1)) == 1)  % arg1 is the dimension of the input space
        % => create a default hyper-rectangle [0; 1]^d, with d = arg1
        d = arg1;
        box_data = repmat ([0; 1], 1, d);
    else
        box_data = double (arg1);
        d = size (box_data, 2);
        if (~ isequal (size (box_data), [2 d]))
            stk_error ('Invalid size: should be 2 x dim.', 'IncorrectSize');
        end
    end
    
    if (~ all (box_data(1, :) <= box_data(2, :)))
        stk_error ('Invalid bounds', 'InvalidBounds');
    end
    
    df = stk_dataframe (box_data, {}, {'lower_bounds', 'upper_bounds'});
    s = class (struct (), 'stk_hrect', df);
    
end

% column names
if nargin > 1,
    s.stk_dataframe.colnames = colnames;
end

end % function stk_hrect
