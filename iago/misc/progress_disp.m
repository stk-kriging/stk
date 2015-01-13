function progress_disp(msg, n, N)

persistent revmsg
if n == 1
	revmsg = []; end
msg = sprintf('%s .. %d/%d', msg, n, N);
fprintf([revmsg, msg]);
revmsg = repmat(sprintf('\b'), 1, length(msg));

if n==N
	fprintf('\n'); end

end