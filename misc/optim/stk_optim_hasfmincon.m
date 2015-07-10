% STK_OPTIM_HASFMINCON is a deprecated function
%
% stk_optim_fmincon is deprecated and will be removed
% from future releases of STK. Use
%
%    try
%       algo = stk_optim_fmincon ();
%       fmincon_available = true;
%    catch
%       fmincon_available = false;
%    end
%
% instead if you want to check whether fmincon is available or not.
%
% See also: stk_optim_fmincon

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
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

function fmincon_available = stk_optim_hasfmincon ()

warning (help ('stk_optim_hasfmincon'));

try
    algo = stk_optim_fmincon ();
    fmincon_available = true;
catch
    fmincon_available = false;
end

end % function stk_optim_hasfmincon
