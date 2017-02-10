% STK_OPTIM_ISAVAILABLE checks if a given optimizer is available
%
% CALL: B = stk_optim_isavailable (ALGO)
%
%    return true is ALGO is available, and false otherwise.  ALGO can be the
%    short name of an algorithm (such as 'octavesqp'), the corresponding class
%    name (such as 'stk_optim_octavesqp'), a handle on the class constructor
%    (such as @stk_optim_octavesqp) or an algorithm object.

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function b = stk_optim_isavailable (algo, varargin)

switch algo

    case 'fmincon'
        A = stk_optim_fmincon (varargin{:});
        
    case 'fminsearch'
        A = stk_optim_fminsearch (varargin{:});
        
    case 'octavesqp'
        A = stk_optim_octavesqp (varargin{:});
        
    otherwise
        try
            A = feval (algo, varargin{:});
        catch
            stk_error ('Invalid input argument', 'InvalidArgument');
        end
end

b = stk_optim_isavailable (A);

end % function
