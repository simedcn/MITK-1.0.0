function [xlim, ylim] = GetAxisLim(dn, ax)
% ��������size��spacing�������������ķ�Χ

% s = dn.Size;
% p = dn.Spacing;
% r = s .* p;
% o = dn.Origin;
% e = dn.EndPoint;

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

return

if strcmp(ax.Tag, 'Axes1') % Axes1
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
elseif strcmp(ax.Tag, 'Axes2') % Axes2
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
elseif strcmp(ax.Tag, 'Axes3') % Axes3
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
