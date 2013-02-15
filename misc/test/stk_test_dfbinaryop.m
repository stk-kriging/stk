function stk_test_dfbinaryop(F, a1, a2)

x1  = stk_dataframe(a1);
x2  = stk_dataframe(a2);
res = F(a1, a2);

x3 = F(x1, x2);
assert(isa(x3, 'stk_dataframe') && isequal(double(x3), res));

x3 = F(x1, a2);
assert(isa(x3, 'stk_dataframe') && isequal(double(x3), res));

x3 = F(a1, a2);
assert(isequal(x3, res));

end % function stk_test_dfbinaryop
