classdef DataNode < handle
	% 数据节点
	
	properties
		ID % 记录该数据节点是第几个，从 1 计起
		Name char % 数据名称，字符串
		Parent DataNode % 父节点
		Child DataNode % 子节点
		DataType char % 数据类型，字符串。{'原始', '分割', '面', '其他'}
		Channel % 通道数，如为多通道的话则默认为RGB图像
		Data % 数据块
		% 以下属性依数据类型不同而可有可无，无时即为默认值(空)
		Size % Data 的 size，1*3
		Max % 最大值
		Min % 最小值
		Matrix % 方向矩阵，3*3
		Spacing % 像素点间的物理间距，1*3
		Origin % 物理原点坐标，1*3
		EndPoint % 与物理原点相对的对角点物理坐标，1*3
		
		% 控制在 4 个窗口上的显示对象，不同 DataType 的数据可能只在某几个窗口上有显示
		Fig(4,1) cell
		
		% 内部的属性 listeners
		EL_Visible
		EL_Alpha
		EL_Color
		EL_DisplayRange
% 		EL_Index
		EL_X
		EL_Y
		EL_Z
	end
	
	
	properties (SetObservable, AbortSet)
		Visible logical % 可见性
		Alpha % 不透明度，0 到 1，0 表示完全透明即不可见，1 表示完全不透明
		Color % 显示时所用的颜色，1*3颜色矩阵
		DisplayRange % 显示范围，[low, high], 1*2
		
% 		Index % 当前光标指示的坐标点的物理坐标
		% 当前光标指示点对应该数据节点的索引坐标
		X
		Y
		Z
	end %
	
	
	methods (Access = public)
		
		
		function a = DataNode
			% 默认构造函数
			a.Visible = 1; % 默认可见
			a.Alpha = 1; % 默认不透明度为 1，即默认完全不透明
			a.Color = [1,0,0];
		end
		
		
		function CreateListeners(a)
			% 创建内部的属性 listeners
			
			a.EL_Visible = addlistener(a, 'Visible', 'PostSet', @a.VisibleChangeFcn);
			a.EL_Alpha = addlistener(a, 'Alpha', 'PostSet', @a.AlphaChangeFcn);
			a.EL_Color = addlistener(a, 'Color', 'PostSet', @a.ColorChangeFcn);
			a.EL_DisplayRange = addlistener(a, 'DisplayRange', 'PostSet', @a.DisplayRangeChangeFcn);
% 			a.EL_Index = addlistener(a, 'Index', 'PostSet', @a.IndexChangeFcn);
			a.EL_X = addlistener(a, 'X', 'PostSet', @a.XChangeFcn);
			a.EL_Y = addlistener(a, 'Y', 'PostSet', @a.YChangeFcn);
			a.EL_Z = addlistener(a, 'Z', 'PostSet', @a.ZChangeFcn);
		end
		
		
		ReadDicom(a, filepath);
		
	end
	
	
	methods (Access = private)
		
		
		function VisibleChangeFcn(a, ~, ~)
			% 改变可见性 Visible 的响应函数
			
			if a.Visible % 由隐藏调成显示时，需要重新刷新图像
				a.X = a.X;
				a.Y = a.Y;
				a.Z = a.Z;
			else
				for i = 1:3
					if ~isempty(a.Fig{i}) && isvalid(a.Fig{i})
						set(a.Fig{i}, 'Visible', a.Visible);
					end
				end
			end
		end
		
		
		function AlphaChangeFcn(a, ~, ~)
			% 改变透明度 Alpha 的响应函数
			
			if strcmp(a.DataType, '原始') % 原始数据为整体透明度变化
				for i = 1:3
					if ~isempty(a.Fig{i}) && isvalid(a.Fig{i})
						set(a.Fig{i}, 'AlphaData', a.Alpha);
					end
				end
			elseif strcmp(a.DataType, '分割') % 分割数据为 MASK 内的透明度变化
				for i = 1:3
					if ~isempty(a.Fig{i}) && isvalid(a.Fig{i})
						mdata = logical(a.Fig{i}.CData);
						M = squeeze(mdata(:,:,1) | mdata(:,:,2) | mdata(:,:,3));
						alpha_mask = a.Alpha * M;
						set(a.Fig{i}, 'AlphaData', alpha_mask);
					end
				end
			else
				% 其他数据类型暂未处理
			end
		end
		
		
		function ColorChangeFcn(a, ~, ~)
			% 改变颜色 Color 的响应函数(原始数据没有 Color 属性)
			
			if strcmp(a.DataType, '分割') % 分割数据为 MASK 内的透明度变化
				for i = 1:3
					if ~isempty(a.Fig{i}) && isvalid(a.Fig{i})
						mdata = logical(a.Fig{i}.CData);
						M = squeeze(mdata(:,:,1) | mdata(:,:,2) | mdata(:,:,3));
						s = size(M);
						cM = zeros(s(1), s(2), 3);
						cM(:,:,1) = a.Color(1) * M;
						cM(:,:,2) = a.Color(2) * M;
						cM(:,:,3) = a.Color(3) * M;
						alpha_mask = a.Alpha * M;
						a.Fig{i} = imshow(cM, dn.DisplayRange, 'Parent', a.Fig{i}.Parent);
						set(a.Fig{i}, 'AlphaData', alpha_mask);
					end
				end
			else
				% 其他数据类型暂未处理
			end
		end
		
		
		function DisplayRangeChangeFcn(a, ~, ~)
			% 改变显示范围 DisplayRange 的响应函数
			
			for i = 1:4
				if ~isempty(a.Fig{i}) && isvalid(a.Fig{i})
					a.Fig{i}.Parent.CLim = a.DisplayRange;
				end
			end
			
		end
		
		
		function IndexChangeFcn(dn, ~, ~)
			
		end
		
		
		function XChangeFcn(dn, ~, ~)
			if ~dn.Visible
				return;
			end
			if dn.X < 1 || dn.X > dn.Size(1)
				delete(dn.Fig{3});
				return;
			end
% 			x = round((dn.X - dn.Origin(1)) / dn.Spacing(1)) + 1;
			ax = findobj('Tag', 'Axes3');
% 			[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
			cdata = squeeze(dn.Data(dn.X,:,:,:));
			delete(dn.Fig{3});
			dn.Fig{3} = imshow(cdata, dn.DisplayRange, 'Parent', ax);
			dn.Fig{3}.XData = [dn.Origin(3), dn.EndPoint(3)];
			dn.Fig{3}.YData = [dn.Origin(2), dn.EndPoint(2)];
			ax.Visible = 'on';
		end
		
		
		function YChangeFcn(dn, ~, ~)
			if ~dn.Visible
				return;
			end
			if dn.Y < 1 || dn.Y > dn.Size(2)
				delete(dn.Fig{2});
				return;
			end
% 			y = round((dn.Y - dn.Origin(2)) / dn.Spacing(2)) + 1;
			ax = findobj('Tag', 'Axes2');
% 			[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
			cdata = squeeze(dn.Data(:,dn.Y,:,:));
			delete(dn.Fig{2});
			dn.Fig{2} = imshow(cdata, dn.DisplayRange, 'Parent', ax);
			dn.Fig{2}.XData = [dn.Origin(3), dn.EndPoint(3)];
			dn.Fig{2}.YData = [dn.Origin(1), dn.EndPoint(1)];
			ax.Visible = 'on';
		end
		
		
		function ZChangeFcn(dn, ~, ~)
			if ~dn.Visible
				return;
			end
			if dn.Z < 1 || dn.Z > dn.Size(3)
				delete(dn.Fig{1});
				return;
			end
			z = round((dn.Z - dn.Origin(3)) / dn.Spacing(3)) + 1;
			ax = findobj('Tag', 'Axes1');
% 			[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
			cdata = squeeze(dn.Data(:,:,dn.Z,:));
			delete(dn.Fig{1});
			dn.Fig{1} = imshow(cdata, dn.DisplayRange, 'Parent', ax);
			dn.Fig{1}.XData = [dn.Origin(2), dn.EndPoint(2)];
			dn.Fig{1}.YData = [dn.Origin(1), dn.EndPoint(1)];
			ax.Visible = 'on';
		end
		
		
	end
	
	
end

