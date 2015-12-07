% STK_TEST_DFBINARYOP ...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function stk_test_dfbinaryop (F, a1, a2)

try

    x1  = stk_dataframe (a1);
    x2  = stk_dataframe (a2);
    res = feval (F, a1, a2);

    x3 = feval (F, x1, x2);
    assert (isa (x3, 'stk_dataframe') && isequal (double (x3), res));

    x3 = feval (F, x1, a2);
    assert (isa (x3, 'stk_dataframe') && isequal (double (x3), res));

    x3 = feval (F, a1, a2);
    assert (isequal (x3, res));

catch

    err = lasterror ();

    if strcmp (err.message, ['octave_base_value::array_value(): ' ...
                             'wrong type argument `class'''])

        warning (msg.message);

    else
    
        rethrow (err);

    end

end % try

end % function
