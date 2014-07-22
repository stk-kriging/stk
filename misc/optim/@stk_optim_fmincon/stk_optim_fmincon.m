% STK_OPTIM_FMINCON constructs an object belonging to the class 'stk_optim_fmincon'
% for function minimisation using the matlab function fmincon.

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC & A. Ravisankar
%
%    Authors:  Julien Bect        <julien.bect@supelec.fr>
%              Ashwin Ravisankar  <ashwinr1993@gmail.com>

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

function x = stk_optim_fmincon (opt)

if nargin > 1
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if exist ('fmincon') ~= 2
    errmsg = 'Function fmincon does not exist or not added to path';
    stk_error (errmsg, 'fmincon_does_not_exist');
end

if nargin == 0,
    
    opt = optimset (            ...
        'Display',      'iter', ...
        'Algorithm',    'interior-point', ...
        'GradObj',      'on',   ...
        'MaxFunEvals',  1500,   ...
        'TolFun',       1e-10,  ...
        'UseParallel', 'always');   
end

x = struct ('options', opt);
x = class (x, 'stk_optim_fmincon');

end % function stk_optim_fmincon