% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
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

function cov = set (cov, propname, value)

switch propname
    
    case 'cparam'
        cov = set_cparam_ (cov, value);
        
    case 'base_cov'
        errmsg = 'Property basecov is read-only.';
        stk_error (errmsg, 'SettingReadOnlyProperty');
        
    case 'clist'
        cov = set_clist_ (cov, value);
        
    otherwise % name
        cov.stk_cov = set (cov.stk_cov, propname, value);
        
end

end % function set


function cov = set_cparam_ (cov, value)

% check arg #2
nb_groups = length (cov.aux.idxfree);
if ~ isa (value, 'double') || (length (value) ~= nb_groups)
    stk_error ('Incorrect ''value'' argument.', 'IncorrectArgument');
end

% build a "full" cparam vector
clist = cov.prop.clist;
t = zeros (length ([clist{:}]), 1);
for j = 1:nb_groups
    t (clist{j}) = value(j);
end

% set the "full" cparam vector
cov.prop.basecov = set (cov.prop.basecov, 'cparam', t);

end % function set_cparam_


function cov = set_clist_ (cov, clist)

basecov = cov.prop.basecov;

% indices of free parameters
nbgroups = length (clist);
idxfree = zeros (1, nbgroups);
for j = 1:nbgroups,
    idxfree (j) = clist{j}(1);
end

% enforce equality constraints in basecov
for j = 1:nbgroups,
    L = length (clist{j}); 
    if L > 1,
        for k = 2:L,
            basecov.cparam(clist{j}(k)) = basecov.cparam(clist{j}(1));
        end
    end
end

% update the structure
cov.prop.basecov = basecov;
cov.prop.clist   = clist;
cov.aux.idxfree  = idxfree;

end % function set_clist_
