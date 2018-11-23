classdef ImageData < DataNode
	% ImageData
	
	properties
		Data % 数据块，多维矩阵，xsize * ysize * zsize * channle
		Size % Data 的 size，1*3
		Channel % 通道数，如为多通道的话则默认为RGB图像
		Max % 最大值
		Min % 最小值
		Spacing % 像素点间的物理间距，1*3
		Origin % 物理原点坐标，1*3
		Matrix % 方向矩阵，3*3
		
		% 控制在 4 个窗口上的显示对象
		Fig(4,1) cell
		
		% 内部的属性 listeners
		EL_Visible
		EL_Alpha
		EL_DisplayRange
		EL_X
		EL_Y
		EL_Z
	end
	
	
	properties (SetObservable)
		Visible logical % 可见性
		Alpha % 不透明度，0 到 1，0 表示完全透明即不可见，1 表示完全不透明
		DisplayRange % 显示范围，[low, high], 1*2
		% 当前光标指示的坐标点 [X, Y, Z]
		X
		Y
		Z
	end %
	
	
	methods
		
		
		function a = ImageData
			% 默认构造函数
			a.Visible = 1; % 默认可见
			a.Alpha = 1; % 默认不透明度为 1，即默认完全不透明
		end
		
		
		function ImageDataReader(a)
			a
		end
		
		
	end
end

