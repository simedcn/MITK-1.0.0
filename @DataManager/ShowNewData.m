function ShowNewData(~, ~, dn)
% ��ʾ�µ�����
% ���룺
%	src : ��Ϊ�¼���Ӧ����ʱ���¼�Դ
%	event : ��Ϊ�¼���Ӧ����ʱ���¼�
%	dn : Ҫ��ʾ�����ݽڵ� handle


ax = findobj('Tag', 'Axes1');
[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
cdata = squeeze(dn.Data(:,:,dn.Z,:));
delete(dn.Fig{1});
dn.Fig{1} = imshow(cdata, dn.DisplayRange, 'Parent', ax);
dn.Fig{1}.XData = [dn.Origin(2), dn.EndPoint(2)];
dn.Fig{1}.YData = [dn.Origin(1), dn.EndPoint(1)];
ax.Color = [0.15, 0.15, 0.15];
ax.Visible = 'on'; % ÿ��imshow�ὫVisible��Ϊoff�����ֶ��Ļ���
% ax.DataAspectRatio = [b, a, c];

ax = findobj('Tag', 'Axes2');
[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
cdata = squeeze(dn.Data(:,dn.Y,:,:));
delete(dn.Fig{2});
dn.Fig{2} = imshow(cdata, dn.DisplayRange, 'Parent', ax);
dn.Fig{2}.XData = [dn.Origin(3), dn.EndPoint(3)];
dn.Fig{2}.YData = [dn.Origin(1), dn.EndPoint(1)];
ax.Color = [0.15, 0.15, 0.15];
ax.Visible = 'on';
% ax.DataAspectRatio = [b, c, a];

ax = findobj('Tag', 'Axes3');
[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
cdata = squeeze(dn.Data(dn.X,:,:,:));
delete(dn.Fig{3});
dn.Fig{3} = imshow(cdata, dn.DisplayRange, 'Parent', ax);
dn.Fig{3}.XData = [dn.Origin(3), dn.EndPoint(3)];
dn.Fig{3}.YData = [dn.Origin(2), dn.EndPoint(2)];
ax.Color = [0.15, 0.15, 0.15];
ax.Visible = 'on';
% ax.DataAspectRatio = [a, c, b];

% delete(dn.Fig{4});
% dn.Fig{4} = slice(app.Axes4, double(dn.Data), dn.Y, ...
% 	dn.X, dn.Z);

TableDM = findobj('Tag', 'TableDM');
if isempty(TableDM.Data)
	TableDM.Data = {dn.Name, dn.DataType, true};
else
	n = size(TableDM.Data, 1) + 1;
	TableDM.Data(2:n, :) = TableDM.Data;
	TableDM.Data(1, :) = {dn.Name, dn.DataType, true}; % �´򿪵����ݷ�������
end

end