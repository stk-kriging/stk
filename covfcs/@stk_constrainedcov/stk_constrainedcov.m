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

function cov = stk_constrainedcov(cov0, clist)

% default/check arg #1
if nargin < 1,
    cov0 = stk_nullcov();
else
    if ~isa(cov0, 'stk_cov')
        errmsg = 'cov0 must be an object of class stk_cov.';
        stk_error(errmsg, 'IncorrectArgument');
    end
end

% default/check arg #2
p = length(cov0.cparam);
if nargin < 2,
    if p == 0,
        clist = {};
    else
        clist = num2cell(1:p);
    end
else % clist has been provided
    if p == 0,
        err = ~isequal(clist, {});
    else
        err = ~iscell(clist) || ~isequal(sort([clist{:}]), 1:p);
    end
    if err
        errmsg = 'clist does have the expected format.';
        stk_error(errmsg, 'IncorrectArgument');
    end
end

% indices of free parameters
nb_groups = length(clist);
idx_free = zeros(1, nb_groups);
for j = 1:nb_groups,
    idx_free(j) = clist{j}(1);
end

% enforce equality constraints
for j = 1:nb_groups,
    L = length(clist{j}); 
    if L > 1,
        for k = 2:L,
            cov0.cparam(clist{j}(k)) = cov0.cparam(clist{j}(1));
        end
    end
end

% create the underlying structure
cov = struct('param', struct(...
    'base_cov', {cov0},     ...   % first param = unconstrained covariance
    'idx_free', {idx_free}, ...   % second param = indices of free parameters
    'clist',    {clist}     ));   % third param = list of equality constraints

% turn the structure into an object of class stk_constrainedcov
cov = class(cov, 'stk_constrainedcov', stk_cov());
cov = set(cov, 'name', 'stk_constrainedcov');

end % function stk_constrainedcov
