% STK_QUADRATURE computes a quadrature
%
% CALL: stk_quadrature()
%
% STK_QUADRATURE computes a quadrature among several types

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec & Ivana Aleksovska
%
%    Authors:  Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function out = stk_quadrature(state, algo, varargin)

switch state
    case 0, % init
        quadtype  = varargin{1};
        quadorder = varargin{2};
        switch quadtype
            case 'GH',
                n = quadorder;
                H = zeros(n+1, n+1);
                H(1, 1)   = [1];
                H(2, 1:2) = [0 2];
                for i=3:(n+1)
                    t0 = -2*(i-2)*H(i-2, :);
                    t1 = 2 * conv(H(i-1,:), [0 1]);
                    t1 = t1(1:n+1);
                    H(i, :) = t1 + t0;
                end
                Hn          = fliplr(H(n+1,:));
                Hnminusone  = fliplr(H(n,:));
                algo.zQ = sort(roots(Hn));
                algo.wQ = 2^(n-1)*factorial(n)*sqrt(pi)/n^2./polyval(Hnminusone, algo.zQ).^2;
            case 'Linear',
                step = 1/quadorder;
                u0 = step/2:step:(1-step/2);
                zQ = -sqrt(2)*erfcinv(2*u0); % zQ = norminv(u0);
                algo.zQ = zQ(:);
                algo.wQ = step*ones(algo_obj.Q, 1);
            case 'T',
                step = 1/quadorder;
                u0 = step/2:step:(1-step/2);
                u1 = tanh(7*(u0-0.5)) / 2 + 0.5;
                zQ = -sqrt(2)*erfcinv(2*u1);
                algo.zQ = zQ(:);
                u2 = [0, u1(1:end-1) + (u1(2:end) - u1(1:end-1))/2, 1];
                wQ = diff(u2);
                algo.wQ = wQ(:);
        end
        out = algo;
        
    case 1, % compute quadrature points
        m = varargin{1};
        v = varargin{2};
        switch algo.quadtype
            case 'GH',
                zQ = m + sqrt(2*v) * algo.zQ;
            case {'Linear', 'T'},
                zQ = m + sqrt(v) * algo.zQ;
        end
        out = zQ;
        
    case 2, % compute quadrature
        losscrit = varargin{1};
        switch algo.quadtype
            case 'GH',
                samplingcrit = 1/sqrt(pi) * sum(algo.wQ.*losscrit);
            case 'Linear',
                samplingcrit = algo.wQ(1) * sum(losscrit);
            case 'T',
                samplingcrit = sum(algo.wQ.*losscrit);
        end
        out = samplingcrit;
end
end