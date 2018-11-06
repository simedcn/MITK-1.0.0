function [xlim, ylim] = GetAxisLim(dn, n)
% 根据数据size和spacing来设置坐标的轴的范围

s = dn.Size;
p = dn.Spacing;
r = s .* p;


if n == 1 % Axes1
	if r(1) > r(2)
		t = round(r(1) / p(2));
		xlim = [0.5 - (t - s(2)) / 2 , 0.5 + (t + s(2)) / 2];
		ylim = [-0.5, s(1) + 1.5];
	elseif r(1) < r(2)
		t = round(r(2) / p(1));
		xlim = [-0.5, s(2) + 1.5];
		ylim = [0.5 - (t - s(1)) / 2 , 0.5 + (t + s(1)) / 2];
	elseif r(1) == r(2)
		xlim = [-0.5, s(2) + 1.5];
		ylim = [-0.5, s(1) + 1.5];
	end
elseif n == 2 % Axes2
	if r(1) > r(3)
		t = round(r(1) / p(3));
		xlim = [0.5 - (t - s(3)) / 2 , 0.5 + (t + s(3)) / 2];
		ylim = [-0.5, s(1) + 1.5];
	elseif r(1) < r(3)
		t = round(r(3) / p(1));
		xlim = [-0.5, s(3) + 1.5];
		ylim = [0.5 - (t - s(1)) / 2 , 0.5 + (t + s(1)) / 2];
	elseif r(1) == r(3)
		xlim = [-0.5, s(3) + 1.5];
		ylim = [-0.5, s(1) + 1.5];
	end
elseif n == 3 % Axes3
	if r(2) > r(3)
		t = round(r(2) / p(3));
		xlim = [0.5 - (t - s(3)) / 2 , 0.5 + (t + s(3)) / 2];
		ylim = [-0.5, s(2) + 1.5];
	elseif r(2) < r(3)
		t = round(r(3) / p(2));
		xlim = [-0.5, s(3) + 1.5];
		ylim = [0.5 - (t - s(2)) / 2 , 0.5 + (t + s(2)) / 2];
	elseif r(2) == r(3)
		xlim = [-0.5, s(3) + 1.5];
		ylim = [-0.5, s(2) + 1.5];
	end
end

end
