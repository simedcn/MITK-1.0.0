classdef RegTest < handle
	properties
		M % 移动图像
		F % 固定图像
		Msize % 移动图像size
		Fsize % 固定图像size
		Mtemp % 移动模板图像
		Ftemp % 固定模板图像
		tempsize % 模板图像size，默认[256, 256]
		Tsize % 形变场size, 即 [tempsize, 2]
		N % N = a.Tsize(1) * a.Tsize(2) * a.Tsize(3)
		T % 形变场，Tsize
		Mgrid % 用于插值计算的坐标网格点，Tsize
		Fgrid % 用于插值计算的坐标网格点，Tsize
		Result % 配准结果图像
% 		k % 迭代次数
% 		m % 储存 yk, sk 的个数
% 		s % s(k) = x(k+1) - x(k), 以一维向量形式储存，只存 m 个，即 size 为 N*m
% 		y % y(k) = g(k+1) - g(k), 以一维向量形式储存，只存 m 个，即 size 为 N*m
	end
	
	methods
		
		
		function a = RegTest(mImage, fImage)
			% 构造函数
			a.M = double(mImage);
			a.F = double(fImage);
			a.Msize = size(a.M);
			a.Fsize = size(a.F);
			a.tempsize = [50, 50];
			a.Tsize = [a.tempsize, 2];
			a.N = a.Tsize(1) * a.Tsize(2) * a.Tsize(3);
			Mxy(1,:) = linspace(1, a.Msize(1), a.tempsize(1)); % CT采样坐标点
			Mxy(2,:) = linspace(1, a.Msize(2), a.tempsize(2));
			Fxy(1,:) = linspace(1, a.Fsize(1), a.tempsize(1)); % MR采样坐标点
			Fxy(2,:) = linspace(1, a.Fsize(2), a.tempsize(2));
			a.Mgrid = zeros(a.Tsize);
			a.Fgrid = zeros(a.Tsize);
			[a.Mgrid(:,:,1), a.Mgrid(:,:,2)] = ndgrid(Mxy(1,:), Mxy(2,:));
			[a.Fgrid(:,:,1), a.Fgrid(:,:,2)] = ndgrid(Fxy(1,:), Fxy(2,:));
			a.Mtemp = interp2(a.M, a.Mgrid(:,:,2), a.Mgrid(:,:,1));
			a.Ftemp = interp2(a.F, a.Fgrid(:,:,2), a.Fgrid(:,:,1));
			
% 			a.k = 1;
% 			a.m = 5;
% 			a.s = zeros(a.Tsize(1) * a.Tsize(2) * a.Tsize(3), m);
% 			a.y = zeros(a.Tsize(1) * a.Tsize(2) * a.Tsize(3), m);
		end
		
		
		function Update(a)
			m = 5;
			s = zeros(a.N, m); % x(k+1) - x(k)
			y = zeros(a.N, m); % g(k+1) - g(k)
			x = zeros(a.N, 1);
			g1 = a.gfun(x); % 前一点的梯度
			q = g1; % 每轮的搜索方向
% 			s(:,1) = a.GetNextPoint(x, -g1);
			tstart = tic;
			fprintf('迭代开始:\n');
			for k = 1:100
				
				if k <= m
					L = k;
				else
					L = m;
					s(:,1:m-1) = s(:,2:m);
					y(:,1:m-1) = y(:,2:m);
				end
				s(:,L) = a.GetNextPoint(x, -q);
				x = x + s(:,L);
				g2 = a.gfun(x); % 后一点的梯度
				if max(abs(g2)) < eps % 终止条件
					break;
				end
				y(:,L) = g2 - g1;
				
				alpha = zeros(L-1, 1);
				for i = L:-1:1
% 					j = i + delta;
					alpha(i) = s(:,i)' * g1 / (y(:,i)' * s(:,i));
					q = g1 - alpha(i) * y(:,i);
					g1 = q;
				end
				beta = zeros(L-1, 1);
				for i = 1:L
% 					j = i + delta;
					beta(i) = y(:,i)' * q / (y(:,i)' * s(:,i));
					g1 = q + (alpha(i) - beta(i)) * s(:,i);
					q = g1;
				end
				g1 = g2;
				fprintf('已迭代 %3d 次，共用时：%s\n',...
					k, duration([0,0,toc(tstart)]));
			end
			a.T = reshape(x, a.Tsize);
			tempgrid = a.Mgrid + a.T;
			a.Result = interp2(a.M, tempgrid(:,:,2), tempgrid(:,:,1), 'linear', 0);
			xy(1,:) = linspace(1, a.tempsize(1), a.Fsize(1));
			xy(2,:) = linspace(1, a.tempsize(2), a.Fsize(2));
			[tempgrid(:,:,1), tempgrid(:,:,2)] = ndgrid(xy(1,:), xy(1,:));
			a.Result = interp2(a.Result, tempgrid(:,:,2), tempgrid(:,:,1), 'linear', 0);
		end
		
		
		function I = GetOutput(a)
			I = a.Result;
		end
		
		
	end
	
	methods (Access = private)
		
		
		function f = fun(a, t)
			% 提供一个形变场，计算优化函数，类成员变量 Ftemp 需要在外部就计算好了
			% t : 形变场
			t = reshape(t, a.Tsize);
			tempgrid = a.Mgrid + t;
			a.Mtemp = interp2(a.M, tempgrid(:,:,2), tempgrid(:,:,1), 'linear', 0);
			Mmean = mean(a.Mtemp(:));
			Fmean = mean(a.Ftemp(:));
			f1 = sum((a.Mtemp - Mmean) .* (a.Ftemp - Fmean), 'all') / ...
				(sqrt(sum((a.Mtemp - Mmean).^2, 'all')) * ...
				sqrt(sum((a.Ftemp - Fmean).^2, 'all')));
			
			f = f1;
		end
		
		
		function g = gfun(a, t)
			% 梯度函数，计算在点 t 处的梯度
			% t : 在这里 t 为一个形变场
% 			g = gfun2(t, a.M, a.Ftemp, a.Mgrid);
			
			g = zeros(a.N, 1);
			parfor i = 1:length(t)
				t1 = t; t2 = t;
				t1(i) = t1(i) + 0.5;
				t2(i) = t2(i) - 0.5;
				t1 = reshape(t1, a.Tsize);
				t2 = reshape(t2, a.Tsize);
				g(i) = (a.fun(t1) - a.fun(t2));
			end
			g = g / max(abs(g));
		end
		
		
		function sk = GetNextPoint(a, xk, dk)
			% Armijo 一维非精确搜索
			beta = 0.5;
			sigma = 0.2;
			m = 0;
			mmax = 50;
			while m <= mmax
				if a.fun(xk + beta^m * dk) <= ...
						a.fun(xk) + sigma * beta^m * a.gfun(xk)' * dk
					break;
				end
				m = m + 1;
			end
			sk = beta^m * dk;
		end
		
		
	end
end

