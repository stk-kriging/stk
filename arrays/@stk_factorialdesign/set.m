% SET [overload base function]

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
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

function x = set (x, propname, value)

df = x.stk_dataframe;

switch propname,
    
    case 'levels',
        % We proceed in two steps, instead of the seemingly simpler
        %    x = stk_factorialdesign (value);
        % to preserve the value of the other fields (info, colnames, ...).
        tmp = stk_factorialdesign (value);
        x = set_data (df, tmp.data);
        
    case 'stk_dataframe',
        errmsg = 'Field .stk_dataframe is read-only.';
        stk_error (errmsg, 'ReadOnlyField');
        
    case {'colnames', 'rownames', 'info'},
        x.stk_dataframe = set (df, propname, value);
        
    otherwise,
        if ismember (propname, fieldnames (df))
            % The result is not an stk_factorialdesign object anymore, in
            % general. An implicit cast to stk_dataframe is thus performed.
            x = set (df, propname, value);
        else
            errmsg = sprintf ('There is no field named: %s.', propname);
            stk_error (errmsg, 'UnknownField');
        end
        
end

end % function
