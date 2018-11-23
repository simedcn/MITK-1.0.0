classdef Segmentation < handle
	% 分割
	
	properties
		DataName % 被分割的原始数据的名称
		Data % 被分割的图像数据
		Result % 分割结果，一般为 2 值图像
		
	end
	
	methods
		function obj = untitled3(inputArg1,inputArg2)
			%UNTITLED3 Construct an instance of this class
			%   Detailed explanation goes here
			obj.Property1 = inputArg1 + inputArg2;
		end
		
		function outputArg = method1(obj,inputArg)
			%METHOD1 Summary of this method goes here
			%   Detailed explanation goes here
			outputArg = obj.Property1 + inputArg;
		end
	end
end

