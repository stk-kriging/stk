% STK_OPTIM_FMINCON constructs an object of class 'stk_optim_fmincon'.
%
% CALL: ALGO = stk_optim_fmincon ()
%
%   constructs an algorithm object ALGO of class 'stk_optim_fmincon'
%   with a default set of options.
%
% CALL: ALGO = stk_optim_fmincon (opt)
%
%   constructs an algorithm object ALGO of class 'stk_optim_fmincon'
%   with a user-defined set of options, defined by the structure opt.

% Copyright Notice
%
%    Copyright (C) 2015-2017 CentraleSupelec
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

function algo = stk_optim_fmincon (varargin)

% Some default options
options = optimset (        ...
    'Display',      'off',  ...
    'GradObj',      'on',   ...
    'MaxFunEvals',  500,    ...
    'TolFun',       1e-5,   ...
    'TolX',         1e-6    );

% The 'algorithm' option is not supported by optimset in Octave
%  (e.g., 4.0.0) and in some old versions of Matlab (e.g., r2007a)
ws = warning ('off', 'all');
try
    % Try to use the interior-point algorithm, which has been
    % found to provide satisfactory results in many cases
    options = optimset (options, 'algorithm', 'interior-point');
end
warning (ws);

% TODO: see if the 'UseParallel' option can be useful

% Take user options into account
if nargin > 0
    options = optimset (options, varargin{:});
end

base = stk_optim_baseclass (true, false);
algo = struct ('options', options);
algo = class (algo, 'stk_optim_fmincon', base);

end % function


%!test stk_test_class ('stk_optim_fmincon')
