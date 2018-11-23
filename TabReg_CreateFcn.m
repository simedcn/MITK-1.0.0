function app = TabReg_CreateFcn(tab, event, app)
% ´´½¨Åä×¼ Tab Ò³Ãæ

app.TextFixedImage = uicontrol(tab, 'Style', 'text', 'Tag', 'TextFixedImage',...
	'String', '¹Ì¶¨Í¼Ïñ', 'Position', [20, 280, 60, 20]);
app.PopuFixedImage = uicontrol(tab, 'Style', 'popupmenu', 'Tag', 'PopuFixedImage',...
	'String', {'Í¼Ïñ1';'Í¼Ïñ2'}, 'Position', [80, 284, 180, 20]);

app.TextMovingImage = uicontrol(tab, 'Style', 'text', 'Tag', 'TextMovingImage',...
	'String', 'ÒÆ¶¯Í¼Ïñ', 'Position', [20, 250, 60, 20]);
app.PopuMovingImage = uicontrol(tab, 'Style', 'popupmenu', 'Tag', 'PopuMovingImage',...
	'String', {'Í¼Ïñ1';'Í¼Ïñ2'}, 'Position', [80, 254, 180, 20]);


tab.ForegroundColor = [1,0,0];



end