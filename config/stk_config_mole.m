% Initialization script for the Matlab/Octave Langage Extension (MOLE).

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:   Julien Bect  <julien.bect@centralesupelec.fr>

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

function stk_config_mole (root, do_addpath, prune_unused)

mole_dir = fullfile (root, 'misc', 'mole');

% do_addpath: Do we want to add the subdirectories to the path ?
%   Defaults to true, for use in stk_init.m, typically.
%   do_appath = false is used in post_install.m, for octave packages.
if nargin < 2
    do_addpath = true;
end

% prune_unused: Do we want to remove unused subdirectories ?
%   Defaults to false, for use in stk_init.m, typically.
%   prune_unused = true is used in post_install.m, for octave packages.
if nargin < 3
    prune_unused = false;
end

if (exist ('OCTAVE_VERSION', 'builtin') == 5), % if Octave
    recursive_rmdir_state = confirm_recursive_rmdir (0);
end

opts = {mole_dir, do_addpath, prune_unused};


%--- isoctave -----------------------------------------------------------------

install_mole_function ('isoctave', opts{:});

% Note: if do_addpath is false, isoctave is not added to the search
% path. Therefore, it cannot be assumed below that isoctave is defined.


%--- Provide missing octave functions for Matlab users ------------------------

% TODO: extract functions that are REALLY needed in separate directories
%       and get rid of the others !

if (exist ('OCTAVE_VERSION', 'builtin') ~= 5), % if Matlab
    if do_addpath,
        addpath (fullfile (mole_dir, 'matlab'));
    end
elseif prune_unused,
    rmdir (fullfile (mole_dir, 'matlab'), 's');
end


%--- graphics_toolkit ---------------------------------------------------------

% For Octave users: graphics_toolkit is missing in some old version of Octave

% For Matlab users: there is no function named graphics_toolkit in Matlab. Our
% implementation returns either 'matlab-jvm' or 'matlab-nojvm'.

install_mole_function ('graphics_toolkit', opts{:});


%--- corr ---------------------------------------------------------------------

% For Octave users: corr belongs to Octave core in recent releases of Octave,
% but was missing in Octave 3.2.4 (when was it added ?)

% For Matlab users: corr is missing from Matlab itself, but it provided by the
% Statistics toolbox if you're rich enough to afford it.

install_mole_function ('corr', opts{:});


%--- isrow --------------------------------------------------------------------

% For Octave users: ?

% For Matlab users: missing in R2007a

install_mole_function ('isrow', opts{:});


%--- linsolve -----------------------------------------------------------------

% For Octave users: linsolve has been missing in Octave for a long time
% (up to 3.6.4)

install_mole_function ('linsolve', opts{:});


%--- quantile -----------------------------------------------------------------

% For Matlab users: quantile is missing from Matlab itself, but it provided by
% the Statistics toolbox if you're rich enough to afford it.

install_mole_function ('quantile', opts{:});


%--- CLEANUP ------------------------------------------------------------------

if (exist ('OCTAVE_VERSION', 'builtin') == 5), % is octave
    confirm_recursive_rmdir (recursive_rmdir_state);
end

end % function stk_config_mole


function install_mole_function (function_name, mole_dir, do_addpath, prune_unused)

function_dir = fullfile (mole_dir, function_name);

if isempty (which (function_name)),  % if the function is absent
    
    function_mfile = fullfile (function_dir, [function_name '.m']);
    
    if exist (function_dir, 'dir') && exist (function_mfile, 'file')
        
        % fprintf ('[MOLE]  Providing function %s\n', function_name);
        if do_addpath,
            addpath (function_dir);
        end
        
    else
        
        warning (sprintf ('[MOLE]  Missing function: %s\n', function_name));
        
    end
    
elseif prune_unused && (exist (function_dir, 'dir'))
        
    rmdir (function_dir, 's');
        
end

end % function install_mole_function

%#ok<*SPWRN,*WNTAG>
