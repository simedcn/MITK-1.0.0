function ChangeIndexByMove(dm)
% 通过移动鼠标来改变当前光标坐标位置
% dm : 数据管理器 DM

ax = gca;
CurrentPoint = get(ax, 'CurrentPoint');
x = round(CurrentPoint(1,2));
y = round(CurrentPoint(1,1));

if x < 1, x = 1; end
if y < 1, y = 1; end

if strcmp(ax.Tag, 'Axes1')
	if x > dm.cdata.Size(1), x = dm.cdata.Size(1); end
	if y > dm.cdata.Size(2), y = dm.cdata.Size(2); end
	for i = 1:length(dm.DN)
		if x <= dm.DN(i).Size(1)
			dm.DN(i).X = x;
		end
		if y <= dm.DN(i).Size(2)
			dm.DN(i).Y = y;
		end
	end
	dm.Index = [x, y, dm.Index(3)];
elseif strcmp(ax.Tag, 'Axes2')
	if x > dm.cdata.Size(1), x = dm.cdata.Size(1); end
	if y > dm.cdata.Size(3), y = dm.cdata.Size(3); end
	for i = 1:length(dm.DN)
		if x <= dm.DN(i).Size(1)
			dm.DN(i).X = x;
		end
		if y <= dm.DN(i).Size(3)
			dm.DN(i).Z = y;
		end
	end
	dm.Index = [x, dm.Index(2), y];
elseif strcmp(ax.Tag, 'Axes3')
	if x > dm.cdata.Size(2), x = dm.cdata.Size(2); end
	if y > dm.cdata.Size(3), y = dm.cdata.Size(3); end
	for i = 1:length(dm.DN)
		if x <= dm.DN(i).Size(2)
			dm.DN(i).Y = x;
		end
		if y <= dm.DN(i).Size(3)
			dm.DN(i).Z = y;
		end
	end
	dm.Index = [dm.Index(1), x, y];
else
	
end

end
