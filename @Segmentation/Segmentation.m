classdef Segmentation < handle
	% 分割
	
	properties
		Data(1,1) DataNode % 被分割的图像数据
		Result(1,1) DataNode % 分割结果，一般为 2 值图像
		Box % 包围盒，3*2，[xmin, xmax; ymin, ymax; zmin, zmax]
		Image % 实际参与分割计算的图像数据矩阵，仅为包围范围内的
		Mask % 分割结果图像的数据矩阵，仅为包围盒大小
	end
	
	methods
		function SetInput(a, datanode)
			a.Data = datanode;
			a.Box = [1,1,1; datanode.Size]'; % 默认包围盒为整个数据的范围
		end
		
		
	end
end

