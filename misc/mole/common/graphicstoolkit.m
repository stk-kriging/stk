% GRAPHICSTOOLKIT indicates which toolkit is assigned to new figures.
%
% CALL: NAME = graphicstoolkit ()
%
%   returns:
%    
%    * octave-XXX    if Octave is running with XXX as its default toolkit,
%    * matlab-nojvm  if Matlab is running without the Java Virtual Machine,
%    * matlab-jvm    if Matlab is running with the Java Virtual Machine,

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function name = graphicstoolkit ()

if isoctave,

    try
        % This should work on older versions of Octave, e.g., 3.2.4
        % (there was no notion of a 'toolkit' at the time, but if gnuplot
        %  is reported as the backend, then it is also the toolkit)
        b = get(0, 'defaultfigure__backend__');
        if strcmp (b, 'gnuplot')
            name = 'octave-gnuplot';
        else
            name = 'octave-unknown';
        end
    catch
        try
            % This should work in modern versions of Octave, e.g., 3.6.2
            % (when exactly did the transition occur ?)
            name = ['octave-' graphics_toolkit];
        catch
            error ('Unable to determine which toolkit is being used.');
        end
    end

else % Matlab

    try
        assert (usejava ('jvm'));
        name = 'matlab-jvm';
    catch
        name = 'matlab-nojvm';
    end

end

end % function graphicstoolkit
