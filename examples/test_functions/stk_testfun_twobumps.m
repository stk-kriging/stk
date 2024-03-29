% STK_TESTFUN_TWOBUMPS computes the TwoBumps response function
%
% CALL: Z = stk_testfun_twobumps (X)
%
%    computes the response Z of the TwoBumps function at X.
%
%    The TwoBumps function is defined as:
%
%       TwoBumps(x) = - (0.7x + sin(5x + 1) + 0.1 sin(10x))
%
%    for x in [-1.0; 1.0].

% Authors
%
%    Julien Bect       <julien.bect@centralesupelec.fr>
%    Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

% Copying Permission Statement  (this file)
%
%    To the extent possible under law, CentraleSupelec has waived all
%    copyright and related or neighboring rights to
%    stk_testfun_twobumps.m.  This work is published from France.
%
%    License: CC0  <http://creativecommons.org/publicdomain/zero/1.0/>

% Copying Permission Statement  (STK toolbox as a whole)
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function z = stk_testfun_twobumps (x)

x = double (x);

z = -(0.7 * x + (sin (5 * x + 1)) + 0.1 * (sin (10 * x)));

end % function
