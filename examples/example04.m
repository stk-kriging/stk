% Example 04 shows two-dimensional designs
% ========================================
%     Examples of two-dimensional designs

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.0.2
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
clear all

octave_in_use = stk_is_octave_in_use();
if octave_in_use
    fprintf(stderr, 'Please, be patient...\n')
    fflush(stderr);
end
dim = 2;
box = [[0 0]; [2 4]]; % xmin, xmax

figure; set( gcf, 'Name', 'Example 4' );

nr = 2; nc = 3;

x = stk_sampling_cartesiangrid( 3, dim, box );
subplot(nr,nc,1); plot( x.a(:,1), x.a(:,2), '*' );
title('3 x 3 regular grid');

x = stk_sampling_cartesiangrid( [25 8], dim, box );
subplot(nr,nc,4); plot( x.a(:,1), x.a(:,2), '*' );
title('25 x 8 regular grid');

x = stk_sampling_maximinlhs( 9, dim, box );
subplot(nr,nc,2); plot( x.a(:,1), x.a(:,2), '*' );
title('9-points maximin LHS');

x = stk_sampling_maximinlhs( 200, dim, box );
subplot(nr,nc,5); plot( x.a(:,1), x.a(:,2), '*' );
title('200-points maximin LHS');

x = stk_sampling_randunif( 9, dim, box );
subplot(nr,nc,3); plot( x.a(:,1), x.a(:,2), '*' );
title('9-points randunif MCS');

x = stk_sampling_randunif( 200, dim, box );
subplot(nr,nc,6); plot( x.a(:,1), x.a(:,2), '*' );
title('200-points randunif MCS');
