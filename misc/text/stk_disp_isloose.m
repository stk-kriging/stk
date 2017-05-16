% STK_DISP_ISLOOSE [STK internal]
%
% CALL: ISLOOSE = stk_disp_isloose ()
%
%    returns true if a 'loose' display mode is used, and false otherwise.
%
% NOTE
%
%    This function solves a Matlab/Octave compatibility issue.  See:
%
%     * https://savannah.gnu.org/bugs/index.php?51035
%     * https://sourceforge.net/p/kriging/tickets/73

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function b = stk_disp_isloose ()

try
    
    % This works in Matlab (even though 'FormatSpacing' as been removed from
    % the public list of root properties since R2014b) and in Octave <= 4.0.3
    fmt = get (0, 'FormatSpacing');
    
catch
    
    try
        
        % In Octave 4.2.0 the 'FormatSpacing' root property has been removed
        % but a different syntax has been introduced:
        [ign, fmt] = format ();  %#ok<ASGLU>
        
    catch
        
        % If nothing works, I really don't know which version of Octave or
        % Matlab you are using, but defaulting to 'loose' in this case seems
        % better than a warning or an error.
        fmt = 'loose';
        
    end
end

b = strcmp (fmt, 'loose');

end % function
