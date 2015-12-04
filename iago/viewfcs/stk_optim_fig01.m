% STK_OPTIM_FIG01 ...

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Authors:  Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%              Julien Bect       <julien.bect@supelec.fr>

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

function stk_optim_fig01 (algo, xi, zi, xi_new)

xt0 = algo.disp_xvals;
zt0 = algo.disp_zvals;

zp = stk_predict_withrep (algo.model, xi, zi, algo.xg0);

figure (algo.disp_fignum_base + 1);

plot_1 (xi, zi, algo.xg0, zp, xt0, zt0);  hold on;
plot (xi_new * [1 1], ylim, '--', 'Color', 0.2 * [1 1 1]);  hold off;

stk_labels ('x', 'f(x)');
stk_title ('Evaluations and kriging prediction');

drawnow;

end % function
