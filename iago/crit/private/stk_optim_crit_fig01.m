% STK_OPTIM_CRIT_FIG01 ...

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
%               (https://github.com/stk-kriging/stk/)
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

function stk_optim_crit_fig01 (algo, xi, zi, x, z_pred, z_sim)

figure (algo.disp_fignum_base + algo.disp_fignum_critshift + 1);

% Do not display all samplepaths
L = min (size (z_sim, 2), 50);

stk_plot1d (xi, zi, x, [], z_pred, z_sim(:, 1:L));

stk_labels ('x', 'f(x)');
stk_title ('Conditional samplepaths');

drawnow;

end % function
