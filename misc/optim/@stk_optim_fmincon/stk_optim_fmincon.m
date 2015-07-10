% STK_OPTIM_FMINCON constructs an object of class 'stk_optim_fmincon'.
%
% CALL: X = stk_optim_fmincon ()
%
%   constructs an object of class 'stk_optim_fmincon' with a default set of
%   options.
%
% CALL: X = stk_optim_fmincon (opt)
%
%   constructs an object of class 'stk_optim_fmincon' with a user-defined
%   set of options, defined by the structure opt.

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2014 SUPELEC & A. Ravisankar
%
%    Authors:  Julien Bect        <julien.bect@centralesupelec.fr>
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

function x = stk_optim_fmincon (options)

if nargin > 1
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

persistent has_fmincon
if isempty (has_fmincon)
    has_fmincon = check_has_fmincon ();
    mlock ();
end

if ~ has_fmincon
    errmsg = 'fmincon () doesn''t seem to be available';
    stk_error (errmsg, 'fminconNotAvailable');
end

if nargin == 0,
    
    options = optimset (            ...
        'Display',      'off',  ...
        'GradObj',      'on',   ...
        'MaxFunEvals',  500,    ...
        'TolFun',       1e-5,   ...
        'TolX',         1e-6    );
    
    try
        % try to use the interior-point algorithm, which has been
        % found to provide satisfactory results in many cases
        options = optimset (options, 'algorithm', 'interior-point');
    catch
        % the 'algorithm' option does not exist in some old versions of
        % matlab (e.g., version 3.1.1 provided with r2007a)...
        err = lasterror ();
        if ~ strcmpi (err.identifier, 'matlab:optimset:invalidparamname')
            rethrow (err);
        end
    end
    
    % TODO: see if the 'UseParallel' option can be useful
    
end

x = struct ('options', options);
x = class (x, 'stk_optim_fmincon');

end % function stk_optim_fmincon


function has_fmincon = check_has_fmincon ()

try
    opt = optimset ('Display', 'off', 'GradObj', 'on');
    z = fmincon (@objfun, 0, [], [], [], [], -1, 1, [], opt);
    assert (abs (z - 0.3) < 1e-2);
    has_fmincon = true;
catch %#ok<CTCH>
    has_fmincon = false;
end

end % function check_has_fmincon


function [f, df] = objfun (x)

f = (x - 0.3) .^ 2;
df = 2 * (x - 0.3);

end % function objfun
