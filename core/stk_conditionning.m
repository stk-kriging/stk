% STK_CONDITIONNING conditions sample paths on observations
%
% CALL: zsimc = stk_conditionning(lambda, zi, zsim, xi_ind)
%       lambda = kriging weights, as provided by stk_predict
%       zi     = structure that contains the observed values on which on
%                wants to condition sample paths
%       zsim   = structure that contains unconditioned sample paths
%       xi_ind = indices of the observations in the vector ysim.a
%       zsimc  = conditional sample paths
%
% STK_CONDITIONNING uses the technique called conditionning by kriging
% (see, e.g., Chiles and Delfiner, Geostatistics: Modeling Spatial
%  Uncertainty, 1999) 
%
% EXAMPLE: see STK/examples/example05.m
%      

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version: 1.0
%    Authors: Julien Bect <julien.bect@supelec.fr>
%             Emmanuel Vazquez <emmanuel.vazquez@supelec.fr>
%    URL:     http://sourceforge.net/projects/kriging/
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
function zsimc = stk_conditionning(lambda, zi, zsim, xi_ind)

nsim = size(zsim.a,2);
zsimc.a = zsim.a + lambda'*(repmat(zi.a,1,nsim) - zsim.a(xi_ind,:));

