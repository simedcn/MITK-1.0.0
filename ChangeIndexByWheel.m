function ChangeIndexByWheel(dm, n)

% 通过鼠标滚轮来改变当前光标坐标位置
% dm : 数据管理器 DM
% n : 滚轮计数

ax = gca;
CurrentPoint = get(ax, 'CurrentPoint');
x = CurrentPoint(1,2);
y = CurrentPoint(1,1);
if x < ax.YLim(1) || x > ax.YLim(2) || y < ax.XLim(1) || y > ax.XLim(2)
	return;
end
if strcmp(ax.Tag, 'Axes1')
	z = round((dm.cdata.Z - dm.cdata.Origin(3)) / dm.cdata.Spacing(3)) + 1;
	idx =  z - n;
	if idx > dm.cdata.Size(3)
		idx = dm.cdata.Size(3);
	elseif idx < 1
		idx = 1;
	end
	if idx == z
		return;
	end
	z_new = (idx - 1) * dm.cdata.Spacing(3) + dm.cdata.Origin(3);
	for i = 1:length(dm.DN)
		dm.DN(i).Z = z_new;
	end
	dm.Index(3) = z_new;
elseif strcmp(ax.Tag, 'Axes2')
	y = round((dm.cdata.Y - dm.cdata.Origin(2)) / dm.cdata.Spacing(2)) + 1;
	idx =  y + n;
	if idx > dm.cdata.Size(2)
		idx = dm.cdata.Size(2);
	elseif idx < 1
		idx = 1;
	end
	if idx == y
		return;
	end
	y_new = (idx - 1) * dm.cdata.Spacing(2) + dm.cdata.Origin(2);
	for i = 1:length(dm.DN)
		dm.DN(i).Y = y_new;
	end
	dm.Index(2) = y_new;
elseif strcmp(ax.Tag, 'Axes3')
	x = round((dm.cdata.X - dm.cdata.Origin(1)) / dm.cdata.Spacing(1)) + 1;
	idx =  x - n;
	if idx > dm.cdata.Size(1)
		idx = dm.cdata.Size(1);
	elseif idx < 1
		idx = 1;
	end
	if idx == x
		return;
	end
	x_new = (idx - 1) * dm.cdata.Spacing(1) + dm.cdata.Origin(1);
	for i = 1:length(dm.DN)
		dm.DN(i).X = x_new;
	end
	dm.Index(1) = x_new;
else
	
end

end
