% STK_UPDATE [STK internal]

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Authors:  Julien Bect  <julien.bect@supelec.fr>

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
Pi  = LS(1:kreq.n, (kreq.n + 1):end);

LS = [[Kii Kji' Pi]; [Kji Kjj Pj]; [Pi' Pj' zeros(kreq.r)]];
[kreq.LS_Q, kreq.LS_R] = qr (LS);

if ~ isempty (kreq.RS)
    Kti = kreq.RS(1:kreq.n, :)';
    Pt  = kreq.RS((kreq.n + 1):end, :)';
    kreq = stk_set_righthandside (kreq, [Kti Ktj], Pt);
elseif nargin > 4
    stk_error ('Too many input arguments: no RS to update', 'TooManyInputArgs');
end

kreq.n = kreq.n + size (Kjj, 1);

end % function stk_update


%!shared model x y
%! model = stk_model ('stk_materncov32_iso', 1);
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
