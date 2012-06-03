% STK_MINDIST ...
%
% FIXME: missing doc, copyright, ...

%% 
% Check that sk_mindist(x) is empty when x has zero lines

%!test
%! for nc = [0 5 10],
%!   x = zeros(0, nc);
%!   d = stk_mindist(x);
%!   assert(isempty(d));
%! end

%% 
% Check that sk_mindist(x) is empty when x has only one line.

%!test
%! for nc = [0 5 10],
%!   x = rand(1, nc);
%!   d = stk_mindist(x);
%!   assert(isempty(d));
%! end

%%
% Check that sk_mindist(x) is 0.0 when x has 0 columns (but at least 2 lines)

%!test
%! for nr = [2 5 10],
%!   x = zeros(nr, 0);
%!   d = stk_mindist(x);
%!   assert(isequal(d, 0.0));
%! end

%% 
% Random matrices with at least 2 lines and 1 column

%!test
%! 
%! nrep = 20;
%! TOL_REL = 1e-15;
%! 
%! for irep = 1:nrep,
%! 
%!     n = 2 + floor(rand * 10);
%!     d = 1 + floor(rand * 10);
%!     x = rand(n, d);       
%!     z = stk_mindist(x);
%!        
%!     assert(isequal(size(d), [1, 1]));
%!     assert(~isnan(d));
%!     assert(~isinf(d));
%!     
%!     % check the result
%!     mindist = Inf;
%!     for i = 1:(n-1),
%!         for j = (i+1):n,
%!             mindist = min(mindist, norm(x(i,:) - x(j,:)));
%!         end
%!     end
%!     assert(abs(z - mindist) <= TOL_REL * mindist);
%!     
%! end
