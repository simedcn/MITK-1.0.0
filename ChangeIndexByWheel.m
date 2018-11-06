function ChangeIndexByWheel(dm, n)

% 通过鼠标滚轮来改变当前光标坐标位置
% dm : 数据管理器 DM
% n : 滚轮计数

ax = gca;
CurrentPoint = get(ax, 'CurrentPoint');
x = round(CurrentPoint(1,2));
y = round(CurrentPoint(1,1));
if x < ax.YLim(1) || x > ax.YLim(2) || y < ax.XLim(1) || y > ax.XLim(2)
	return;
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
	for i = 1:length(dm.DN)
		dm.DN(i).Z = idx;
	end
	dm.Index(3) = idx;
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
	for i = 1:length(dm.DN)
		dm.DN(i).Y = idx;
	end
	dm.Index(2) = idx;
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
	for i = 1:length(dm.DN)
		dm.DN(i).X = idx;
	end
	dm.Index(1) = idx;
else
	
end

end
