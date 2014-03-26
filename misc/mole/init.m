% Initialization script for the Matlab/Octave Langage Extension (MOLE).

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

% Change directory to make install_mole_function available
here = pwd ();  cd (mole_dir);

% MOLE_DO_ADDPATH: Do we want to add the subdirectories to the path ?
% (MOLE_DO_ADDPATH = false is used in pre_install.m for octave packages)
if ~ exist ('MOLE_DO_ADDPATH', 'var')
    MOLE_DO_ADDPATH = true;
end

% MOLE_PRUNE_UNUSED: Do we want to remove unused subdirectories ?
% (MOLE_PRUNE_UNUSED = true is used in pre_install.m for octave packages)
if ~ exist ('MOLE_PRUNE_UNUSED', 'var')
    MOLE_PRUNE_UNUSED = false;
end

if (exist ('OCTAVE_VERSION', 'builtin') == 5), % if Octave
    recursive_rmdir_state = confirm_recursive_rmdir (0);
end

opts = {MOLE_DO_ADDPATH, MOLE_PRUNE_UNUSED};


%--- isoctave -----------------------------------------------------------------

install_mole_function ('isoctave', mole_dir, opts{:});

% Note: if MOLE_DO_ADDPATH is false, isoctave is not added to the search
% path. Therefore, it cannot be assumed below that isoctave is defined.


%--- Provide missing octave functions for Matlab users ------------------------

% TODO: extract functions that are REALLY needed in separate directories
%       and get rid of the others !

if (exist ('OCTAVE_VERSION', 'builtin') ~= 5), % if Matlab
    if MOLE_DO_ADDPATH,
        addpath (fullfile (mole_dir, 'matlab'));
    end
elseif MOLE_PRUNE_UNUSED,
    rmdir (fullfile (mole_dir, 'matlab'), 's');
end


%--- graphics_toolkit ---------------------------------------------------------

% For Octave users: graphics_toolkit is missing in some old version of Octave

% For Matlab users: there is no function named graphics_toolkit in Matlab. Our
% implementation returns either 'matlab-jvm' or 'matlab-nojvm'.

install_mole_function ('graphics_toolkit', mole_dir, opts{:});


%--- corr ---------------------------------------------------------------------

% For Octave users: corr belongs to Octave core in recent releases of Octave,
% but was missing in Octave 3.2.4 (when was it added ?)

% For Matlab users: corr is missing from Matlab itself, but it provided by the
% Statistics toolbox if you're rich enough to afford it.

install_mole_function ('corr', mole_dir, opts{:});


%--- linsolve -----------------------------------------------------------------

% For Octave users: linsolve has been missing in Octave for a long time
% (up to 3.6.4)

install_mole_function ('linsolve', mole_dir, opts{:});


%--- quantile -----------------------------------------------------------------

% For Matlab users: quantile is missing from Matlab itself, but it provided by
% the Statistics toolbox if you're rich enough to afford it.

install_mole_function ('quantile', mole_dir, opts{:});


%--- CLEANUP ------------------------------------------------------------------

cd (here);

if (exist ('OCTAVE_VERSION', 'builtin') == 5), % is octave
    confirm_recursive_rmdir (recursive_rmdir_state);
end

clear mole_dir here MOLE_PRUNE_UNUSED MOLE_DO_ADDPATH recursive_rmdir_state opts
