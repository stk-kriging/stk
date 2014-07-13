% STK_CONFIG_MAKEINFO returns make information for STK's MEX-files

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function info = stk_config_makeinfo ()

relpath = fullfile ('misc', 'dist', 'private');
info = register_mex ([],   relpath, 'stk_dist_matrixx');
info = register_mex (info, relpath, 'stk_dist_matrixy');
info = register_mex (info, relpath, 'stk_dist_pairwise');
info = register_mex (info, relpath, 'stk_filldist_discr_mex');
info = register_mex (info, relpath, 'stk_mindist_mex');
info = register_mex (info, relpath, 'stk_gpquadform_matrixy');
info = register_mex (info, relpath, 'stk_gpquadform_matrixx');
info = register_mex (info, relpath, 'stk_gpquadform_pairwise');

relpath = fullfile ('arrays', '@stk_dataframe', 'private');
info = register_mex (info, relpath, 'get_column_number');

relpath = 'sampling';
info = register_mex (info, relpath, 'stk_sampling_vdc_rr2', {'primes.h'});

relpath = fullfile ('arrays', 'generic', 'private');
info = register_mex (info, relpath, 'stk_paretofind_mex', {'pareto.h'});
info = register_mex (info, relpath, 'stk_isdominated_mex', {'pareto.h'});

end % function stk_config_makeinfo


function info = register_mex (info, relpath, mexname, includes)

if nargin < 4,
    includes = {};
end

k = 1 + length (info);

info(k).relpath = relpath;
info(k).mexname = mexname;
info(k).includes = [{'stk_mex.h'} includes];

end % function register_mex

