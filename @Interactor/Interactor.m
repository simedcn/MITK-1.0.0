classdef Interactor < handle
	% ���潻������
	
	
	properties
		Index % ��ǰ���ָʾ������� [x, y, z]
		
		LeftButtonDown logical
		RightButtonDown logical
		MiddleButtonDown logical
		RightClick logical
		CtrlPressDown logical
		
	end
	
	methods
		function a = Interactor
			a.LeftButtonDown = 0;
			a.RightButtonDown = 0;
			a.MiddleButtonDown = 0;
			a.RightClick = 0;
			a.CtrlPressDown = 0;
		end
	end

end

