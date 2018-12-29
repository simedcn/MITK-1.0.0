classdef DataManager < handle
	% 数据管理器
	
	properties (Access = public)
		DN DataNode	% 节点数据
		UI(1,1) Interactor % 交互控制数据

		Line(4,1) cell % 4 个窗口的十字交叉线
		
		EL_Index event.listener
		EL_cdata event.listener
		EL_LoadDataSuccess event.listener
	end
	
	properties (SetObservable, AbortSet)
		% 界面数据
		Index % 界面当前光标指示的坐标点的物理坐标 [x, y, z]
		cdata % 当前所操作的数据节点，通常是当前牌显示顶层的数据，仅用于引用，
			  % 有效时为 DataNode, 无效时被设为 []
	end
	
	properties (SetObservable)
		% 界面数据
% 		Index % 界面当前光标指示的坐标点的物理坐标 [x, y, z]
	end
	
	events
		LoadDataSuccess
	end
	
	methods
		function a = DataManager
			
		end
		
		function CreateListeners(a)
			a.EL_Index = addlistener(a, 'Index', 'PostSet', @a.IndexChangeFcn);
			a.EL_cdata = addlistener(a, 'cdata', 'PostSet', @a.cdataChangeFcn);
			a.EL_LoadDataSuccess = addlistener(a, 'LoadDataSuccess', ...
				@(src, event)DataManager.ShowNewData(src, event, src.DN(end)));
		end
		
		function LoadData(a, filepath, filename, datatype)
			[~, ~, ext] = fileparts(filename);
			dn = DataNode;
			% 如果文件拓展名为 dcm 或者没有扩展名，均视作 dicom 文件打开，
			% 并自动在该路径下查找 dicom 序列文件
			if isempty(ext) || strcmpi(ext, '.dcm')
				dn.ReadDicom(filepath);
			elseif strcmpi(ext, '.nii')
				
			elseif strcmpi(ext, '.mhd')
				
			else
				errordlg('不支持的数据格式。', '导入数据失败', 'modal');
			end
			
			if isempty(dn.Data)
				errordlg('未知错误。', '导入数据失败', 'modal');
			else
				n = length(a.DN) + 1; % 已有数据节点个数 + 1
				dn.ID = n;
				dn.DataType = datatype;
				dn.CreateListeners;
				a.DN(n) = dn;
% 				notify(a, 'LoadDataSuccess');
				a.SetAxisLim(dn);
% 				a.Index = (round((1 + dn.Size) / 2) - 1) .* dn.Spacing + ...
% 					dn.Origin;
% 				a.Index = ([dn.X, dn.Y, dn.Z] - 1) .* dn.Spacing + ...
% 					dn.Origin;
				a.cdata = dn; % 默认将当前新打开的数据作为显示顶层的数据
				
				% 加入数据管理器
				TableDM = findobj('Tag', 'TableDM');
				if isempty(TableDM.Data)
					TableDM.Data = {dn.Name, dn.DataType, true};
				else
					n = size(TableDM.Data, 1) + 1;
					TableDM.Data(2:n, :) = TableDM.Data;
					TableDM.Data(1, :) = {dn.Name, dn.DataType, true}; % 新打开的数据放在首行
				end
			end
		end
		
		
		% 在图像窗口交互添加种子点
		AddSeed(obj, cdata)
		
	end
	
	
	methods(Static)
		ShowNewData(src, event, dn) % 显示数据节点
	end
	 
	
	
	methods(Access = private)
		function SetAxisLim(a, dn)
			% 根据数据size和spacing来设置坐标的轴的范围
			
			ax = findobj('Tag', 'Axes1');
			[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
			ax.Color = [0.15, 0.15, 0.15];
			ax = findobj('Tag', 'Axes2');
			[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
			ax.Color = [0.15, 0.15, 0.15];
			ax = findobj('Tag', 'Axes3');
			[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
			ax.Color = [0.15, 0.15, 0.15];
			
			a.Index = (ax.UserData(1,:) + ax.UserData(2,:)) / 2;
		end
		
		
		function IndexChangeFcn(a, ~, ~)
			% 光标 Index 改变引起 DataNode 中索引 X, Y, Z 的改变
			for i = 1:length(a.DN)
				idx = xyz2ijk(a.Index, a.DN(i));
				a.DN(i).X = idx(1);
				a.DN(i).Y = idx(2);
				a.DN(i).Z = idx(3);
			end
			% 更新十字交叉线
			a.UpdateCrossLine;
			% 更新状态栏
			a.UpdateStatusBar;
		end
		
		
		function cdataChangeFcn(a, ~, ~)
			if isempty(a.cdata)
				h = findobj('Tag', 'TextCurrentPixel');
				h.String = {'Data  : No Data!';
					'Index : Out of image!';
					'Value : None!'};
			else
				a.UpdateStatusBar;
			end
		end
		
		
		function UpdateStatusBar(a)
			found = false;
			for i = length(a.DN):-1:1
				if strcmp(a.DN(i).DataType, '原始') && a.DN(i).Visible
					idx = xyz2ijk(a.Index, a.DN(i));
					if (idx >= 1) & (idx <= a.DN(i).Size) %#ok<AND2>
						h = findobj('Tag', 'TextCurrentPixel');
						h.String = {['Data  : ', a.DN(i).Name];
							['Index : ', '(', num2str(idx(2)), ', ', ...
							num2str(idx(1)), ', ', num2str(idx(3)), ')'];
							['Value : ', ...
							num2str(a.DN(i).Data(idx(1), idx(2), idx(3), :))]};
						found = true;
						break;
					end
				end
			end
			if ~found
				h = findobj('Tag', 'TextCurrentPixel');
				h.String = {'Data  : No Data!';
					'Index : Out of image!';
					'Value : None!'};
			end
		end
		
		
		function UpdateCrossLine(a)
			X = a.Index(1);
			Y = a.Index(2);
			Z = a.Index(3);
			if ~isempty(a.Line{1}) % 更多的时候是执行这一块，响应更快
				ax = findobj('Tag', 'Axes1');
				xdata = [Y, ax.UserData(1,2); Y, ax.UserData(2,2)];
				ydata = [ax.UserData(1,1), X; ax.UserData(2,1), X];
				a.Line{1}(1).XData = xdata(:,1)';
				a.Line{1}(1).YData = ydata(:,1)';
				a.Line{1}(2).XData = xdata(:,2)';
				a.Line{1}(2).YData = ydata(:,2)';
				
				ax = findobj('Tag', 'Axes2');
				xdata = [Z, ax.UserData(1,3); Z, ax.UserData(2,3)];
				ydata = [ax.UserData(1,1), X; ax.UserData(2,1), X];
				a.Line{2}(1).XData = xdata(:,1)';
				a.Line{2}(1).YData = ydata(:,1)';
				a.Line{2}(2).XData = xdata(:,2)';
				a.Line{2}(2).YData = ydata(:,2)';
				
				ax = findobj('Tag', 'Axes3');
				xdata = [Z, ax.UserData(1,3); Z, ax.UserData(2,3)];
				ydata = [ax.UserData(1,2), Y; ax.UserData(2,2), Y];
				a.Line{3}(1).XData = xdata(:,1)';
				a.Line{3}(1).YData = ydata(:,1)';
				a.Line{3}(2).XData = xdata(:,2)';
				a.Line{3}(2).YData = ydata(:,2)';
			else % 只有第一次创建 Line 时才执行这一块
				ax = findobj('Tag', 'Axes1');
				xdata = [Y, ax.UserData(1,2); Y, ax.UserData(2,2)];
				ydata = [ax.UserData(1,1), X; ax.UserData(2,1), X];
				a.Line{1} = line(ax, xdata, ydata, 'LineWidth', 0.2);
				a.Line{1}(1).Tag = 'CrossLine1';
				a.Line{1}(2).Tag = 'CrossLine1';
				a.Line{1}(1).Color = 'g';
				a.Line{1}(2).Color = 'b';
				
				ax = findobj('Tag', 'Axes2');
				xdata = [Z, ax.UserData(1,3); Z, ax.UserData(2,3)];
				ydata = [ax.UserData(1,1), X; ax.UserData(2,1), X];
				a.Line{2} = line(ax, xdata, ydata, 'LineWidth', 0.2);
				a.Line{2}(1).Tag = 'CrossLine2';
				a.Line{2}(2).Tag = 'CrossLine2';
				a.Line{2}(1).Color = 'r';
				a.Line{2}(2).Color = 'b';
				
				ax = findobj('Tag', 'Axes3');
				xdata = [Z, ax.UserData(1,3); Z, ax.UserData(2,3)];
				ydata = [ax.UserData(1,2), Y; ax.UserData(2,2), Y];
				a.Line{3} = line(ax, xdata, ydata, 'LineWidth', 0.2);
				a.Line{3}(1).Tag = 'CrossLine3';
				a.Line{3}(2).Tag = 'CrossLine3';
				a.Line{3}(1).Color = 'r';
				a.Line{3}(2).Color = 'g';
			end
		end
		
		
	end
	
end

