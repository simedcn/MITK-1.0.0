function ShowNewData(~, ~, dn)
% 显示新的数据
% 输入：
%	src : 作为事件响应函数时的事件源
%	event : 作为事件响应函数时的事件
%	dn : 要显示的数据节点 handle

a = dn.Spacing(1);
b = dn.Spacing(2);
c = dn.Spacing(3);

ax = findobj('Tag', 'Axes1');
[ax.XLim, ax.YLim] = GetAxisLim(dn, 1);
cdata = squeeze(dn.Data(:,:,dn.Z,:));
delete(dn.Fig{1});
dn.Fig{1} = imshow(cdata, dn.DisplayRange, 'Parent', ax);
ax.Color = [0.15, 0.15, 0.15];
ax.Visible = 'on'; % 每次imshow会将Visible设为off，需手动改回来
ax.DataAspectRatio = [b, a, c];

ax = findobj('Tag', 'Axes2');
[ax.XLim, ax.YLim] = GetAxisLim(dn, 2);
cdata = squeeze(dn.Data(:,dn.Y,:,:));
delete(dn.Fig{2});
dn.Fig{2} = imshow(cdata, dn.DisplayRange, 'Parent', ax);
ax.Color = [0.15, 0.15, 0.15];
ax.Visible = 'on';
ax.DataAspectRatio = [b, c, a];

ax = findobj('Tag', 'Axes3');
[ax.XLim, ax.YLim] = GetAxisLim(dn, 3);
cdata = squeeze(dn.Data(dn.X,:,:,:));
delete(dn.Fig{3});
dn.Fig{3} = imshow(cdata, dn.DisplayRange, 'Parent', ax);
ax.Color = [0.15, 0.15, 0.15];
ax.Visible = 'on';
ax.DataAspectRatio = [a, c, b];

% delete(dn.Fig{4});
% dn.Fig{4} = slice(app.Axes4, double(dn.Data), dn.Y, ...
% 	dn.X, dn.Z);

TableDM = findobj('Tag', 'TableDM');
if isempty(TableDM.Data)
	TableDM.Data = {dn.Name, dn.DataType, true};
else
	n = size(TableDM.Data, 1) + 1;
	TableDM.Data(2:n, :) = TableDM.Data;
	TableDM.Data(1, :) = {dn.Name, dn.DataType, true}; % 新打开的数据放在首行
end

end