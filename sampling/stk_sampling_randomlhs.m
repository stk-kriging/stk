% STK_SAMPLING_RANDOMLHS builds a random LHS design
%
% CALL: x = stk_sampling_randomlhs(n, d, box)
%
% FIXME: documentation incomplete

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%          =================================================
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version:   1.0
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%
function x = stk_sampling_randomlhs(n, d, box)

niter = 1;

x = stk_sampling_maximinlhs(n, d, box, niter);
