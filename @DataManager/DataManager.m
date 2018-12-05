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
				@(src, event)DataManager.ShowNewData(src, event, a.cdata));
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
				a.cdata = dn; % 默认将当前新打开的数据作为显示顶层的数据
				notify(a, 'LoadDataSuccess');
				a.Index = ([dn.X, dn.Y, dn.Z] - 1) .* dn.Spacing + ...
					dn.Origin;
			end
		end
		
		
		% 在图像窗口交互添加种子点
		AddSeed(obj, cdata)
		
	end
	
	
	methods(Static)
		ShowNewData(src, event, dn) % 显示数据节点
	end
	 
	
	
	methods(Access = private)
		function IndexChangeFcn(a, ~, ~)
			X = a.Index(1);
			Y = a.Index(2);
			Z = a.Index(3);
			
			for i = 1:length(a.DN)
				idx = xyz2ijk(a.Index, a.DN(i));
				a.DN(i).X = idx(1);
				a.DN(i).Y = idx(2);
				a.DN(i).Z = idx(3);
			end
			
			ax = findobj('Tag', 'Axes1');
			delete(a.Line{1});
			xdata = [Y, ax.UserData(1,2); Y, ax.UserData(2,2)];
			ydata = [ax.UserData(1,1), X; ax.UserData(2,1), X];
			a.Line{1} = line(ax, xdata, ydata, 'LineWidth', 0.2);
			a.Line{1}(1).Color = 'g';
			a.Line{1}(2).Color = 'b';
			
			ax = findobj('Tag', 'Axes2');
			delete(a.Line{2});
			xdata = [Z, ax.UserData(1,3); Z, ax.UserData(2,3)];
			ydata = [ax.UserData(1,1), X; ax.UserData(2,1), X];
			a.Line{2} = line(ax, xdata, ydata, 'LineWidth', 0.2);
			a.Line{2}(1).Color = 'r';
			a.Line{2}(2).Color = 'b';
			
			ax = findobj('Tag', 'Axes3');
			delete(a.Line{3});
			xdata = [Z, ax.UserData(1,3); Z, ax.UserData(2,3)];
			ydata = [ax.UserData(1,2), Y; ax.UserData(2,2), Y];
			a.Line{3} = line(ax, xdata, ydata, 'LineWidth', 0.2);
			a.Line{3}(1).Color = 'r';
			a.Line{3}(2).Color = 'g';

			idx = [];
			for i = length(a.DN):-1:1
				if strcmp(a.DN(i).DataType, '原始') && a.DN(i).Visible
					idx = xyz2ijk(a.Index, a.DN(i));
					if ~isempty(idx)
						h = findobj('Tag', 'TextCurrentPixel');
						h.String = {['Data  : ', a.DN(i).Name];
							['Index : ', '(', num2str(idx(2)), ', ', ...
								num2str(idx(1)), ', ', num2str(idx(3)), ')'];
							['Value : ', ...
								num2str(a.DN(i).Data(idx(1), idx(2), idx(3), :))]};
						break;
					end
				end
			end
			if isempty(idx)
				h = findobj('Tag', 'TextCurrentPixel');
				h.String = {'Data  : No Data!';
					'Index : Out of image!';
					'Value : None!'};
			end
		end
		
		
		function cdataChangeFcn(a, ~, ~)
			if isempty(a.cdata)
				h = findobj('Tag', 'TextCurrentPixel');
				h.String = {'Data  : No Data!';
					'Index : Out of image!';
					'Value : None!'};
				return;
			end
			
			if ~isempty(a.Line{1})
				ReArrangeUIStack(a) % 重新排列图像层次关系
				a.Index = [a.cdata.X, a.cdata.Y, a.cdata.Z];
			end
		end


	end
	
end

