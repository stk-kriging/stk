% -*- texinfo -*-
% @deftypefn  {Function File} {[@var{x}, @var{obj}, @var{info}, @var{iter}, @var{nf}, @var{lambda}] =} sqp (@var{x0}, @var{phi})
% @deftypefnx {Function File} {[@dots{}] =} sqp (@var{x0}, @var{phi}, @var{g})
% @deftypefnx {Function File} {[@dots{}] =} sqp (@var{x0}, @var{phi}, @var{g}, @var{h})
% @deftypefnx {Function File} {[@dots{}] =} sqp (@var{x0}, @var{phi}, @var{g}, @var{h}, @var{lb}, @var{ub})
% @deftypefnx {Function File} {[@dots{}] =} sqp (@var{x0}, @var{phi}, @var{g}, @var{h}, @var{lb}, @var{ub}, @var{maxiter})
% @deftypefnx {Function File} {[@dots{}] =} sqp (@var{x0}, @var{phi}, @var{g}, @var{h}, @var{lb}, @var{ub}, @var{maxiter}, @var{tol})
% Minimize an objective function using sequential quadratic programming (SQP).
%
% Solve the nonlinear program
% @tex
% $$
% \min_x \phi (x)
% $$
% @end tex
% @ifnottex
%
% @example
% @group
% min phi (x)
%  x
% @end group
% @end example
%
% @end ifnottex
% subject to
% @tex
% $$
%  g(x) = 0 \qquad h(x) \geq 0 \qquad lb \leq x \leq ub
% $$
% @end tex
% @ifnottex
%
% @example
% @group
% g(x)  = 0
% h(x) >= 0
% lb <= x <= ub
% @end group
% @end example
%
% @end ifnottex
% @noindent
% using a sequential quadratic programming method.
%
% The first argument is the initial guess for the vector @var{x0}.
%
% The second argument is a function handle pointing to the objective function
% @var{phi}.  The objective function must accept one vector argument and
% return a scalar.
%
% The second argument may also be a 2- or 3-element cell array of function
% handles.  The first element should point to the objective function, the
% second should point to a function that computes the gradient of the
% objective function, and the third should point to a function that computes
% the Hessian of the objective function.  If the gradient function is not
% supplied, the gradient is computed by finite differences.  If the Hessian
% function is not supplied, a BFGS update formula is used to approximate the
% Hessian.
%
% When supplied, the gradient function @code{@var{phi}@{2@}} must accept one
% vector argument and return a vector.  When supplied, the Hessian function
% @code{@var{phi}@{3@}} must accept one vector argument and return a matrix.
%
% The third and fourth arguments @var{g} and @var{h} are function handles
% pointing to functions that compute the equality constraints and the
% inequality constraints, respectively.  If the problem does not have
% equality (or inequality) constraints, then use an empty matrix ([]) for
% @var{g} (or @var{h}).  When supplied, these equality and inequality
% constraint functions must accept one vector argument and return a vector.
%
% The third and fourth arguments may also be 2-element cell arrays of
% function handles.  The first element should point to the constraint
% function and the second should point to a function that computes the
% gradient of the constraint function:
% @tex
% $$
%  \Bigg( {\partial f(x) \over \partial x_1},
%         {\partial f(x) \over \partial x_2}, \ldots,
%         {\partial f(x) \over \partial x_N} \Bigg)^T
% $$
% @end tex
% @ifnottex
%
% @example
% @group
%             [ d f(x)   d f(x)        d f(x) ]
% transpose ( [ ------   -----   ...   ------ ] )
%             [  dx_1     dx_2          dx_N  ]
% @end group
% @end example
%
% @end ifnottex
% The fifth and sixth arguments, @var{lb} and @var{ub}, contain lower and
% upper bounds on @var{x}.  These must be consistent with the equality and
% inequality constraints @var{g} and @var{h}.  If the arguments are vectors
% then @var{x}(i) is bound by @var{lb}(i) and @var{ub}(i).  A bound can also
% be a scalar in which case all elements of @var{x} will share the same
% bound.  If only one bound (lb, ub) is specified then the other will
% default to (-@var{realmax}, +@var{realmax}).
%
% The seventh argument @var{maxiter} specifies the maximum number of
% iterations.  The default value is 100.
%
% The eighth argument @var{tol} specifies the tolerance for the stopping
% criteria.  The default value is @code{sqrt (eps)}.
%
% The value returned in @var{info} may be one of the following:
%
% @table @asis
% @item 101
% The algorithm terminated normally.
% All constraints meet the specified tolerance.
%
% @item 102
% The BFGS update failed.
%
% @item 103
% The maximum number of iterations was reached.
%
% @item 104
% The stepsize has become too small, i.e.,
% @tex
% $\Delta x,$
% @end tex
% @ifnottex
% delta @var{x},
% @end ifnottex
% is less than @code{@var{tol} * norm (x)}.
% @end table
%
% An example of calling @code{sqp}:
%
% @example
% function r = g (x)
%   r = [ sum(abs(x).^2)-10;
%         x(2)*x(3)-5*x(4)*x(5);
%         x(1)^3+x(2)^3+1 ];
% end % function
%
% function obj = phi (x)
%   obj = exp (prod (x)) - 0.5*(x(1)^3+x(2)^3+1)^2;
% end % function
%
% x0 = [-1.8; 1.7; 1.9; -0.8; -0.8];
%
% [x, obj, info, iter, nf, lambda] = sqp (x0, @@phi, @@g, [])
%
% x =
%
%   -1.71714
%    1.59571
%    1.82725
%   -0.76364
%   -0.76364
%
% obj = 0.053950
% info = 101
% iter = 8
% nf = 10
% lambda =
%
%   -0.0401627
%    0.0379578
%   -0.0052227
% @end example
%
% @seealso{qp}
% @end deftypefn

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>
%
%    This file is based on Octave's sqp function (distributed under the
%    GPLv3 licence) with minor modifications to be usable under Matlab.
%    The original copyright notice is as follows:
%
%       Copyright (C) 2005-2015 John W. Eaton
%       Copyright (C) 2013-2015 Arun Giridhar

% Copying Permission Statement
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

% Original Copying Permission Statement
%
%    This file is part of Octave.
%
%    Octave is free software; you can redistribute it and/or modify it
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 3 of the License, or (at
%    your option) any later version.
%
%    Octave is distributed in the hope that it will be useful, but
%    WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with Octave; see the file COPYING.  If not, see
%    <http://www.gnu.org/licenses/>.

function [x, obj, info, iter, nf, lambda] = sqp_quadprog ...
    (x0, objf, cef, cif, lb, ub, maxiter, tolerance)

  globals = struct (); % data and handles, needed and changed by subfunctions

  if (nargin < 2 || nargin > 8 || nargin == 5)
    print_usage ();
  end % if

  if (~ isvector (x0))
    error ('sqp: X0 must be a vector');
  end % if
  if (size (x0, 1) == 1)
    x0 = x0';
  end % if

  have_hess = 0;
  if (iscell (objf))
    switch (numel (objf))
      case 1
        obj_fun = objf{1};
        obj_grd = @(x) fd_obj_grd (x, obj_fun);
      case 2
        obj_fun = objf{1};
        obj_grd = objf{2};
      case 3
        obj_fun = objf{1};
        obj_grd = objf{2};
        obj_hess = objf{3};
        have_hess = 1;
      otherwise
        error ('sqp: invalid objective function specification');
    end % switch
  else
    obj_fun = objf;   % No cell array, only obj_fun set
    obj_grd = @(x) fd_obj_grd (x, obj_fun);
  end % if

  ce_fun = @empty_cf;
  ce_grd = @empty_jac;
  if (nargin > 2)
    if (iscell (cef))
      switch (numel (cef))
        case 1
          ce_fun = cef{1};
          ce_grd = @(x) fd_ce_jac (x, ce_fun);
        case 2
          ce_fun = cef{1};
          ce_grd = cef{2};
        otherwise
          error ('sqp: invalid equality constraint function specification');
      end % switch
    elseif (~ isempty (cef))
      ce_fun = cef;   % No cell array, only constraint equality function set
      ce_grd = @(x) fd_ce_jac (x, ce_fun);
    end % if
  end % if

  ci_fun = @empty_cf;
  ci_grd = @empty_jac;
  if (nargin > 3)
    % constraint function given by user with possible gradient
    globals.cif = cif;
    % constraint function given by user without gradient
    globals.cifcn = @empty_cf;
    if (iscell (cif))
      if (~ isempty (cif))
        globals.cifcn = cif{1};
      end % if
    elseif (~ isempty (cif))
      globals.cifcn = cif;
    end % if

    if (nargin < 5 || (nargin > 5 && isempty (lb) && isempty (ub)))
      % constraint inequality function only without any bounds
      ci_grd = @(x) fd_ci_jac (x, globals.cifcn);
      if (iscell (cif))
        switch (length (cif))
          case 1
            ci_fun = cif{1};
          case 2
            ci_fun = cif{1};
            ci_grd = cif{2};
          otherwise
           error ('sqp: invalid inequality constraint function specification');
        end % switch
      elseif (~ isempty (cif))
        ci_fun = cif;   % No cell array, only constraint inequality function set
      end % if
    else
      % constraint inequality function with bounds present
      ub_idx = true (size (x0));  lb_idx = ub_idx;
      lb_grad = eye (size (x0, 1));  ub_grad = - lb_grad;
      if (isvector (lb))
        tmp_lb = lb(:);  globals.lb = tmp_lb;
        tmp_idx = (lb ~= -Inf);  lb_idx(:) = tmp_idx;
        globals.lb = globals.lb(tmp_idx, 1);
        lb_grad = lb_grad(lb_idx, :);
      elseif (isempty (lb))
        if (isa (x0, 'single'))
          tmp_lb = - realmax ('single');  globals.lb = tmp_lb;
        else
          tmp_lb = -realmax;  globals.lb = tmp_lb;
        end % if
      else
        error ('sqp: invalid lower bound');
      end % if

      if (isvector (ub))
        tmp_ub = ub(:);  globals.ub = tmp_ub;
        tmp_idx = (ub ~= Inf);  ub_idx(:) = tmp_idx;
        globals.ub = globals.ub(tmp_idx, 1);
        ub_grad = ub_grad(ub_idx, :);
      elseif (isempty (ub))
        if (isa (x0, 'single'))
          tmp_ub = realmax ('single');  globals.ub = tmp_ub;
        else
          tmp_ub = realmax;  globals.ub = tmp_ub;
        end % if
      else
        error ('sqp: invalid upper bound');
      end % if

      if (any (tmp_lb > tmp_ub))
        error ('sqp: upper bound smaller than lower bound');
      end % if
      bounds_grad = [lb_grad; ub_grad];
      ci_fun = @(x) cf_ub_lb (x, lb_idx, ub_idx, globals);
      ci_grd = @(x) cigrad_ub_lb (x, bounds_grad, globals);
    end % if

  end % if   % if (nargin > 3)

  iter_max = 100;
  if (nargin > 6 && ~ isempty (maxiter))
    if (isscalar (maxiter) && maxiter > 0 && fix (maxiter) == maxiter)
      iter_max = maxiter;
    else
      error ('sqp: invalid number of maximum iterations');
    end % if
  end % if

  tol = sqrt (eps);
  if (nargin > 7 && ~ isempty (tolerance))
    if (isscalar (tolerance) && tolerance > 0)
      tol = tolerance;
    else
      error ('sqp: invalid value for TOLERANCE');
    end % if
  end % if

  % Initialize variables for search loop
  % Seed x with initial guess and evaluate objective function, constraints,
  % and gradients at initial value x0.
  %
  % obj_fun   -- objective function
  % obj_grad  -- objective gradient
  % ce_fun    -- equality constraint functions
  % ci_fun    -- inequality constraint functions
  % A == [grad_{x_1} cx_fun, grad_{x_2} cx_fun, ..., grad_{x_n} cx_fun]^T
  x = x0;

  obj = feval (obj_fun, x0);
  globals.nfun = 1;

  c = feval (obj_grd, x0);

  % Choose an initial NxN symmetric positive definite Hessian approximation B.
  n = length (x0);
  if (have_hess)
    B = feval (obj_hess, x0);
  else
    B = eye (n, n);
  end % if

  ce = feval (ce_fun, x0);
  F = feval (ce_grd, x0);

  ci = feval (ci_fun, x0);
  C = feval (ci_grd, x0);

  A = [F; C];

  % Choose an initial lambda (x is provided by the caller).
  lambda = 100 * ones (size (A, 1), 1);

  qp_iter = 1;
  alpha = 1;

  info = 0;
  % report ();  % Called with no arguments to initialize reporting
  % report (iter, qp_iter, alpha, __sqp_nfun__, obj);

  for iter = 1:iter_max  % FIXME in Octave -> shift by one (check iter_max = 1) ???

    % Check convergence.  This is just a simple check on the first
    % order necessary conditions.
    nr_f = size (F, 1);

    lambda_e = lambda((1:nr_f)');
    lambda_i = lambda((nr_f+1:end)');

    con = [ce; ci];

    t0 = norm (c - A' * lambda);
    t1 = norm (ce);
    t2 = all (ci >= 0);
    t3 = all (lambda_i >= 0);
    t4 = norm (lambda .* con);

    % Normal convergence.  All constraints are satisfied
    % and objective has converged.
    if (t2 && t3 && max ([t0; t1; t4]) < tol)
      info = 101;
      break;
    end % if

    % Compute search direction p by solving QP.
    g = -ce;
    d = -ci;
    
    % [p, obj_qp, INFO, lambda] = qp (x, B, c, F, g, [], [], d, C, ...
    %                                 Inf (size (d)));
    
    B = 0.5 * (B + B');  % Prevents quadprog warning

    % Matlab's quadprog issues a warning when changing its default solver,
    % but we don't want to see that in the output of sqp.
    ws = warning ('off', 'all');

    try
        % Call quadprog to solve the QP subproblem
        quadprog_options = optimset ('Display', 'off');
        [p, ~, quadprog_exitflag, ~, lambda] = quadprog ...
            (B, c, -C, -d, F, g, [], [], x, quadprog_options);
    catch
        warning (ws);
        rethrow (lasterror ());
    end
    
    warning (ws);

    % Recreate a vector of Lagrange multipliers similar to qp's one
    lambda = [- lambda.eqlin; lambda.ineqlin];
    
    % VERY crude processing of quadprog_exitflag
    if quadprog_exitflag <= 0
        error ('quadprog failed to solve QP subproblem');
    end
    
    % info = INFO.info;
    %
    % % FIXME: check QP solution and attempt to recover if it has failed.
    % %        For now, just warn about possible problems.
    %
    % id = 'Octave:SQP-QP-subproblem';
    % switch (info)
    %   case 2
    %     warning (id, 'sqp: QP subproblem is non-convex and unbounded');
    %   case 3
    %     warning (id, 'sqp: QP subproblem failed to converge in %d iterations', ...
    %              INFO.solveiter);
    %   case 6
    %     warning (id, 'sqp: QP subproblem is infeasible');
    % end % switch

    % Choose mu such that p is a descent direction for the chosen
    % merit function phi.
    [x_new, alpha, obj_new, globals] = ...
        linesearch_L1 (x, p, obj_fun, obj_grd, ce_fun, ci_fun, lambda, ...
                       obj, globals);

    % Evaluate objective function, constraints, and gradients at x_new.
    c_new = feval (obj_grd, x_new);

    ce_new = feval (ce_fun, x_new);
    F_new = feval (ce_grd, x_new);

    ci_new = feval (ci_fun, x_new);
    C_new = feval (ci_grd, x_new);

    A_new = [F_new; C_new];

    % Set
    %
    % s = alpha * p
    % y = grad_x L (x_new, lambda) - grad_x L (x, lambda})

    y = c_new - c;

    if (~ isempty (A))
      t = ((A_new - A)'*lambda);
      y = y - t;
    end % if

    delx = x_new - x;

    % Check if step size has become too small (indicates lack of progress).
    if (norm (delx) < tol * norm (x))
      info = 104;
      break;
    end % if

    if (have_hess)

      B = feval (obj_hess, x);

    else
      % Update B using a quasi-Newton formula.
      delxt = delx';

      % Damped BFGS.  Or maybe we would actually want to use the Hessian
      % of the Lagrangian, computed directly?
      d1 = delxt*B*delx;

      t1 = 0.2 * d1;
      t2 = delxt*y;

      if (t2 < t1)
        theta = 0.8*d1/(d1 - t2);
      else
        theta = 1;
      end % if

      r = theta*y + (1-theta)*B*delx;

      d2 = delxt*r;

      % Check if the next BFGS update will work properly.
      % If d1 or d2 vanish, the BFGS update will fail.
      if (d1 == 0 || d2 == 0)
        info = 102;
        break;
      end % if

      B = B - B*delx*delxt*B/d1 + r*r'/d2;

    end % if

    x = x_new;

    obj = obj_new;

    c = c_new;

    ce = ce_new;
    F = F_new;

    ci = ci_new;
    C = C_new;

    A = A_new;

    % report (iter, qp_iter, alpha, __sqp_nfun__, obj);
    
  end % for

  % Check if we've spent too many iterations without converging.
  if (iter >= iter_max)
    info = 103;
  end % if

  nf = globals.nfun;

end % function


function [merit, obj, globals] = phi_L1 (obj, obj_fun, ce_fun, ci_fun, ...
                                         x, mu, globals)

  ce = feval (ce_fun, x);
  ci = feval (ci_fun, x);

  idx = ci < 0;

  con = [ce; ci(idx)];

  if (isempty (obj))
    obj = feval (obj_fun, x);
    globals.nfun = globals.nfun + 1;
  end % if

  merit = obj;
  t = norm (con, 1) / mu;

  if (~ isempty (t))
    merit = merit + t;
  end % if

end % function


function [x_new, alpha, obj, globals] = ...
      linesearch_L1 (x, p, obj_fun, obj_grd, ce_fun, ci_fun, lambda, ...
                     obj, globals)

  % Choose parameters
  %
  % eta in the range (0, 0.5)
  % tau in the range (0, 1)

  eta = 0.25;
  tau = 0.5;

  delta_bar = sqrt (eps);

  if (isempty (lambda))
    mu = 1 / delta_bar;
  else
    mu = 1 / (norm (lambda, Inf) + delta_bar);
  end % if

  alpha = 1;

  c = feval (obj_grd, x);
  ce = feval (ce_fun, x);

  [phi_x_mu, obj, globals] = phi_L1 (obj, obj_fun, ce_fun, ci_fun, x, ...
                                     mu, globals);

  D_phi_x_mu = c' * p;
  d = feval (ci_fun, x);
  % only those elements of d corresponding
  % to violated constraints should be included.
  idx = d < 0;
  t = - norm ([ce; d(idx)], 1) / mu;
  if (~ isempty (t))
    D_phi_x_mu = D_phi_x_mu + t;
  end % if

  while (1)
    [p1, obj, globals] = phi_L1 ([], obj_fun, ce_fun, ci_fun, ...
                                 x+alpha*p, mu, globals);
    p2 = phi_x_mu+eta*alpha*D_phi_x_mu;
    if (p1 > p2)
      % Reset alpha = tau_alpha * alpha for some tau_alpha in the
      % range (0, tau).
      tau_alpha = 0.9 * tau;  % ??
      alpha = tau_alpha * alpha;
    else
      break;
    end % if
  end % while

  x_new = x + alpha * p;

end % function


function grd = fdgrd (f, x)

  if (~ isempty (f))
    y0 = feval (f, x);
    nx = length (x);
    grd = zeros (nx, 1);
    deltax = sqrt (eps);
    for i = 1:nx
      t = x(i);
      x(i) = x(i) + deltax;
      grd(i) = (feval (f, x) - y0) / deltax;
      x(i) = t;
    end % for
  else
    grd = zeros (0, 1);
  end % if

end % function


function jac = fdjac (f, x)

  nx = length (x);
  if (~ isempty (f))
    y0 = feval (f, x);
    nf = length (y0);
    nx = length (x);
    jac = zeros (nf, nx);
    deltax = sqrt (eps);
    for i = 1:nx
      t = x(i);
      x(i) = x(i) + deltax;
      jac(:,i) = (feval (f, x) - y0) / deltax;
      x(i) = t;
    end % for
  else
    jac = zeros  (0, nx);
  end % if

end % function


function grd = fd_obj_grd (x, obj_fun)

  grd = fdgrd (obj_fun, x);

end % function


function res = empty_cf (x)

  res = zeros (0, 1);

end % function


function res = empty_jac (x)

  res = zeros (0, length (x));

end % function


function jac = fd_ce_jac (x, ce_fun)

  jac = fdjac (ce_fun, x);

end % function


function jac = fd_ci_jac (x, cifcn)

  % cifcn = constraint function without gradients and lb or ub
  jac = fdjac (cifcn, x);

end % function


function res = cf_ub_lb (x, lbidx, ubidx, globals)

  % combine constraint function with ub and lb
  if (isempty (globals.cifcn))
    res = [x(lbidx,1)-globals.lb; globals.ub-x(ubidx,1)];
  else
    res = [feval(globals.cifcn,x); x(lbidx,1)-globals.lb;
           globals.ub-x(ubidx,1)];
  end % if

end % function


function res = cigrad_ub_lb (x, bgrad, globals)

  cigradfcn = @(x) fd_ci_jac (x, globals.cifcn);

  if (iscell (globals.cif) && length (globals.cif) > 1)
    cigradfcn = globals.cif{2};
  end % if

  if (isempty (cigradfcn))
    res = bgrad;
  else
    res = [feval(cigradfcn,x); bgrad];
  end % if

end % function

% Utility function used to debug sqp
function report (iter, qp_iter, alpha, nfun, obj)

  if (nargin == 0)
    printf ('  Itn ItQP     Step  Nfun     Objective\n');
  else
    printf ('%5d %4d %8.1g %5d %13.6e\n', iter, qp_iter, alpha, nfun, obj);
  end % if

end % function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test Code

%!test if (exist ('quadprog', 'file') == 2)
%! 
%! x0 = [-1.8; 1.7; 1.9; -0.8; -0.8];
%!
%! [x, obj, info, iter, nf, lambda] = sqp_quadprog ...
%!    (x0, @sqp_quadprog_testf, @sqp_quadprog_testg, []);
%!
%! x_opt = [-1.717143501952599;
%!           1.595709610928535;
%!           1.827245880097156;
%!          -0.763643103133572;
%!          -0.763643068453300];
%!
%! obj_opt = 0.0539498477702739;
%!
%! assert (stk_isequal_tolrel (x, x_opt, 8 * sqrt (eps)));
%! assert (stk_isequal_tolrel (obj, obj_opt, sqrt (eps)));
%!
%! end

% Test input validation
%!error sqp_quadprog ()
%!error sqp_quadprog (1)
%!error sqp_quadprog (1,2,3,4,5,6,7,8,9)
%!error sqp_quadprog (1,2,3,4,5)
%!error sqp_quadprog (ones (2,2))
%!error sqp_quadprog (1, cell (4,1))
%!error sqp_quadprog (1, cell (3,1), cell (3,1))
%!error sqp_quadprog (1, cell (3,1), cell (2,1), cell (3,1))
%!error sqp_quadprog (1, cell (3,1), cell (2,1), cell (2,1), ones (2,2),[])
%!error sqp_quadprog (1, cell (3,1), cell (2,1), cell (2,1),[], ones (2,2))
%!error sqp_quadprog (1, cell (3,1), cell (2,1), cell (2,1),1,-1)
%!error sqp_quadprog (1, cell (3,1), cell (2,1), cell (2,1),[],[], ones (2,2))
%!error sqp_quadprog (1, cell (3,1), cell (2,1), cell (2,1),[],[],-1)
%!error sqp_quadprog (1, cell (3,1), cell (2,1), cell (2,1),[],[],1.5)
%!error sqp_quadprog (1, cell (3,1), cell (2,1), cell (2,1),[],[],[], ones (2,2))
%!error sqp_quadprog (1, cell (3,1), cell (2,1), cell (2,1),[],[],[],-1)

%#ok<*NASGU> 
