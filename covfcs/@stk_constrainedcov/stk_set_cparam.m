% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%
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

function cov = stk_set_cparam(cov, value)

% check arg #2
nb_groups = length(cov.param.idx_free);
if ~isa(value, 'double') || (length(value) ~= nb_groups)
    stk_error('Incorrect ''value'' argument.', 'IncorrectArgument');
end

% build a "full" cparam vector
clist = cov.param.clist;
t = zeros(1, length([clist{:}]));
for j = 1:nb_groups
    t(clist{j}) = value(j);
end

% set the "full" cparam vector
cov.param.base_cov = stk_set_cparam(cov.param.base_cov, t);

end