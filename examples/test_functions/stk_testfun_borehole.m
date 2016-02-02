% STK_TESTFUN_BOREHOLE computes the "borehole model" response function
%
% CALL: Y = stk_testfun_borehole (X)
%
%    computes the responses Y(i, :) of the "borehole model" [1-3] for the
%    input vectors X(i, :).
%
%    The output Y is the water flow rate through the borehole (m3/yr).
%
%    The input variables (columns of X) are:
%
%       X(:, 1) = rw   radius of borehole (m),
%       X(:, 2) = r    radius of influence (m),
%       X(:, 3) = Tu   transmissivity of upper aquifer (m2/yr),
%       X(:, 4) = Hu   potentiometric head of upper aquifer (m),
%       X(:, 5) = Tl   transmissivity of lower aquifer (m2/yr),
%       X(:, 6) = Hl   potentiometric head of lower aquifer (m),
%       X(:, 7) = L    length of borehole (m),
%       X(:, 8) = Kw   hydraulic conductivity of borehole (m/yr),
%
%    and their usual domain of variation is:
%
%       input_domain = stk_hrect ([                                  ...
%           0.05    100   63070    990   63.1    700  1120   9855;   ...
%           0.15  50000  115600   1110  116.0    820  1680  12045],  ...
%          {'rw',  'r',    'Tu',  'Hu',  'Tl',  'Hl',  'L',  'Kw'})
%
% REFERENCES
%
%  [1] Harper, W. V. & Gupta, S. K. (1983).  Sensitivity/uncertainty analysis
%      of a borehole scenario comparing Latin Hypercube Sampling and determinis-
%      tic sensitivity approaches.  Technical report BMI/ONWI-516,  Battelle
%      Memorial Inst., Office of Nuclear Waste Isolation, Columbus, OH (USA).
%
%  [2] Morris, M. D., Mitchell, T. J. & Ylvisaker, D. (1993).  Bayesian design
%      and analysis of computer experiments: use of derivatives in surface
%      prediction.  Technometrics, 35(3):243-255.
%
%  [3] Surjanovic, S. & Bingham, D.  Virtual Library of Simulation Experiments:
%      Test Functions and Datasets.  Retrieved February 1, 2016, from
%      http://www.sfu.ca/~ssurjano/borehole.html. 

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>
%
%    Based on the "Virtual Library for Simulation Experiments"
%       Copyright (C) 2013 Derek Bingham, Simon Fraser University
%       Authors: Sonja Surjanovic & Derek Bingham (dbingham@stat.sfu.ca)
%       Distributed under the GPLv2 licence
%       http://www.sfu.ca/~ssurjano/Code/borehole.html

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

function y = stk_testfun_borehole (x)

x = double (x);

rw = x(:, 1);
r  = x(:, 2);
Tu = x(:, 3);
Hu = x(:, 4);
Tl = x(:, 5);
Hl = x(:, 6);
L  = x(:, 7);
Kw = x(:, 8);

A = 2 * pi * Tu .* (Hu - Hl);
B = 2 * L .* Tu ./ ((log (r ./ rw)) .* (rw .^ 2) .* Kw);
C = Tu ./ Tl;
D = (log (r ./ rw)) .* (1 + B + C);

y = A ./ D;

end % function
