function app = TabReg_CreateFcn(tab, event, app)
% ������׼ Tab ҳ��

app.TextFixedImage = uicontrol(tab, 'Style', 'text', 'Tag', 'TextFixedImage',...
	'String', '�̶�ͼ��', 'Position', [20, 280, 60, 20]);
app.PopuFixedImage = uicontrol(tab, 'Style', 'popupmenu', 'Tag', 'PopuFixedImage',...
	'String', {'ͼ��1';'ͼ��2'}, 'Position', [80, 284, 180, 20]);

app.TextMovingImage = uicontrol(tab, 'Style', 'text', 'Tag', 'TextMovingImage',...
	'String', '�ƶ�ͼ��', 'Position', [20, 250, 60, 20]);
app.PopuMovingImage = uicontrol(tab, 'Style', 'popupmenu', 'Tag', 'PopuMovingImage',...
	'String', {'ͼ��1';'ͼ��2'}, 'Position', [80, 254, 180, 20]);


tab.ForegroundColor = [1,0,0];



end