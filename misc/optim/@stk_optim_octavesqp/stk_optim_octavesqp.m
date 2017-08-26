% STK_OPTIM_OCTAVESQP constructs an object of class 'stk_optim_octavesqp'.
%
% CALL: ALGO = stk_optim_octavesqp ()
%
%   constructs an algorithm object ALGO of class 'stk_optim_octavesqp'
%   with a default set of options.
%
% CALL: ALGO = stk_optim_octavesqp (opt)
%
%   constructs an algorithm object ALGO of class 'stk_optim_octavesqp'
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

function algo = stk_optim_octavesqp (user_options)

if nargin > 1
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Default options
options.maxiter = 500;     % Octave's default is 100
options.tol = sqrt (eps);  % This is Octave's default
options.qp_solver = [];    % We provide a default choice below, if needed

% Process user options
if nargin > 0
    fn = fieldnames (user_options);
    for i = 1:(numel (fn))
        switch lower (fn{i})
            case 'maxiter'
                options.maxiter = user_options.maxiter;
            case 'tol'
                options.tol = user_options.tol;
            case 'qp_solver'
                options.qp_solver = user_options.qp_solver;
            otherwise
                stk_error (sprintf ('Unknown option: %s.\n',fn{i}), ...
                    'InvalidArgument');
        end
    end
end

% Provide default QP solver if needed
if isempty (options.qp_solver)
    if exist ('OCTAVE_VERSION', 'builtin') == 5  % Octave
        % Octave's core qp function
        options.qp_solver = 'qp';
    else
        % quadprog from Mathworks' Optimization toolbox or from MOSEK
        options.qp_solver = 'quadprog';
    end
end

% Choose the appropriate optimizer, depending on the value of qp_solver
switch options.qp_solver
    case 'qp'
        optimizer = 'sqp';
    case 'quadprog'
        optimizer = 'sqp_quadprog';
    otherwise
        stk_error (sprintf (['Incorrect value for option qp_solver %s.\n\n' ...
            'qp_solver must be either ''qp'' or ''quadprog''.\n'], ...
            options.qp_solver), 'InvalidArgument');
end

% Note: do NOT rewrite to use handles instead of strings for optimizer
%    (see bug report https://savannah.gnu.org/bugs/index.php?47828)

base = stk_optim_baseclass (true, true);
algo = struct ('options', options, 'sqp', optimizer);
algo = class (algo, 'stk_optim_octavesqp', base);

end % function


%!test stk_test_class ('stk_optim_octavesqp')
