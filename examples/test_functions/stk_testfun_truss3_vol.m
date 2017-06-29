% STK_TESTFUN_TRUSS3_VOL computes the volume of the 'truss3' structure
%
% CALL: V = stk_testfun_truss3_vol (X, CONST)
%
% See also: stk_testcase_truss3, stk_testfun_truss3_bb


% Copyright Notice
%
%    This file: stk_testfun_truss3_vol.m was written in 2017
%                        by Julien Bect <julien.bect@centralesupelec.fr>.
%
%    To the extent possible under law,  the author(s)  have dedicated all
%    copyright and related and neighboring rights to this file to the pub-
%    lic domain worldwide. This file is distributed without any warranty.
%
%    This work is published from France.
%
%    You should have received a copy of the  CC0 Public Domain Dedication
%    along with this file.  If not, see
%                    <http://creativecommons.org/publicdomain/zero/1.0/>.

% Copying Permission Statement (STK toolbox as a whole)
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

function V = stk_testfun_truss3_vol (x, const)

% Convert input to double-precision input data
% (and get rid of extra structure such as table or stk_dataframe objects)
x_ = double (x);

% Extract design variables
a1 = x_(:, 1);
a2 = x_(:, 2);
a3 = x_(:, 3);
w  = x_(:, 4);

% Extract constants
L = const.L;
D = const.D;

% Length of bar 1 and bar 3
L1 = sqrt (L ^ 2 + w .^ 2);
L3 = sqrt (L ^ 2 + (D - w) .^ 2);

% Total volume
V = a1 .* L1 + a2 * L + a3 .* L3;

% df-in/df-out
if isa (x, 'stk_dataframe')
    V = stk_dataframe (V, {'V'}, x.rownames);
end

end % function
