% STK_MODEL_ [internal]
%
% This is meant to become the base class for all STK models.
%
% Currently:
%    * prior models  are defined by model structures (structs) and thus
%      do not derive from this class;
%    * the stk_model_gpposterior and stk_model_gn classes already derive
%      from this class.

% Copyright Notice
%
%    Copyright (C) 2018, 2019 CentraleSupelec
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

function gn = stk_model_ ()

gn = class (struct (), 'stk_model_');

end % function
