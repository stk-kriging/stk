% STK_OPTIM_HASFMINCON returns true if fmincon is available
%
% CALL: fmincon_available = stk_optim_hasfmincon ()

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

persistent b;

if isempty (b),
    
    try
        opt = optimset ('Display', 'off', 'GradObj', 'on');
        z = fmincon (@objfun, 0, [], [], [], [], -1, 1, [], opt);
        assert (abs (z - 0.3) < 1e-2);
        b = true;
    catch %#ok<CTCH>
        b = false;
    end
    
    mlock ();
    
end

fmincon_available = b;

end % function stk_optim_hasfmincon


function [f, df] = objfun (x)

f = (x - 0.3) .^ 2;
df = 2 * (x - 0.3);

end % function objfun
