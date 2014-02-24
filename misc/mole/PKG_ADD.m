% Initialization script for the Matlab/Octave Langage Extension (MOLE).
%
% Note: this script must be renamed to PKG_ADD (without the extension) if the MOLE is to
% be released as an octave package.

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:   Julien Bect  <julien.bect@supelec.fr>

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

mole_dir = fileparts (mfilename ('fullpath'));

% MOLE: Matlab/Octave common part
addpath (fullfile(mole_dir, 'common'));

% MOLE: Matlab-specific part
% FIXME: directly test for functions instead !
if ~ isoctave,
    addpath (fullfile(mole_dir, 'matlab'));
end


%--- corr ---------------------------------------------------------------------

% For Octave users: corr belongs to Octave core in recent releases of Octave,
% but was missing in Octave 3.2.4 (when was it added ?)

% For Matlab users: corr is missing from Matlab itself, but it provided by the
% Statistics toolbox if you're rich enough to afford it.

if isempty (which ('corr')),
    addpath (fullfile (mole_dir, 'corr'));
end


%--- linsolve -----------------------------------------------------------------

% For Octave users: linsolve has been missing in Octave for a long time
% (up to 3.6.4)

if isempty (which ('linsolve')),
    addpath (fullfile (mole_dir, 'linsolve'));
end


%--- quantile -----------------------------------------------------------------

% For Matlab users: quantile is missing from Matlab itself, but it provided by
% the Statistics toolbox if you're rich enough to afford it.

if isempty (which ('quantile'))
    addpath (fullfile (mole_dir, 'quantile'));
end


clear mole_dir
