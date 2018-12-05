function ChangeIndexByWheel(dm, n)

% 通过鼠标滚轮来改变当前光标坐标位置
% dm : 数据管理器 DM
% n : 滚轮计数

ax = gca;
CurrentPoint = get(ax, 'CurrentPoint');
x = CurrentPoint(1,2);
y = CurrentPoint(1,1);
if x < ax.YLim(1) || x > ax.YLim(2) || y < ax.XLim(1) || y > ax.XLim(2)
	return; % 在坐标轴外使用滚轮无效
end
if strcmp(ax.Tag, 'Axes1')
	idx =  dm.cdata.Z - n;
	if idx > dm.cdata.Size(3)
		idx = dm.cdata.Size(3);
	elseif idx < 1
		idx = 1;
	end
	if idx == dm.cdata.Z
		return;
	end
	z_new = (idx - 1) * dm.cdata.Spacing(3) + dm.cdata.Origin(3);
	dm.Index(3) = z_new;
elseif strcmp(ax.Tag, 'Axes2')
	idx =  dm.cdata.Y + n;
	if idx > dm.cdata.Size(2)
		idx = dm.cdata.Size(2);
	elseif idx < 1
		idx = 1;
	end
	if idx == dm.cdata.Y
		return;
	end
	y_new = (idx - 1) * dm.cdata.Spacing(2) + dm.cdata.Origin(2);
	dm.Index(2) = y_new;
elseif strcmp(ax.Tag, 'Axes3')
	idx =  dm.cdata.X - n;
	if idx > dm.cdata.Size(1)
		idx = dm.cdata.Size(1);
	elseif idx < 1
		idx = 1;
	end
	if idx == dm.cdata.X
		return;
	end
	x_new = (idx - 1) * dm.cdata.Spacing(1) + dm.cdata.Origin(1);
	dm.Index(1) = x_new;
else
	
end

end
