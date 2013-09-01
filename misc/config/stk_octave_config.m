% STK_OCTAVECONFIG_CHECKGLPK checks that the GLPK library is installed.

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
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

function stk_octave_config()

% We need to check that the GLPK library is installed. This is the case
% in most recent releases of Octave, but some older releases do not contain
% GLPK.
try
    stk_test_glpk_();
catch %#ok<CTCH>
    error('The GLPK library does not seem to be properly installed');
end

% Note: simply checking that __glpk__.oct is present is not good enough,
% since some distribution include (or so it seems) a fake __glpk__.oct
% package, which is in charge of issuing an error message...

% Suppress additional help information in Octave
suppress_verbose_help_message(true);

% Perhaps to early to use FLTK as a default choice
% if ismember('fltk', available_graphics_toolkits())
%    graphics_toolkit('fltk');
% end

% So, we keep gnuplot as a graphical backend
% but use GNUTERM=wxt for prettier and faster plots!
try
    % doesn't work in old Octave versions (e.g., 3.2.3)
    if ismember ('gnuplot', available_graphics_toolkits)
        graphics_toolkit ('gnuplot')
        setenv ('GNUTERM', 'wxt')
        fprintf ('Graphics toolkit: gnuplot\n');
    end
end

% Fix a problem with private folders in Octave 3.2.x
v = version;
if strcmp (v(1:4), '3.2.')
    addpath (fullfile ...
        (stk_get_root, 'utils', '@stk_dataframe', 'private'));
    addpath (fullfile ...
        (stk_get_root, 'core', '@stk_kriging_equation', 'private'));
end

end


%%%%%%%%%%%%%%%%%%%%%%
%%% stk_test_glpk_ %%%
%%%%%%%%%%%%%%%%%%%%%%

function stk_test_glpk_()

% minimize c*x
% under a*x = b, x >= 0
a = 1;
b = 1;
c = 1;

% solve this difficult problem using GLPK ;-)
x = glpk (c, a, b);
assert(x == 1);

end
