% LINSOLVE

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function kreq = linsolve(kreq, xt) 

[Kti, Pt] = stk_make_matcov(kreq.model, xt, kreq.xi);

kreq.xt = double(xt);
kreq.RS = [Kti Pt]';

% solve the upper-triangular system to get the extended
% kriging weights vector (weights + Lagrange multipliers)
if stk_is_octave_in_use(),
    % linsolve is missing in Octave
    kreq.lambda_mu = kreq.LS_R \ (kreq.LS_Q' * kreq.RS);
else
    kreq.lambda_mu = linsolve ...
        (kreq.LS_R, kreq.LS_Q' * kreq.RS, struct('UT', true));
end

end % function linsolve