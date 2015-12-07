% STK_UPDATE  [STK internal]
%
% CALL: kreq = stk_update (kreq, Kjj, Kji, Pj, Ktj)
%
%    Experimental...

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
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

function kreq = stk_update (kreq, Kjj, Kji, Pj, Ktj)

% Poor man's update...
% TODO: implement efficient update equations (use qrinsert)

LS  = kreq.LS_Q * kreq.LS_R;
Kii = LS(1:kreq.n, 1:kreq.n);
Pi  = bsxfun (@rdivide, LS(1:kreq.n, (kreq.n + 1):end), kreq.P_scaling);

Kii = [[Kii Kji']; [Kji Kjj]];
Pi  = [Pi; Pj];

old_scaling = kreq.P_scaling;
kreq.P_scaling = compute_P_scaling (Kii, Pi);
Pi = bsxfun (@times, Pi, kreq.P_scaling);

LS = [[Kii Pi]; [Pi' zeros(kreq.r)]];
[kreq.LS_Q, kreq.LS_R] = qr (LS);

if ~ isempty (kreq.RS)
    Kti = kreq.RS(1:kreq.n, :)';
    Pt  = bsxfun (@rdivide, kreq.RS((kreq.n + 1):end, :)', old_scaling);
    kreq = stk_set_righthandside (kreq, [Kti Ktj], Pt);
elseif nargin > 4
    stk_error ('Too many input arguments: no RS to update', 'TooManyInputArgs');
end

kreq.n = kreq.n + size (Kjj, 1);

end % function


%!shared model, x, y
%! model = stk_model ('stk_materncov32_iso', 1);
%! model.param = log ([1.0; 2.8]);
%! x = [1.2; 0.3; -1.9];
%! y = 0.0;

%!test
%! kreqA = stk_kreq_qr (model, x);
%! [Kii, Pi] = stk_make_matcov (model, x);
%! kreqB = stk_kreq_qr (model, x(1));
%! kreqB = stk_update (kreqB, Kii(2, 2), Kii(2, 1), Pi(2));
%! kreqB = stk_update (kreqB, Kii(3, 3), Kii(3, [1 2]), Pi(3));
%! assert (stk_isequal_tolabs (kreqA, kreqB, 3 * eps))

%!test
%! kreqA = stk_kreq_qr (model, x, y);
%! [Kii, Pi] = stk_make_matcov (model, x);
%! [Kti, Pt] = stk_make_matcov (model, y, x);
%! kreqB = stk_kreq_qr (model, x(1), y);
%! kreqB = stk_update (kreqB, Kii(2, 2), Kii(2, 1), Pi(2), Kti(2));
%! kreqB = stk_update (kreqB, Kii(3, 3), Kii(3, [1 2]), Pi(3), Kti(3));
%! assert (stk_isequal_tolabs (kreqA, kreqB, 3 * eps))
