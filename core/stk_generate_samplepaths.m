% STK_GENERATE_SAMPLEPATHS generates sample paths of a Gaussian process
%
% CALL: zsim = stk_generate_samplepaths(xt, model, nb_paths)
%       xt       = structure that contains the points at which one wants to 
%              generate sample paths 
%       model    = kriging model
%       nb_paths = number of sample paths
%       zsim     = structure that contains unconditioned sample paths
%
% STK_GENERATE_SAMPLEPATHS compute sample values of a Gaussian random vector
% by using a Cholesky factorization (see, e.g., Chiles and Delfiner,
% Geostatistics: Modeling Spatial Uncertainty, 1999) 
%
% EXAMPLE: see STK/examples/example05.m

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.0.2
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging/
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
function zsim = stk_generate_samplepaths(xt, model, nb_paths)

if nargin < 3, nb_paths = 1; end

% covariance matrix
K = stk_make_matcov( xt, model );

% Cholesky factorization, once and for all
V = chol(K);

% generates samplepaths
zsim.a = V' * randn( size(K,1), nb_paths );