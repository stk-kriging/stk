% STK_MAKEDOC generates the HTML documentation for the STK.

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

STK_ROOT = fileparts(mfilename('fullpath'));

addpath( ...
    fullfile(STK_ROOT, 'misc', 'm2html'), ...
    fullfile(STK_ROOT, 'misc', 'config'));

% Check that we are running the script from Matlab
if stk_is_octave_in_use(),
    error('M2HTML is not (yet) working with GNU Octave...');
end

% Ensure that we are at the root of STK
cd(STK_ROOT);

% Output directory
DOC_FOLDER = fullfile(STK_ROOT, 'htmldoc');
   
% Generate HTML documentation
m2html('htmlDir', DOC_FOLDER, 'recursive', 'on', 'graph', 'on', ...
       'ignoredDir', {'htmldoc', 'm2html', 'matlab'});
