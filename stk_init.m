% STK_INIT initializes the STK
%
% CALL: stk_init()
%
% STK_INIT sets paths and environment variables

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

%% PKG_ADD: stk_init ('pkg_load');

%% PKG_DEL: stk_init ('pkg_unload');

function output = stk_init (command)

if nargin == 0
    command = 'pkg_load';
end

% Deduce the root of STK from the path to this script
root = fileparts (mfilename ('fullpath'));

switch command
    
    case 'pkg_load'
        stk_init__pkg_load (root);
        
    case 'pkg_unload'
        stk_init__pkg_unload (root);
        
    case 'prune_mole'
        stk_init__config_mole (root, false, true);  % prune, but do not add to path
        
    case 'clear_persistents'
        % Note: this implies munlock
        stk_init__clear_persistents ();
        
    case 'munlock'
        stk_init__munlock ();
        
    case 'addpath'
        % Add STK subdirectories to the search path
        stk_init__addpath (root);
        
    case 'rmpath'
        % Remove STK subdirectories from the search path
        stk_init__rmpath (root);
        
    case 'genpath'
        % Return the list of all STK "public" subdirectories
        output = stk_init__genpath (root);
        
    case 'build_mex'
        % Compile all MEX-files in the STK
        stk_init__build_mex (root, false);
        
    case 'force_build_mex'
        % Compile all MEX-files in the STK
        stk_init__build_mex (root, true);
        
    case 'get_make_info'
        % Provide make information for STK's MEX-files
        output = stk_init__get_make_info ();
        
    case 'test_private_mex'
        % Check if the MEX-files located in private dirs are found
        stk_init__test_private_mex ();
        
    otherwise
        error ('Unknown command.');
        
end % switch

end % function

%#ok<*NODEF,*WNTAG,*SPERR,*SPWRN,*LERR,*CTCH,*SPERR>


function stk_init__pkg_load (root)

% Add STK's root directory to the path
addpath (root);

% Unlock all possibly mlock-ed STK files and clear all STK functions
% that contain persistent variables
stk_init__clear_persistents ();

% Build MEX-files "in-place"
stk_init__build_mex (root, false);

% Add STK subdirectories to the path
%   (note: doing this ATFER building the MEX-files seems to solve
%    the problem related to having MEX-files in private folders)
stk_init__addpath (root);

% Check that MEX-files located in private folders are properly detected (note:
% there are no MEX-files in private folders if STK is used as an Octave package)
if isoctave
    stk_init__test_private_mex ();
end

% Set default options
stk_options_set ();

% Select default "parallelization engine"
stk_parallel_engine_set ();

% Hide some warnings about numerical accuracy
warning ('off', 'STK:stk_predict:NegativeVariancesSetToZero');
warning ('off', 'STK:stk_cholcov:AddingRegularizationNoise');
warning ('off', 'STK:stk_param_relik:NumericalAccuracyProblem');

% Uncomment this line if you want to see a lot of details about the internals
% of stk_dataframe and stk_factorialdesign objects:
% stk_options_set ('stk_dataframe', 'disp_format', 'verbose');

end % function


function stk_init__pkg_unload (root)

% Unlock all possibly mlock-ed STK files and clear all STK functions
% that contain persistent variables
stk_init__clear_persistents ();

% Remove STK subdirectories from the path
stk_init__rmpath (root);

% Remove STK root directory from the path
rmpath (root);

end % function


function stk_init__munlock ()

filenames = { ...
    'isoctave', ...
    'stk_optim_fmincon', ...
    'stk_options_set', ...
    'stk_parallel_engine_set'};

for i = 1:(length (filenames))
    name = filenames{i};
    if mislocked (name),
        munlock (name);
    end
end

end % function


function stk_init__clear_persistents ()

stk_init__munlock ();

filenames = { ...
    'isoctave', ...
    'stk_disp_progress', ...
    'stk_gausscov_iso', ...
    'stk_gausscov_aniso', ...
    'stk_materncov_aniso', ...
    'stk_materncov_iso', ...
    'stk_materncov32_aniso', ...
    'stk_materncov32_iso', ...
    'stk_materncov52_aniso', ...
    'stk_materncov52_iso', ...
    'stk_optim_fmincon', ...
    'stk_options_set', ...
    'stk_parallel_engine_set'};

for i = 1:(length (filenames))
    clear (filenames{i});
end

end % function


function stk_init__addpath (root)

path = stk_init__genpath (root);

% Check for missing directories
for i = 1:length (path),
    if ~ exist (path{i}, 'dir')
        error (sprintf (['Directory %s does not exist.\n' ...
            'Is there a problem in stk_init__genpath ?'], path{i}));
    end
end

% Add STK folders to the path
addpath (path{:});

% Selectively add MOLE subdirectories to compensate for missing functions
stk_init__config_mole (root, true, false);  % (add to path, but do not prune)

end % function


function path = stk_init__genpath (root)

path = {};

% main function folders
path = [path {...
    fullfile(root, 'arrays'            ) ...
    fullfile(root, 'arrays', 'generic' ) ...
    fullfile(root, 'core'              ) ...
    fullfile(root, 'covfcs'            ) ...
    fullfile(root, 'lm'                ) ...
    fullfile(root, 'paramestim'        ) ...
    fullfile(root, 'sampling'          ) ...
    fullfile(root, 'utils'             ) }];

% 'misc' folder and its subfolders
misc = fullfile (root, 'misc');
path = [path {...
    fullfile(misc, 'design'  ) ...
    fullfile(misc, 'dist'    ) ...
    fullfile(misc, 'distrib' ) ...
    fullfile(misc, 'error'   ) ...
    fullfile(misc, 'optim'   ) ...
    fullfile(misc, 'options' ) ...
    fullfile(misc, 'parallel') ...
    fullfile(misc, 'pareto'  ) ...
    fullfile(misc, 'plot'    ) ...
    fullfile(misc, 'specfun' ) ...
    fullfile(misc, 'test'    ) ...
    fullfile(misc, 'text'    ) }];

% IAGO
iago = fullfile (root, 'iago');
path = [path {iago ...
    fullfile(iago, 'crit'   ) ...
    fullfile(iago, 'rep'    ) ...
    fullfile(iago, 'utils'  )}];

% folders that contain examples
path = [path {...
    fullfile(root, 'examples', '01_kriging_basics'       ) ...
    fullfile(root, 'examples', '02_design_of_experiments') ...
    fullfile(root, 'examples', '03_miscellaneous'        ) ...
    fullfile(root, 'examples', 'test_functions'          ) }];

% Fix a problem with private folders in Octave 3.2.x
%   (add private folders to the path to make STK work...)
if (exist ('OCTAVE_VERSION', 'builtin') == 5)
    v = version;
    if strcmp (v(1:4), '3.2.')
        test_path = [path {...
            fullfile(root, 'arrays', '@stk_dataframe') ...
            fullfile(root, 'arrays', '@stk_factorialdesign') ...
            fullfile(root, 'core', '@stk_kreq_qr')}];
        private_path = {};
        for i = 1:(length (test_path))
            p = fullfile (test_path{i}, 'private');
            if exist (p, 'dir')
                private_path = [private_path {p}];
            end
        end
        path = [path private_path];
    end
end

end % function


function stk_init__rmpath (root)

s = path ();

regex1 = strcat ('^', escape_regexp (root));

isoctave = (exist ('OCTAVE_VERSION', 'builtin') == 5);

if isoctave,
    regex2 = strcat (escape_regexp (octave_config_info ('api_version')), '$');
end

while ~ isempty (s)
    
    [d, s] = strtok (s, pathsep);  %#ok<STTOK>
    
    if (~ isempty (regexp (d,  regex1, 'once'))) ...
            && ((~ isoctave) || isempty (regexp (d, regex2, 'once'))) ...
            && (~ strcmp (d, root))  % Only remove subdirectories, not the root
        
        rmpath (d);
        
    end
end

end % function


function s = escape_regexp (s)

% For backward compatibility with Octave 3.2.x, we cannot use regexprep here:
%
%    s = regexprep (s, '([\+\.\\])', '\\$1');
%
% Indeed, compare the results with Octave 3.8.x
%
%    >> regexprep ('2.2.0', '(\.)', '\$1')
%    ans = 2$12$10
%
%    >> regexprep ('2.2.0', '(\.)', '\\$1')
%    ans = 2\.2\.0
%
% and those with Octave 3.2.4
%
%    >> regexprep ('2.2.0', '(\.)', '\$1')
%    ans = 2\.2\.0
%
%    >> regexprep ('2.2.0', '(\.)', '\\$1')
%    ans = 2\\.2\\.0
%

s = strrep (s, '\', '\\');
s = strrep (s, '+', '\+');
s = strrep (s, '.', '\.');

end % function


function stk_init__build_mex (root, force_recompile)

here = pwd ();

opts.force_recompile = force_recompile;
opts.include_dir = fullfile (root, 'misc', 'include');

info = stk_init__get_make_info ();

for k = 1:(length (info)),
    stk_init__compile (fullfile (root, info(k).relpath), ...
        opts, info(k).mexname, info(k).other_src, info(k).includes);
end

cd (here);

end % function


function stk_init__compile (d, opts, mexname, other_src, includes)

mex_filename = [mexname '.' mexext];
mex_fullpath = fullfile (d, mex_filename);

src_filename = [mexname '.c'];

dir_mex = dir (mex_fullpath);
compile = opts.force_recompile || (isempty (dir_mex));

src_files = [{src_filename} other_src];

for k = 1:(length (src_files))
    % Look for src file in current directory
    dir_src = dir (fullfile (d, src_files{k}));
    if isempty (dir_src)
        error ('STK:stk_init__build_mex:FileNotFound', ...
            sprintf ('Source file %s not found', src_files{k}));
    end
    compile = compile || (dir_mex.datenum < dir_src.datenum);
end

if ~ isempty (includes)
    for k = 1:(length (includes))
        % Look for header file in current directory
        dir_hdr = dir (fullfile (d, includes{k}));
        if isempty (dir_hdr)
            % Look for header file in include directory
            dir_hdr = dir (fullfile (opts.include_dir, includes{k}));
            if isempty (dir_hdr)
                error ('STK:stk_init__build_mex:FileNotFound', ...
                    sprintf ('Header file %s not found', includes{k}));
            end
        end
        compile = compile || (dir_mex.datenum < dir_hdr.datenum);
    end
end

if compile,
    
    fprintf ('Compiling MEX-file %s... ', mexname);
    
    here = pwd ();
    
    try  % Safely change directory
        cd (d);
    
        include = sprintf ('-I%s', opts.include_dir);
        mex (src_files{:}, include);
        
        fprintf ('ok.\n');
        if (exist ('OCTAVE_VERSION', 'builtin') == 5)
            fflush (stdout);
        end
        cd (here);
        
    catch
        cd (here);
        rethrow (lasterror ());
    end
end

end % function


function info = stk_init__get_make_info ()

relpath = fullfile ('misc', 'dist', 'private');
info = register_mex ([],   relpath, 'stk_dist_matrixx');
info = register_mex (info, relpath, 'stk_dist_matrixy');
info = register_mex (info, relpath, 'stk_dist_pairwise');
info = register_mex (info, relpath, 'stk_filldist_discr_mex');
info = register_mex (info, relpath, 'stk_mindist_mex');
info = register_mex (info, relpath, 'stk_gpquadform_matrixy');
info = register_mex (info, relpath, 'stk_gpquadform_matrixx');
info = register_mex (info, relpath, 'stk_gpquadform_pairwise');

relpath = fullfile ('misc', 'distrib', 'private');
info = register_mex (info, relpath, 'stk_distrib_bivnorm0_cdf');

relpath = fullfile ('arrays', '@stk_dataframe', 'private');
info = register_mex (info, relpath, 'get_column_number');

relpath = 'sampling';
info = register_mex (info, relpath, 'stk_sampling_vdc_rr2', {}, {'primes.h'});

relpath = fullfile ('misc', 'pareto', 'private');
info = register_mex (info, relpath, 'stk_paretofind_mex', {}, {'pareto.h'});
info = register_mex (info, relpath, 'stk_isdominated_mex', {}, {'pareto.h'});
info = register_mex (info, relpath, 'stk_dominatedhv_mex', {'wfg.c'}, {'wfg.h'});

end % function


function info = register_mex (info, relpath, mexname, other_src, includes)

if nargin < 4,
    other_src = {};
end

if nargin < 5,
    includes = {};
end

k = 1 + length (info);

info(k).relpath = relpath;
info(k).mexname = mexname;
info(k).other_src = other_src;
info(k).includes = [{'stk_mex.h'} includes];

end % function


function stk_init__test_private_mex ()

try
    n = 5;  d = 2;
    x = rand (n, d);
    D = stk_dist (x);  % calls a MEX-file internally
    assert (isequal (size (D), [n n]));
catch
    err = lasterror ();
    if (~ isempty (regexp (err.message, 'stk_dist_matrixx', 'once'))) ...
            && (~ isempty (regexp (err.message, 'undefined', 'once')))
        fprintf ('\n\n');
        warning (sprintf (['\n\n' ...
            '!>>>>>> PLEASE RESTART OCTAVE BEFORE USING STK <<<<<<!\n' ...
            '!                                                    !\n' ...
            '! Some STK functions implemented as MEX-files have   !\n' ...
            '! just been compiled, but will not be detected until !\n' ...
            '! Octave is restarted.                               !\n' ...
            '!                                                    !\n' ...
            '! We apologize for this inconvenience, which is      !\n' ...
            '! related to a known Octave bug (bug #40824), that   !\n' ...
            '! will hopefully be fixed in the near future.        !\n' ...
            '! (see https://savannah.gnu.org/bugs/?40824)         !\n' ...
            '!                                                    !\n' ...
            '!>>>>>> PLEASE RESTART OCTAVE BEFORE USING STK <<<<<<!\n' ...
            '\n']));
    else
        rethrow (err);
    end
end

end % function


function stk_init__config_mole (root, do_addpath, prune_unused)

mole_dir = fullfile (root, 'misc', 'mole');
isoctave = (exist ('OCTAVE_VERSION', 'builtin') == 5);

if isoctave
    recursive_rmdir_state = confirm_recursive_rmdir (0);
end

opts = {mole_dir, do_addpath, prune_unused};

% isoctave
install_mole_function ('isoctave', opts{:});

% Provide missing octave functions for Matlab users
% TODO: extract functions that are REALLY needed in separate directories
%       and get rid of the others !
if (exist ('OCTAVE_VERSION', 'builtin') ~= 5)  % if Matlab
    if do_addpath
        addpath (fullfile (mole_dir, 'matlab'));
    end
elseif prune_unused
    rmdir (fullfile (mole_dir, 'matlab'), 's');
end

% graphics_toolkit
%  * For Octave users: graphics_toolkit is missing in some old version of Octave
%  * For Matlab users: there is no function named graphics_toolkit in Matlab.
%    Our implementation returns either 'matlab-jvm' or 'matlab-nojvm'.
install_mole_function ('graphics_toolkit', opts{:});

% isrow
%  * For Octave users: ?
%  * For Matlab users: missing in R2007a
install_mole_function ('isrow', opts{:});

% linsolve
%  * For Octave users: linsolve has been missing in Octave for a long time
%    (up to 3.6.4)
%  * For Matlab users: ?
install_mole_function ('linsolve', opts{:});

% quantile
%  * For Octave users: ?
%  * For Matlab users: quantile is missing from Matlab itself, but it provided
%    by the Statistics toolbox if you're rich enough to afford it.
install_mole_function ('quantile', opts{:});

% cleanup
if isoctave
    confirm_recursive_rmdir (recursive_rmdir_state);
end

end % function


function install_mole_function (funct_name, mole_dir, do_addpath, prune_unused)

function_dir = fullfile (mole_dir, funct_name);

if isempty (which (funct_name)),  % if the function is absent
    
    function_mfile = fullfile (function_dir, [funct_name '.m']);
    
    if exist (function_dir, 'dir') && exist (function_mfile, 'file')
        
        % fprintf ('[MOLE]  Providing function %s\n', function_name);
        if do_addpath,
            addpath (function_dir);
        end
        
    else
        
        warning (sprintf ('[MOLE]  Missing function: %s\n', funct_name));
        
    end
    
elseif prune_unused && (exist (function_dir, 'dir'))
    
    rmdir (function_dir, 's');
    
end

end % function
