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

function cov = stk_constrainedcov(basecov, clist)

% default/check arg #1
if nargin < 1,
    basecov = stk_nullcov();
else
    if ~isa(basecov, 'stk_cov')
        errmsg = 'basecov must be an object of class stk_cov.';
        stk_error(errmsg, 'IncorrectArgument');
    end
end

% default/check arg #2
p = length(basecov.cparam);
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

% create the underlying structure
cov = struct('prop', struct(), 'aux', []);
cov.prop = struct('basecov', basecov, 'clist', []);
cov.aux = struct('idxfree', []);
    
% turn the structure into an object of class stk_constrainedcov
cov = class(cov, 'stk_constrainedcov', stk_cov());

% populate some fields
cov = set(cov, 'name', 'stk_constrainedcov');
cov = set(cov, 'clist', clist);

end % function stk_constrainedcov
