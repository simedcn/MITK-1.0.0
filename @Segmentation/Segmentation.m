classdef Segmentation < handle
	% �ָ�
	
	properties
		Data(1,1) DataNode % ���ָ��ͼ������
		Result(1,1) DataNode % �ָ�����һ��Ϊ 2 ֵͼ��
		Box % ��Χ�У�3*2��[xmin, xmax; ymin, ymax; zmin, zmax]
		Image % ʵ�ʲ���ָ�����ͼ�����ݾ��󣬽�Ϊ��Χ��Χ�ڵ�
		Mask % �ָ���ͼ������ݾ��󣬽�Ϊ��Χ�д�С
	end
	
	methods
		function SetInput(a, datanode)
			a.Data = datanode;
			a.Box = [1,1,1; datanode.Size]'; % Ĭ�ϰ�Χ��Ϊ�������ݵķ�Χ
		end
		
		
	end
end

