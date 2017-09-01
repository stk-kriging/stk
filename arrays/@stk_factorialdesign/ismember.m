% ISMEMBER [overload base function]

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

function varargout = ismember (A, B, varargin)

if ~ all (cellfun (@ischar, varargin))
    stk_error ('Invalid flag (should be a string).', 'InvalidArgument');
end

if isa (A, 'stk_factorialdesign')

    varargout = cell (1, max (nargout, 1));
    [varargout{:}] = ismember (double (A), B, varargin{:});
    
else  % B is an stk_factorialdesign object
    
    has_rows = false;
    has_legacy = false;
    
    for k = 1:(numel (varargin))
        switch varargin{k}
            case 'rows'
                has_rows = true;
            case 'legacy'
                has_legacy = true;
            otherwise
                errmsg = sprintf ('Unknown flag: %s', varargin{k});
                stk_error (errmsg, 'InvalidArgument');
        end
    end
    
    if has_rows && ~ has_legacy && (nargout < 2)  % This case can be optimized
        
        lia = ismember_fd (A, B);
        varargout = {lia};
        
    else  % otherwise, use the base ismember function
        
        varargout = cell (1, max (nargout, 1));
        [varargout{:}] = ismember (A, double (B), varargin{:});
        
    end
    
end

end % function


function [lia, locb] = ismember_fd (A, B)

[n, dim] = size (A);
if dim ~= length (B.levels)
    stk_error (['A and B should have the same number ' ...
        'of columns'], 'InvalidArgument');
end

b = false (n, dim);
for j = 1:dim
    b(:, j) = ismember (A(:, j), B.levels{j});
end

lia = all (b, 2);

end % function


%!shared A, B, BB, b
%!
%! i_max = 10;  n = 100;  d = 5;
%!
%! A = randi (i_max, n, d);
%!
%! levels = repmat ({1:i_max}, 1, d);
%! levels{4} = 1:2:i_max;
%! B = stk_factorialdesign (levels);
%!
%! BB = double (B);

%!test b = ismember (A, B);
%!assert (isequal (b, ismember (A, BB)));

%!test b = ismember (A, B, 'rows');
%!assert (isequal (b, ismember (A, BB, 'rows')));
