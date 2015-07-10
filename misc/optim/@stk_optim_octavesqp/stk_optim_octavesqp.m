% STK_OPTIM_OCTAVESQP constructs an object of class 'stk_optim_octavesqp'.
%
% CALL: X = stk_optim_octavesqp ()
%
%   constructs an object of class 'stk_optim_octavesqp' with a default set of
%   options.
%
% CALL: X = stk_optim_octavesqp (opt)
%
%   constructs an object of class 'stk_optim_octavesqp' with a user-defined
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

function x = stk_optim_octavesqp (opt)

if nargin > 1
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if ~ isoctave
    errmsg = 'Function sqp is only available in Octave';
    stk_error (errmsg, 'sqpNotAvailable');
end

if nargin == 0
    opt = struct ('maxiter', 500, 'tol', 1e-5);
end

x = struct ('options', opt);
x = class (x, 'stk_optim_octavesqp');

end % function stk_optim_octavesqp
