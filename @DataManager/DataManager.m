classdef DataManager < handle
	% 数据管理器
	
	properties (Access = public)
		DN DataNode	% 节点数据
		UI(1,1) Interactor
% 		cdata % 当前所操作的数据节点，通常是当前牌显示顶层的数据，仅用于引用，
% 			  % 有效时为 DataNode, 无效时被设为 []
		Line(4,1) cell
		
		EL_Index event.listener
		EL_cdata event.listener
		EL_LoadDataSuccess event.listener
	end
	
	properties (SetObservable)
		% 界面数据
		Index % 界面当前光标指示的坐标点 [x, y, z]
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
		
		function LoadData(a, filepath, filename)
			[~, ~, ext] = fileparts(filename);
			dn = DataNode;
			% 如果文件拓展名为 dcm 或者没有扩展名，均视作 dicom 文件打开，并自动在该路径下查找 dicom 序列文件
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
				dn.CreateListeners;
				a.DN(n) = dn;
				a.cdata = dn; % 默认将当前新打开的数据作为显示顶层的数据
				notify(a, 'LoadDataSuccess');
				a.Index = [dn.X, dn.Y, dn.Z];
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
			s = a.cdata.Size;
			
			ax = findobj('Tag', 'Axes1');
			Xmax = s(2);
			Ymax = s(1);
			delete(a.Line{1});
			xdata = [Y,1; Y, Xmax];
			ydata = [1,X; Ymax, X];
			a.Line{1} = line(ax, xdata, ydata, 'LineWidth', 0.2);
			a.Line{1}(1).Color = 'g';
			a.Line{1}(2).Color = 'b';
			
			ax = findobj('Tag', 'Axes2');
			Xmax = s(3);
			Ymax = s(1);
			delete(a.Line{2});
			xdata = [Z,1; Z, Xmax];
			ydata = [1,X; Ymax, X];
			a.Line{2} = line(ax, xdata, ydata, 'LineWidth', 0.2);
			a.Line{2}(1).Color = 'r';
			a.Line{2}(2).Color = 'b';
			
			ax = findobj('Tag', 'Axes3');
			Xmax = s(3);
			Ymax = s(2);
			delete(a.Line{3});
			xdata = [Z,1; Z, Xmax];
			ydata = [1,Y; Ymax, Y];
			a.Line{3} = line(ax, xdata, ydata, 'LineWidth', 0.2);
			a.Line{3}(1).Color = 'r';
			a.Line{3}(2).Color = 'g';
			
			h = findobj('Tag', 'TextCurrentPixel');
			h.String = {['Index : ',...
				'(', num2str(Y), ', ', num2str(X), ', ', num2str(Z), ')']
				['Value : ', num2str(a.cdata.Data(X, Y, Z, :))]};
		end
		
		
		function cdataChangeFcn(a, ~, ~)
			if isempty(a.cdata)
				h = findobj('Tag', 'TextCurrentPixel');
				h.String = {'Index : Out of image!';
					'Value : None!'};
				return;
			end
			ReArrangeUIStack(a) % 重新排列图像层次关系
			a.Index = [a.cdata.X, a.cdata.Y, a.cdata.Z];
		end


	end
	
end

