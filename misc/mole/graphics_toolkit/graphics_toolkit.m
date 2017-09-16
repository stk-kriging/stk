% GRAPHICS_TOOLKIT indicates which toolkit is assigned to new figures.
%
% This is a (partial) replacement for the graphics_toolkit function that is missing both
% from Matlab and from some old version f Octave.
%
% CALL: NAME = graphics_toolkit ()
%
%   returns:
%
%    * the result of get (0, 'defaultfigure__backend__') if you're running an old version
%      of Octave that does not have graphics_toolkit,
%
%    * 'matlab-nojvm' if running Matlab without the Java Virtual Machine,
%
%    * 'matlab-jvm' if running Matlab with the Java Virtual Machine.

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
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

function name = graphics_toolkit ()

if exist ('OCTAVE_VERSION', 'builtin') == 5  % Octave
    
    try
        % This should work on older versions of Octave, e.g., 3.2.4
        % (there was no notion of a 'toolkit' at the time, but if gnuplot
        %  is reported as the backend, then it is also the toolkit)
        name = get (0, 'defaultfigure__backend__');
    catch
        error ('Unable to determine which toolkit is being used.');
    end
    
else  % Matlab
    
    try
        assert (usejava ('jvm'));
        name = 'matlab-jvm';
    catch
        name = 'matlab-nojvm';
    end
    
end

end % function

%#ok<*CTCH>
