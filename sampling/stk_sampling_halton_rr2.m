% STK_SAMPLING_HALTON_RR2 generates points from the Halton/RR2 sequence
%
% CALL: X = stk_sampling_halton_rr2(N, D)
%
%    computes the first N terms of the D-dimensional RR2-scrambled Halton
%    sequence.
%
% REFERENCE: 
%
%    Ladislav Kocis and William J. Whiten, "Computational investigations of low
%    discrepancy sequences", ACM Transactions on Mathematical Software, 
%    23(2):266-294, 1997.  http://dx.doi.org/10.1145/264029.264064
%
% SEE ALSO: stk_sampling_vdc_rr2

% Copyright Notice
%
%    Copyright  (C) 2013 Alexandra Krauth, Elham Rahali & SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Alexandra Krauth  <alexandrakrauth@gmail.com>
%               Elham Rahali      <elham.rahali@gmail.com>
 
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

function x = stk_sampling_halton_rr2 (n, d)

if nargin > 2,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

xdata = zeros (n, d);

for j = 1:d,
    xdata(:, j) = double (stk_sampling_vdc_rr2 (n, j));
end

x = stk_dataframe (xdata);

end % function stk_sampling_halton_rr2


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!error stk_sampling_halton_rr2()           % two inputs required
%!error stk_sampling_halton_rr2(10)         % two inputs required
%!error stk_sampling_halton_rr2(10, 3, -1)  % two inputs required

%!test 
%! n = 300; d = 25;
%! x = stk_sampling_halton_rr2(n, d);
%! assert(isequal(size(x), [n d]))

%!test
%! x = stk_sampling_halton_rr2(1000, 3);
%! y = x(end, :);
%! yref = [0.9052734375 0.028349336991312 0.74848];
%! assert(stk_isequal_tolrel(y, yref, 1e-13));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Comparison with Scilab+lowdisc %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Matlab/Octave STK test script
% 
% NREP = 10;
% M = 1e5;
% DIM = 20;
% 
% tic;
% for i = 1:NREP
%     x = stk_sampling_halton_rr2(M, DIM);
% end;
% t1 = toc/NREP;
% fprintf('time elapsed: %.2e seconds\n', t1);
% 
% fprintf('%.15f\n', x(1:5, 2))

% // Scilab lowdisc test script
%
% NREP = 10;
% M = 1e5;
% DIM = 20;
% 
% tic();
% for i = 1:NREP,
%     rng = lowdisc_new("halton");
%     rng = lowdisc_configure(rng, "-dimension", DIM);
%     rng = lowdisc_configure(rng, "-scrambling", "RR2");
%     rng = lowdisc_startup(rng);
%     [rng, x] = lowdisc_next(rng, M);
%     rng = lowdisc_destroy(rng);
% end
% t = toc() / NREP
% 
% mprintf('%.15f\n', x(1:9, 2))
