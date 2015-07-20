% STK_CONFIG_GETROOT returns STK's root folder

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@centralesupelec.fr>

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

function [root, found_in_path] = stk_config_getroot ()

root = fileparts (which ('stk_param_relik'));

if isempty (root),
    
    % STK is not in the search path -> Return the path to the copy of STK
    % that contains this specific version stk_config_getroot
    
    root = fileparts (fileparts (mfilename ('fullpath')));
    
    found_in_path = false;
    
else
    
    % STK is already in the search path -> Deduce the path of STK's root
    % from the full path of stk_param_relik.
    
    root = fileparts (root);  % One level upper in the hierarchy
    
    found_in_path = true;
    
end

end % function stk_config_getroot
