% NOISE_PARAMS_CONSISTENCY [internal]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function b = noise_params_consistency (algo, xi)

b = false;  % If any condition is violated, we just have to return

n = stk_length (xi);  % Current number of evaluations

heterosc = isa (algo.xg0, 'stk_ndf');

% Check the size and type of algo.model.lognoisevariance
lnv = algo.model.lognoisevariance;
b1 = isnumeric (lnv);
b2 = heterosc && (isequal (size (lnv), [n 1]));
b3 = (~ heterosc) && (isscalar (lnv));
if ~ (b1 && (xor (b2, b3))), return; end

% Check the size and value of algo.noisevariance
nv = algo.noisevariance;
b1 = (~ heterosc) && (isscalar (nv)) && (isnan (nv));
b2 = (~ heterosc) && (isscalar (nv)) && (~ isnan (nv)) ...
    && (stk_isequal_tolrel (nv, exp (lnv), 1e-12));
if ~ (xor (heterosc, xor (b1, b2))), return; end

b = true;

end % function
