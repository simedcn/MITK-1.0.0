classdef Interactor < handle
	% 界面交互控制
	
	
	properties
		Index % 当前光标指示的坐标点 [x, y, z]
		
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

