% STK_SET_ROOT sets STK's root folder and add subfolder to the path

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%          =================================================
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.1
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

function out = stk_set_root(root)

persistent root_folder

if nargin > 0,    
    
	first_time = isempty(root_folder);
	
	if ~first_time
		if ~strcmp(root, root_folder),
			% changing STK's root folder: we remove
			% the previous one from the path
			stk_rmpath(root_folder);			
		end
	end
	
	% NOTE: calling stk_rmpath when root and root_folder are identical
	% is harmless in recent versions of Matlab and Octave, but has been
	% found to cause a bug in Octave 3.0.2 when calling stk_init twice
	% in a row.
	
	root_folder = root;
	if first_time,
		% lock this M-file into memory to prevent clear
		% all from erasing the persistent variable
		mlock(); 
	end
	
	% finally, add STK folders to the path
	stk_addpath(root_folder);

end

out = root_folder;
   
end % stk_set_root


%%%%%%%%%%%%%%%%%%
%%% stk_rmpath %%%
%%%%%%%%%%%%%%%%%%

function stk_rmpath(root)

warning('off','MATLAB:rmpath:DirNotFound');
path = stk_makepath(root);
rmpath( path{:} );
warning('on','MATLAB:rmpath:DirNotFound');

end % stk_rmpath


%%%%%%%%%%%%%%%%%%%
%%% stk_addpath %%%
%%%%%%%%%%%%%%%%%%%

function stk_addpath(root)

path = stk_makepath(root);
for i=1:length(path),
    if exist(path{i},'dir')
        addpath(path{i});
    else
        error('problem in stk_makepath ?');
    end
end

end % stk_addpath


%%%%%%%%%%%%%%%%%%%%
%%% stk_makepath %%%
%%%%%%%%%%%%%%%%%%%%

function path = stk_makepath(root)

path = { ...
    fullfile(root, 'core'            ), ...
    fullfile(root, 'covfcs'          ), ...
    fullfile(root, 'paramestim'      ), ...
    fullfile(root, 'sampling'        ), ...
    fullfile(root, 'utils'           ), ...
    fullfile(root, 'misc'            ), ...
    fullfile(root, 'misc', 'config'  ), ...
    fullfile(root, 'misc', 'plot'    ), ...
    fullfile(root, 'misc', 'specfun' )   };

end % stk_makepath
