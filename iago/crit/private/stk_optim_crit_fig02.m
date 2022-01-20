% STK_OPTIM_CRIT_FIG02 ...

% Copyright Notice
%
%    Copyright (C) 2015, 2020 CentraleSupelec
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

function stk_optim_crit_fig02 (algo, x, p)

figure (algo.disp_fignum_base + algo.disp_fignum_critshift + 2);

% x-axis: actual x-values in 1D, indices otherwise
if algo.dim == 1
    x = double (x);
    xlab = 'x';
else
    x = (1:(stk_get_sample_size (x)))';
    xlab = 'index';
end

stem (x, p);

stk_labels (xlab, 'probability');
stk_title ('Distribution of the maximizer');

drawnow;

end % function
