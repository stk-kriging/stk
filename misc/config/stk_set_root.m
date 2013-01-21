% STK_SET_ROOT sets STK's root folder and add subfolder to the path

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>

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

function out = stk_set_root(root)

current_root = find_stk_root();

if nargin > 0,
        
    while ~isempty(current_root) && ~strcmp(current_root, root)                
        warning(sprintf(['Removing another copy of STK from the ' ...
            'search path.\n    (%s)\n'], current_root)); %#ok<SPWRN>
        stk_rmpath(current_root);
        current_root = find_stk_root();
    end
    
    % NOTE: calling stk_rmpath when root and stkRootFolder are identical
    % is harmless in recent versions of Matlab and Octave, but has been
    % found to cause a bug in Octave 3.0.2 when calling stk_init twice
    % in a row.
    
    current_root = root;
    
    % finally, add STK folders to the path
    stk_addpath(current_root);
    
end

out = current_root;

end % stk_set_root


%%%%%%%%%%%%%%%%%%
%%% stk_rmpath %%%
%%%%%%%%%%%%%%%%%%

function stk_rmpath(root)

warning('off','MATLAB:rmpath:DirNotFound');
path = stk_path(root);
rmpath( path{:} );
warning('on','MATLAB:rmpath:DirNotFound');

end % stk_rmpath


%%%%%%%%%%%%%%%%%%%
%%% stk_addpath %%%
%%%%%%%%%%%%%%%%%%%

function stk_addpath(root)

path = stk_path(root);

for i = 1:length(path),
    if exist(path{i},'dir')
        addpath(path{i});
    else
        error('problem in stk_path ?');
    end
end

end % stk_addpath


%%%%%%%%%%%%%%%%%%%%%
%%% find_stk_root %%%
%%%%%%%%%%%%%%%%%%%%%

function root = find_stk_root()

try
    % This will raise an error if STK is not in the search path
    s = which('stk_test');
    % Extract root folder
    n = length(s) - 1 - length(fullfile('misc', 'test', 'stk_test.m'));
    root = s(1:n);
catch
    root = [];
end

end % function find_stk_root
