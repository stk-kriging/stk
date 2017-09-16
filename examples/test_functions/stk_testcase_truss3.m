% STK_TESTCASE_TRUSS3 provides information about the 'truss3' test case
%
% CALL: TC = stk_testcase_truss3 ()
%
%    returns a structure TC that describes the 'truss3' test case, borrowed
%    from [1, chapter 9].  This structure contains two fields:
%
%     * .constants: all the numerical constants for this problem,
%
%     * .search_domain: an stk_hrect object that specifies the search domain
%       of the optimization problem.
%
% TEST CASE OVERVIEW
%
%    The system considered in this test case is the following 3-bar truss:
%
%                 <---------  D  ----------->
%                 <--- w --->
%           ------A==========B==============C------
%                  \_        |           __/    ^
%                    \_      | (2)    __/       |
%                      \_    |     __/          L
%                   (1)  \_  |  __/   (3)       |
%                          \_P_/                v
%
%    Nodes A, B and C are fixed (pin joints).  Node D is submitted to both an
%    horizontal load F1 (e.g., wind) and a vertical load F2 (suspended load).
%
%    The design variables are the cross-sections a1, a2 and a3 of the three
%    bars, and the horizontal position w of the vertical bar.  The quantities
%    of interest are the total volume of the structure, the mechanical
%    (tensile) stress in the bars, and the displacement of P.  Various
%    formulations of optimization problems can be considered, depending on
%    which quantities are selected as contraints and objectives, and whether
%    or not uncertainties are taken into account (robust formulations).
%
% NUMERICAL CONSTANTS
%
%    The numerical values borrowed from [1] have been converted to SI
%    units.  The fields of TC.constants are:
%
%     *       .D: truss width [m],
%     *       .L: length of the vertical bar [m],
%     *       .E: Young's modulus [Pa],
%
%     *   .a_min: minimal cross-section [m^2],
%     *   .a_max: maximal cross-section [m^2],
%     *   .w_min: minimal value of the position of the vertical bar [m],
%     *   .w_max: maximal value of the position of the vertical bar [m],
%
%     * .F1_mean: mean (nominal) value of the horizontal load [N],
%     *  .F1_std: standard deviation of the horizontal load [N],
%     * .F2_mean: mean (nominal) value of the vertical load [N]
%     *  .F2_std: standard deviation of the vertical load [N].
%
%    The standard deviations .F1_std and .F2_std are used in the formulation
%    of robust optimization problems related to this test case [see 1, chap 11].
%    
% NUMERICAL FUNCTIONS
%
%    Two numerical functions are provided to compute the quantities of interest
%    of this test case:
%
%     * stk_testfun_truss3_vol: computes the total volume of the structure,
%
%     * stk_testfun_truss3_bb: computes the tensile stress in the bars and the
%       displacement of P.
%
%    Both functions have the same syntax:
%
%       V = stk_testfun_truss3_vol (X, CONST)
%
%       Z = stk_testfun_truss3_bb (X, CONST)
%
%    where CONST is a structure containing the necessary numerical constants.
%    To use the constants from [1], pass TC.constants as second input argument.
%
%    Both function accept as first input argument an N x D matrix (or data
%    frame) where D is either 4 or 6:
%
%     * columns 1--3: cross-section a1, a2 and a3,
%
%     * column 4: position w of the horizontal bar,
%
%     * column 5-6 (optional): horizontal and vertical loads F1, F2.
%
%    The second function is named 'bb' for 'black box', as it plays the role of
%    a (supposedly expensive to evaluate) black box computer model for this
%    test case.  The output Z has five columns, corresponding to:
%
%     * columns 1--2: horizontal and vertical displacement y1, y2 of P,
%
%     * columns 3--5: tensile stress sigma_j in bars j = 1, 2 and 3.
%
% EXAMPLE
%
%     tc = stk_testcase_truss3 ();  n = 5;
%
%     % Draw 5 points uniformly in the 4D input domain ("design space")
%     xd = stk_sampling_randunif (n, [], tc.search_domain)
%
%     % Compute the volumes
%     v = stk_testfun_truss3_vol (xd, tc.constants)
%
%     % Compute displacements and stresses for nominal loads
%     z = stk_testfun_truss3_bb (xd, tc.constants)
%
%     % Draw loads from normal distributions
%     F = stk_dataframe (zeros (n, 2), {'F1' 'F2'});
%     F(:, 1) = tc.constants.F1_mean + tc.constants.F1_std * randn (n, 1);
%     F(:, 2) = tc.constants.F2_mean + tc.constants.F2_std * randn (n, 1);
%
%     % Compute displacements and stresses for the random loads
%     x = [xd F]
%     z = stk_testfun_truss3_bb (x, tc.constants)
%
% REFERENCE
%
%  [1] Indraneel Das,  Nonlinear Multicriteria Optimization and Robust
%      Optimality.  PhD thesis,  Rice University,  1997.
%
%  [2] Juhani Koski,   Defectiveness of weighting method in multicriterion
%      optimization of structures.  Int. J. for Numerical Methods in
%      Biomedical Engineering,  1(6):333-337,  1985.
%
% See also: stk_testfun_truss3_vol, stk_testfun_truss3_bb

% Copyright Notice
%
%    This file: stk_testcase_truss3.m was written in 2017
%                        by Julien Bect <julien.bect@centralesupelec.fr>.
%
%    To the extent possible under law,  the author(s)  have dedicated all
%    copyright and related and neighboring rights to this file to the pub-
%    lic domain worldwide. This file is distributed without any warranty.
%
%    This work is published from France.
%
%    You should have received a copy of the  CC0 Public Domain Dedication
%    along with this file.  If not, see
%                    <http://creativecommons.org/publicdomain/zero/1.0/>.

% Copying Permission Statement (STK toolbox as a whole)
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

function tc = stk_testcase_truss3 ()

tc = struct ();

%--- Numerical constants -------------------------------------------------------

% Conversion from feet to meters
m_per_foot = 0.3048;
m_per_inch = m_per_foot / 12;

% Conversion from lbf (pound-force) to newtons (N)
N_per_lbf = 4.4482216152605;
N_per_kip = 1000 * N_per_lbf;

% Conversion from psi (pound-force per square inch) to Pa (pascals)
Pa_per_psi = N_per_lbf / (m_per_inch ^ 2);
Ps_per_ksi = 1000 * Pa_per_psi;

% Constants in Das (97)  (differs from the test case used by Koski (1985))

% Truss width
constants.D = 120 * m_per_foot;           % [m]     120 feet ~ 36.6 m

% Length of the vertical bar
constants.L =  60 * m_per_foot;           % [m]      60 feet ~ 18.3 m

% Young's modulus (steel)
constants.E = 29e3 * Ps_per_ksi;          % [Pa]    29e3 ksi ~ 200 GPa

% Minimal and maximal cross-sections
constants.a_min = 0.8 * m_per_inch ^ 2;   % [m^2]  0.8 in^2  ~  5.2 cm^2
constants.a_max = 3.0 * m_per_inch ^ 2;   % [m^2]  0.8 in^2  ~ 19.4 cm^2

% Bounds the position of the vertical bar
constants.w_min = constants.D / 4;         % [m]
constants.w_max = 3 * constants.w_min;  % [m]

% Normal distribution on the loads
constants.F1_mean =  100 * N_per_kip;
constants.F1_std  =   15 * N_per_kip;
constants.F2_mean = 1000 * N_per_kip;
constants.F2_std  =   25 * N_per_kip;

%--- Search domain (bounds on design variables) --------------------------------

a_dom = stk_hrect ( ...  % Bounds on cross-sections
    repmat ([constants.a_min; constants.a_max], 1, 3), {'a1', 'a2', 'a3'});

w_dom = stk_hrect ( ...  % Bounds on w
    [constants.w_min; constants.w_max], {'w'});

search_domain = [a_dom w_dom];

%--- Store everything inside a structure ---------------------------------------

tc.constants = constants;
tc.search_domain = search_domain;

end % function


%!shared tc, xd, n
%! tc = stk_testcase_truss3 ();  n = 5;
%! xd = stk_sampling_randunif (n, [], tc.search_domain);

%!test
%! v = stk_testfun_truss3_vol (xd, tc.constants);
%! z = stk_testfun_truss3_bb (xd, tc.constants);
%! assert (isequal (size (v), [n 1]));
%! assert (isequal (size (z), [n 5]));

%!test
%! F = stk_dataframe (zeros (n, 2), {'F1' 'F2'});
%! F(:, 1) = tc.constants.F1_mean + tc.constants.F1_std * randn (n, 1);
%! F(:, 2) = tc.constants.F2_mean + tc.constants.F2_std * randn (n, 1);
%! x = [xd F];
%! v = stk_testfun_truss3_vol (x, tc.constants);
%! z = stk_testfun_truss3_bb (x, tc.constants);
%! assert (isequal (size (v), [n 1]));
%! assert (isequal (size (z), [n 5]));
