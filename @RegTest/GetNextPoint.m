function xnew = GetNextPoint(xk, dk)
% Armijo 一维非精确搜索

beta = 0.5;
sigma = 0.2;
m = 0;
mmax = 200;
while m <= mmax
	if fun(xk + beta^m * dk) <= fun(xk) + sigma * beta^m * gfun(xk)' * dk
		mk = m;
		break;
	end
	m = m + 1;
end

xnew = xk + beta^mk * dk;

end
