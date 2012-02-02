% STK_INIT initializes the STK
%
% CALL: stk_init()
%
% STK_INIT sets paths and environment variables

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%          =================================================
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version:   1.0
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%

% Displaying the Copying Permission Statement

disp( '                                                                     ' );
disp( '=====================================================================' );
disp( '                                                                     ' );
disp( 'STK is free software: you can redistribute it and/or modify          ' );
disp( 'it under the terms of the GNU General Public License as published by ' );
disp( 'the Free Software Foundation, either version 3 of the License, or    ' );
disp( '(at your option) any later version.                                  ' );
disp( '                                                                     ' );
disp( 'STK is distributed in the hope that it will be useful,               ' );
disp( 'but WITHOUT ANY WARRANTY; without even the implied warranty of       ' );
disp( 'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        ' );
disp( 'GNU General Public License for more details.                         ' );
disp( '                                                                     ' );
disp( 'You should have received a copy of the GNU General Public License    ' );
disp( 'along with STK.  If not, see <http://www.gnu.org/licenses/>.         ' );
disp( '                                                                     ' );
disp( '=====================================================================' );
disp( '                                                                     ' );

%=== Add STK folders to the path

STK_ROOT   = fileparts( mfilename('fullpath') );
STK_CORE   = fullfile( STK_ROOT, 'core'     );
STK_UTILS  = fullfile( STK_ROOT, 'utils'    );
STK_COVFCS = fullfile( STK_ROOT, 'covfcs'   );
STK_SAMPL  = fullfile( STK_ROOT, 'sampling' );

addpath( STK_CORE, STK_UTILS, STK_COVFCS, STK_SAMPL );

%=== Check which of Matlab or Octave is in use

octave_in_use = stk_is_octave_in_use();
if octave_in_use,
    s = ver('Octave');
    fprintf('Using Octave %s\n',s.Version);
	stk_check_octave_packages();
else
    s = ver('Matlab');
    fprintf('Using Matlab %s %s\n',s.Version,s.Release);
end

%=== Check for presence of the Parallel Computing Toolbox

fprintf('Parallel Computing toolbox... ');
if octave_in_use,
    fprintf('not available in Octave.\n');
else
    pct_found = stk_is_pct_installed();
    if pct_found, fprintf('found\n');
    else fprintf('not found.\n'); end
end

%=== Check for presence of an appropriate optimizer

if octave_in_use,
    fprintf('sqp()... ');
    % sqp() should be available since the "optim" package is loaded
	% but we check anyway (better safe than sorry)
    if exist('sqp','file') == 2,
		fprintf('found.\n');
	else
		fprintf('not found.\n');
        error('Please check that the optim package is properly installed.');
    end
else	
    fprintf('fmincon()... ');
	fmincon_found = stk_is_fmincon_available();
    if fmincon_found == true,
        fprintf('found.\n');
    else
        fprintf('not found.\n');
		warning('Falling back on fminsearch. Expect wrong results.')
    end
end

%=== Build MEX-files if necessary

fprintf('stk_distance_matrix()... ');

if exist('stk_distance_matrix','file') ~= 3,
    here = pwd();
    cd( STK_COVFCS );
    mex stk_distance_matrix.c
    cd( here );
end

if exist('stk_distance_matrix','file') == 3,
    fprintf('ok\n');
else
    fprintf('\n\n');
    error('compilation error ?\n');
end

%=== Cleanup

fprintf('\n');
clear here STK_* pct_found fmincon_found octave_in_use s ans
