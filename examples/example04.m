% Example 04 shows two-dimensional designs
% ========================================
%     Examples of two-dimensional designs

%          STK : a Small (Matlab/Octave) Toolbox for Kriging
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

%% Welcome

disp('                  ');
disp('#================#');
disp('#   Example 04   #');
disp('#================#');
disp('                  ');


%% Preliminaries

DIM = 2; BOX = [[0 0]; [2 4]]; % xmin, xmax
N1 = 9; N2 = 200; N1_ = [3 3]; N2_ = [25 8];

figure; set( gcf, 'Name', 'Example 4' );
nr = 2; nc = 3;


%% Cartesian grid ("full factorial" design)

x = stk_sampling_regulargrid(N1, DIM, BOX);
subplot(nr, nc, 1); plot(x.a(:,1), x.a(:,2), '*');
title(sprintf('%d x %d regular grid', N1_(1), N1_(2)));

x = stk_sampling_regulargrid(N2_, DIM, BOX);
subplot(nr, nc, 4); plot(x.a(:,1), x.a(:,2), '*');
title(sprintf('%d x %d regular grid', N2_(1), N2_(2)));


%% Maximin LHS

x = stk_sampling_maximinlhs(N1, DIM, BOX);
subplot(nr, nc, 2); plot(x.a(:,1), x.a(:,2), '*');
title(sprintf('%d-points maximin LHS', N1));

x = stk_sampling_maximinlhs(N2, DIM, BOX);
subplot(nr, nc, 5); plot(x.a(:,1), x.a(:,2), '*');
title(sprintf('%d-points maximin LHS', N2));


%% Random (uniform) sampling

x = stk_sampling_randunif(N1, DIM, BOX);
subplot(nr, nc, 3); plot(x.a(:,1), x.a(:,2), '*');
title(sprintf('%d-points randunif MCS', N1));

x = stk_sampling_randunif(N2, DIM, BOX);
subplot(nr, nc, 6); plot(x.a(:,1), x.a(:,2), '*');
title(sprintf('%d-points randunif MCS', N2));
