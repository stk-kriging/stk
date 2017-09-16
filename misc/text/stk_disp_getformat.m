% STK_DISP_GETFORMAT [STK internal]
%
% CALL: [FMT, SPC] = stk_disp_getformat ()
%
% NOTE
%
%    This function solves a Matlab/Octave compatibility issue.  See:
%
%     * https://savannah.gnu.org/bugs/?51035
%     * https://savannah.gnu.org/bugs/?49951
%     * https://savannah.gnu.org/bugs/?46034
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

function [fmt, spc] = stk_disp_getformat ()

persistent method
if isempty (method)
    method = choose_method ();
end

switch method
    
    case 1  % Matlab and some versions of Octave (e.g., 4.0.3)
        
        % Note: 'Format' and 'FormatSpacing' have been removed from the public
        % list of root properties since Matlab R2014b, but are still recommended
        % as the proper way to obtain this information in R2017a's manual.
        
        fmt = get (0, 'Format');
        spc = get (0, 'FormatSpacing');
        
    case 2  % Octave 4.2 for sure (when was it introduced ?)
        
        % In Octave 4.2.0 the 'Format' and 'FormatSpacing' root property have
        % been removed, but __formattring__ and __compactformat__ are still
        % available.
        
        fmt = feval ('__formatstring__');
        spc = feval ('__compactformat__');
        
    case 3  % Octave > 4.2
        
        % After Octave 4.2.0, __formattring__ and __compactformat__ have been
        % removed too, and a new syntax is available.
        
        [fmt, spc] = format ();
        
    otherwise
        
        % If nothing works, I really don't know which version of Octave or
        % Matlab you are using, but defaulting to 'short' + 'loose' in this case
        % seems better than a warning or an error.
        
        fmt = 'short';
        spc = 'loose';
        
end % switch

end % function


function method = choose_method ()

try
    
    spc = get (0, 'FormatSpacing');
    assert (ismember (spc, {'compact', 'loose'}));
    method = 1;
    
catch
    
    if exist ('__compactformat__', 'builtin') == 5
        
        method = 2;
        
    else
        
        try
            
            [fmt, spc] = format (); %#ok<ASGLU> CG#07
            assert (ismember (spc, {'compact', 'loose'}));
            method = 3;
            
        catch
            
            method = 4;
            
        end % try
        
    end % if
    
end % try

end % function
