% VERTCAT [overloaded base function]

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

function z = vertcat(x, y, varargin)

if isa(x, 'stk_dataframe')
    
    % In this case, [x; y] will be an stk_dataframe also.
    
    data = [x.data; double(y)];
    
    if isa(y, 'stk_dataframe')
        
        if ~all(strcmp(x.vnames, y.vnames))
            errmsg = 'Cannot concatenate because of incompatible column names.';
            stk_error(errmsg, 'IncompatibleColNames');
        else
            colnames = x.vnames;
        end
        
        bx = isempty(x.rownames);
        by = isempty(y.rownames);
        if bx && by
            rownames = {};
        elseif ~bx && ~by
            rownames = [x.rownames; y.rownames];
        else
            warning(sprintf(['One of the dataframes has no row names.\n' ...
                '  => Ignoring row names from the other one.'])); %#ok<WNTAG,SPWRN>
            rownames = {};
        end
        
    else % y is a matrix
        
        colnames = x.vnames;
        
        if ~isempty(x.rownames)
            warning(sprintf(['One of the dataframes has no row names.\n' ...
                '  => Ignoring row names from the other one.'])); %#ok<WNTAG,SPWRN>
        end
        rownames = {};
        
    end % if
    
    z = stk_dataframe(data, colnames, rownames);
    
else  % In this case, z will be a matrix.
    
    z = [double(x); double(y)];
    
end

if ~isempty(varargin),
    z = vertcat(z, varargin{:});
end

end % function subsref


%!shared u v
%! u = rand(3, 2);
%! v = rand(3, 2);

%%
% Vertical concatenation of two dataframes

%!test
%! x = stk_dataframe(u);
%! y = stk_dataframe(v);
%! z = [x; y];
%! assert (isa(z, 'stk_dataframe') && isequal(double(z), [u; v]));

%!test % the same, with row names this time
%! x = stk_dataframe(u, {}, {'a'; 'b'; 'c'});
%! y = stk_dataframe(v, {}, {'d'; 'e'; 'f'});
%! z = [x; y];
%! assert (isa(z, 'stk_dataframe') && isequal(double(z), [u; v]));
%! assert (all(strcmp(z.rownames, {'a'; 'b'; 'c'; 'd'; 'e'; 'f'})));

%!test % the same, with row names only for the first argument
%! x = stk_dataframe(u, {}, {'a'; 'b'; 'c'});
%! y = stk_dataframe(v);
%! z = [x; y];
%! assert (isa(z, 'stk_dataframe') && isequal(double(z), [u; v]));

%!error % incompatible variable names
%! u = rand(3, 1);  x = stk_dataframe(u, {'x'});
%! v = rand(3, 1);  y = stk_dataframe(v, {'y'});
%! z = [x; y];

%%
% Vertical concatenation [dataframe; matrix]

%!test
%! x = stk_dataframe(u);
%! z = [x; v];
%! assert (isa(z, 'stk_dataframe') && isequal(double(z), [u; v]));

%!test % the same, with row names for the first argument
%! x = stk_dataframe(u, {}, {'a'; 'b'; 'c'});
%! z = [x; v];
%! assert (isa(z, 'stk_dataframe') && isequal(double(z), [u; v]));

%%
% Vertical concatenation [matrix; dataframe]

%!test
%! y = stk_dataframe(v);
%! z = [u; y];
%! assert(isa(z, 'double') && (isequal(z, [u; v])));

%%
% Vertical concatenation of more than two elements

%!test
%! x = stk_dataframe(u);
%! y = stk_dataframe(v);
%! z = [x; y; u; v];
%! assert(isa(z, 'stk_dataframe') && isequal(double(z), [u; v; u; v]));
