% STK_TESTFUN_TRUSS3_BB computes displacements and stresses for 'truss3'
%
% CALL: Z = stk_testfun_truss3_bb (X, CONST)
%
% See also: stk_testcase_truss3, stk_testfun_truss3_vol

% Author
%
%    Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement  (this file)
%
%    To the extent possible under law, CentraleSupélec has waived all
%    copyright and related or neighboring rights to
%    stk_testfun_truss3_bb.m.  This work is published from France.
%
%    License: CC0  <http://creativecommons.org/publicdomain/zero/1.0/>

% Copying Permission Statement (STK toolbox as a whole)
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function z = stk_testfun_truss3_bb (x, const)

% Convert input to double-precision input data
% (and get rid of extra structure such as table or stk_dataframe objects)
x_ = double (x);

% Check input size
[n, dim] = size (x_);
switch dim
    
    case 4
        % Use nominal loads
        F = zeros (n, 2);
        F(:, 1) = const.F1_mean;
        F(:, 2) = const.F2_mean;
        x_ = [x_ F];
        
    case 6
        % Loads have been provided as well
        
    otherwise
        error ('Incorrect number of variables.');
        
end

% Extract variables
a = x_(:, 1:3);  % Cross-sections of the bars     [m^2]
w = x_(:, 4);    % Horizontal position of bar #2  [m]
F = x_(:, 5:6);  % Horizontal and vertical loads  [N]

% Extract constants
D = const.D;    % Total width of the structure   [m]
L = const.L;    % Length of the vertical bar     [m]
E = const.E;    % Young's modulus                [Pa]

% Check w values
D_w = D - w;
if any (w < 0) || any (D_w < 0)
    error ('w should be between 0 and D.')
end

% Lengths
LL = repmat (L, [n 3]);
LL(:, 1) = sqrt (L ^ 2 + w .^ 2);
LL(:, 3) = sqrt (L ^ 2 + D_w .^ 2);

% Sines and cosines
sin_theta =   L ./ LL(:, 1);
cos_theta =   w ./ LL(:, 1);
sin_alpha =   L ./ LL(:, 3);
cos_alpha = D_w ./ LL(:, 3);

% Linear relation between tensile forces and elongations,
% assuming linear elasticity (Hooke's law)
C = E * a ./ LL;

% Compute displacement of node P and stresses
y = zeros (n, 2);  % Displacement of node P
s = zeros (n, 3);  % Tensile stress in the bars
for i = 1:n
    
    % Rectangular matrix A for Equ. 9.1 in Das (1997) p.65, gives the
    % equilibrium relation between tensile forces and loads (small displacements)
    A = [cos_theta(i) sin_theta(i); 0 1; -cos_alpha(i) sin_alpha(i)];
    
    % Stiffness matrix
    K = A' * (diag (C(i, :))) * A;
    
    % Compute the displacement of node P
    y(i, :) = F(i, :) / K;
    
    % Bar elongations
    delta = y(i, :) * A';
    
    % Tensile stresses (Hooke's law)
    s(i, :) = E * delta ./ LL(i, :);
    
end

% Output: return displacement of node P and tensile stresses (five outputs)
z = [y s];

% df-in/df-out
if isa (x, 'stk_dataframe')
    z = stk_dataframe (z, {'y1' 'y2' 'sigma1' 'sigma2' 'sigma3'}, x.rownames);
end

end % function
