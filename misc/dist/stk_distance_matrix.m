% STK_DISTANCE_MATRIX...
%
% FIXME: missing doc, copyright, ...

%%
% Check that an error is raised in nargin is not either 1 or 2

%!error stk_distance_matrix();
%!error stk_distance_matrix(0, 0, 0);
%!error stk_distance_matrix(0, 0, 0, 0);

%%
% Check that an error is raised when the number of columns differs

%!error stk_distance_matrix(0, ones(1, 2));
%!error stk_distance_matrix(eye(3), ones(1, 2));
%!error stk_distance_matrix(ones(2, 1), zeros(2));

%%
% Test with some simple matrices

%!shared x, y, z
%! x = zeros(11, 5);
%! y = zeros(13, 5);
%! z = ones(7, 5);

%!test
%! Dx = stk_distance_matrix(x);
%! assert(isequal(Dx, zeros(11)));

%!test
%! Dxx = stk_distance_matrix(x, x);
%! assert(isequal(Dxx, zeros(11)));

%!test
%! Dxy = stk_distance_matrix(x, y);
%! assert(isequal(Dxy, zeros(11, 13)));

%!test
%! Dzz = stk_distance_matrix(z, z);
%! assert(isequal(Dzz, zeros(7)));

%!test
%! Dxz = stk_distance_matrix(x, z);
%! assert(isequal(Dxz, sqrt(5)*ones(11, 7)));
