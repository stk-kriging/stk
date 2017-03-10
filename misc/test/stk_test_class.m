% STK_TEST_CLASS is a unit test that any STK class should pass

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

function stk_test_class (classname, verbose)

if nargin < 2
    verbose = false;
end

test_list = { ...
    'default_constructor_doesnt_crash', ...
    'default_constructor_return_type', ...
    'isequal_argin1', ...
    'isequal_2_self', ...
    'isequal_3_self', ...
    'isequal_2_zero', ...
    'isequal_3_zero' };

for i = 1:(length (test_list))
    fname = ['stk_test_class__' test_list{i}];
    if verbose,  fprintf ('stk_test_class #1: %s... ', fname);  end
    
    try
        feval (fname, classname);
        if verbose,  fprintf ('OK\n');  end
    catch
        if verbose,  fprintf ('FAILED.\n');  end
        rethrow (lasterror ());
    end
end

end % function


function stk_test_class__default_constructor_doesnt_crash (classname)
x = feval (classname);
end

function stk_test_class__default_constructor_return_type (classname)
x = feval (classname);
if ~ strcmp (class (x), classname)
    error (sprintf ('Returned object is not of class %s.', classname));
end
end

function stk_test_class__isequal_argin1 (classname)
x = feval (classname);
try
    b = isequal (x); %#ok<>
    error (sprintf ('isequal (x) does not fail for class %s.', classname));
end
end

function stk_test_class__isequal_2_self (classname)
x = feval (classname);
assert (isequal (x, x));
end

function stk_test_class__isequal_3_self (classname)
x = feval (classname);
assert (isequal (x, x, x));
end

function stk_test_class__isequal_2_zero (classname)
x = feval (classname);
assert (~ isequal (x, 0));
assert (~ isequal (0, x));
end

function stk_test_class__isequal_3_zero (classname)
x = feval (classname);
assert (~ isequal (x, x, 0));
assert (~ isequal (x, 0, x));
assert (~ isequal (0, x, x));
assert (~ isequal (x, 0, 0));
assert (~ isequal (0, x, 0));
assert (~ isequal (0, 0, x));
end


%#ok<*SPERR,*DEFNU,*TRYNC,*NASGU>
