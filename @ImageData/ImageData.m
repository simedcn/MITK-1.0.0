classdef ImageData < DataNode
	% ImageData
	
	properties
		Data % ���ݿ飬��ά����xsize * ysize * zsize * channle
		Size % Data �� size��1*3
		Channel % ͨ��������Ϊ��ͨ���Ļ���Ĭ��ΪRGBͼ��
		Max % ���ֵ
		Min % ��Сֵ
		Spacing % ���ص��������࣬1*3
		Origin % ����ԭ�����꣬1*3
		Matrix % �������3*3
		
		% ������ 4 �������ϵ���ʾ����
		Fig(4,1) cell
		
		% �ڲ������� listeners
		EL_Visible
		EL_Alpha
		EL_DisplayRange
		EL_X
		EL_Y
		EL_Z
	end
	
	
	properties (SetObservable)
		Visible logical % �ɼ���
		Alpha % ��͸���ȣ�0 �� 1��0 ��ʾ��ȫ͸�������ɼ���1 ��ʾ��ȫ��͸��
		DisplayRange % ��ʾ��Χ��[low, high], 1*2
		% ��ǰ���ָʾ������� [X, Y, Z]
		X
		Y
		Z
	end %
	
	
	methods
		
		
		function a = ImageData
			% Ĭ�Ϲ��캯��
			a.Visible = 1; % Ĭ�Ͽɼ�
			a.Alpha = 1; % Ĭ�ϲ�͸����Ϊ 1����Ĭ����ȫ��͸��
		end
		
		
		function ImageDataReader(a)
			a
		end
		
		
	end
end

