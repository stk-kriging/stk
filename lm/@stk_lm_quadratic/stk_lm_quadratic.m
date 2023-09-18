% STK_LM_QUADRATIC creates a quadratic linear model object
%
% CALL: LM = STK_LM_QUADRATIC ()
%
%    creates a quadratic linear model object LM.

% Copyright Notice
%
%    Copyright (C) 2017, 2018, 2021 CentraleSupelec
%    Copyright (C) 2012-2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
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

function lm = stk_lm_quadratic ()

lm = class (struct (), 'stk_lm_quadratic', stk_lm_ ());

end % function


%!test stk_test_class ('stk_lm_quadratic')
