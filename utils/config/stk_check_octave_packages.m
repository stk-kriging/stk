% STK_CHECK_OCTAVE_PACKAGES checks required Octave packages
%
% CALL: stk_check_octave_packages()
%
% An error is raised is one of the required packages is not installed.
% Otherwise, all required packages are loaded (if they are not already).

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version: 1.0
%    Authors: Julien Bect <julien.bect@supelec.fr>
%             Emmanuel Vazquez <emmanuel.vazquez@supelec.fr>
%    URL:     http://sourceforge.net/projects/kriging/
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

function stk_check_octave_packages()

pkg_list = pkg('list');

stk_check_octave_package_('optim', pkg_list);
stk_check_octave_package_('statistics', pkg_list);

end


function stk_check_octave_package_(name, pkg_list)

for i = 1:length(pkg_list)
	if strcmp(pkg_list{i}.name, name),
		if ~pkg_list{i}.loaded,
			pkg('load', name);
		end
		fprintf('Octave package %s-%s loaded.\n', ...
		         pkg_list{i}.name, pkg_list{i}.version);
		return
	end
end

error('Octave package %s not installed.', name);

end