function ChangeIndexByClick(dm)
% 通过鼠标点击来改变当前光标坐标位置
% dm : 数据管理器 DM

ax = gca;
CurrentPoint = get(ax, 'CurrentPoint');
x = CurrentPoint(1,2);
y = CurrentPoint(1,1);
if x < ax.YLim(1) || x > ax.YLim(2) || y < ax.XLim(1) || y > ax.XLim(2)
	return; % 点到坐标轴外无效
end
if strcmp(ax.Tag, 'Axes1')
	if x < ax.UserData(1,1), x = ax.UserData(1,1); end
	if x > ax.UserData(2,1), x = ax.UserData(2,1); end
	if y < ax.UserData(1,2), y = ax.UserData(1,2); end
	if y > ax.UserData(2,2), y = ax.UserData(2,2); end
% 	for i = 1:length(dm.DN)
% 		if x >= dm.DN(i).Origin(1) && x <= dm.DN(i).EndPoint(1)
% 			dm.DN(i).X = x;
% 		end
% 		if y >= dm.DN(i).Origin(2) && y <= dm.DN(i).EndPoint(2)
% 			dm.DN(i).Y = y;
% 		end
% 	end
	dm.Index = [x, y, dm.Index(3)];
elseif strcmp(ax.Tag, 'Axes2')
	if x < ax.UserData(1,1), x = ax.UserData(1,1); end
	if x > ax.UserData(2,1), x = ax.UserData(2,1); end
	if y < ax.UserData(1,3), y = ax.UserData(1,3); end
	if y > ax.UserData(2,3), y = ax.UserData(2,3); end
% 	for i = 1:length(dm.DN)
% 		if x >= dm.DN(i).Origin(1) && x <= dm.DN(i).EndPoint(1)
% 			dm.DN(i).X = x;
% 		end
% 		if y >= dm.DN(i).Origin(3) && y <= dm.DN(i).EndPoint(3)
% 			dm.DN(i).Z = y;
% 		end
% 	end
	dm.Index = [x, dm.Index(2), y];
elseif strcmp(ax.Tag, 'Axes3')
	if x < ax.UserData(1,2), x = ax.UserData(1,2); end
	if x > ax.UserData(2,2), x = ax.UserData(2,2); end
	if y < ax.UserData(1,3), y = ax.UserData(1,3); end
	if y > ax.UserData(2,3), y = ax.UserData(2,3); end
% 	for i = 1:length(dm.DN)
% 		if x >= dm.DN(i).Origin(2) && x <= dm.DN(i).EndPoint(2)
% 			dm.DN(i).Y = x;
% 		end
% 		if y >= dm.DN(i).Origin(3) && y <= dm.DN(i).EndPoint(3)
% 			dm.DN(i).Z = y;
% 		end
% 	end
	dm.Index = [dm.Index(1), x, y];
else
	
end

end
