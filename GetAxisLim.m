function [xlim, ylim] = GetAxisLim(dn, ax)
% 根据数据size和spacing来设置坐标的轴的范围


if isempty(ax.UserData)
	ax.UserData = [dn.Origin; dn.EndPoint; dn.Spacing];
else
	ax.UserData(1,:) = min(dn.Origin, ax.UserData(1,:));
	ax.UserData(2,:) = max(dn.EndPoint, ax.UserData(2,:));
	ax.UserData(3,:) = min(dn.Spacing, ax.UserData(3,:));
end
a = ax.UserData(1,:);
b = ax.UserData(2,:);
r = b - a;
if strcmp(ax.Tag, 'Axes1') % Axes1
	if r(1) > r(2)
		xlim = [(a(2) + b(2) - r(1)) / 2 , (a(2) + b(2) + r(1)) / 2];
		ylim = [a(1), b(1)];
	elseif r(1) < r(2)
		xlim = [a(2), b(2)];
		ylim = [(a(1) + b(1) - r(2)) / 2 , (a(1) + b(1) + r(2)) / 2];
	elseif r(1) == r(2)
		xlim = [a(2), b(2)];
		ylim = [a(1), b(1)];
	end
elseif strcmp(ax.Tag, 'Axes2') % Axes2
	if r(1) > r(3)
		xlim = [(a(3) + b(3) - r(1)) / 2 , (a(3) + b(3) + r(1)) / 2];
		ylim = [a(1), b(1)];
	elseif r(1) < r(3)
		xlim = [a(3), b(3)];
		ylim = [(a(1) + b(1) - r(3)) / 2 , (a(1) + b(1) + r(3)) / 2];
	elseif r(1) == r(3)
		xlim = [a(3), b(3)];
		ylim = [a(1), b(1)];
	end
elseif strcmp(ax.Tag, 'Axes3') % Axes3
	if r(2) > r(3)
		xlim = [(a(3) + b(3) - r(2)) / 2 , (a(3) + b(3) + r(2)) / 2];
		ylim = [a(2), b(2)];
	elseif r(2) < r(3)
		xlim = [a(3), b(3)];
		ylim = [(a(2) + b(2) - r(3)) / 2 , (a(2) + b(2) + r(3)) / 2];
	elseif r(2) == r(3)
		xlim = [a(3), b(3)];
		ylim = [a(2), b(2)];
	end
end

end
