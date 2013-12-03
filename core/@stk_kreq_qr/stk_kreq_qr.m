% STK_KREQ_QR [STK internal]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function kreq = stk_kreq_qr (model, xi, xt)

[Kii, Pi] = stk_make_matcov (model, xi);
[n, r] = size (Pi);

% kriging matrix (left-hand side of the kriging equation)
LS = [[Kii, Pi]; [Pi', zeros(r)]];

% orthogonal-triangular decomposition
[Q, R] = qr (LS);

kreq = struct ('n', n, 'r', r, ...
    'LS_Q', Q, 'LS_R', R, 'RS', [], 'lambda_mu', []);
kreq = class (kreq, 'stk_kreq_qr');

% prepare the right-hand side of the kriging equation
if nargin > 2,
    [Kti, Pt] = stk_make_matcov (model, xt, xi);
    kreq = stk_set_righthandside (kreq, Kti, Pt);
end

end % function stk_kreq_qr
