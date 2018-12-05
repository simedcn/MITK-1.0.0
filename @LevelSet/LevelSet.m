classdef LevelSet < Segmentation
	% 水平集
	
	properties
		dt % 步长
		mu % 正则化距离项 R(phi) 的系数
		lambda % 弧长项 L(phi) 的系数
				% 注：需满足 mu * dt < 1/4
		alpha % 面积项 A(phi) 的系数
		epsilon % δ函数的宽度参数
		c0; % 正值，初始化水平集函数为二值阶梯函数，内部 -c0, 外部 c0
		iter_in % 内层迭代次数
		iter_out % 外层迭代次数
		phi % 水平集函数
		area0 % 初始范围，逻辑矩阵，同原始数据一样的 size，用于初始化水平集函数
	end
	
	methods
		function a = LevelSet
			a.dt = 0.1;
			a.mu = 1;
			a.lambda = 0.001 * 255^2;
			a.alpha = 1;
			a.epsilon = 1;
			a.c0 = 1;
			a.iter_in = 5;
			a.iter_out = 1000;
		end
		
		
		function SetC0(a, c0)
			% 设置初始水平集函数
			% area : 逻辑矩阵，同原始数据一样的 size
			% c0 : 正值，可选设置，以取代默认值 3，内部为 -c0，外部为 c0
			
			if nargin == 3
				a.c0 = c0;
			end
		end
		
		
		function SetArea0(a, area)
			% 设置初始水平集函数
			% area : 逻辑矩阵，同原始数据一样的 size
			
			a.area0 = area;
		end
		
		
		function Initialization(a)
			% 初始化
			a.Image = a.Data.Data(a.Box(1,1):a.Box(1,2), ...
				a.Box(2,1):a.Box(2,2), a.Box(3,1):a.Box(3,2));
			a.Mask = false(size(a.Image));
			a.phi = a.c0 * ones(size(a.Image));
			tarea = a.area0(a.Box(1,1):a.Box(1,2), ...
				a.Box(2,1):a.Box(2,2), a.Box(3,1):a.Box(3,2));
			a.phi(tarea) = -a.c0;
		end
		
		
		function Evolution_2D_2(a)
			% 2 维水平集演化
			
			a.Initialization;
			
			img = imshow(a.Image, []);
			fig = gcf; fig.NextPlot = 'add';
			ax = gca; ax.NextPlot = 'add';
			fig.Units = 'pixels';
			fig.Position = [460,80,1000,900];
			ax.Units = 'pixels';
			ax.Position = [100,50,800,800];
			hold on; [~, hb] = contour(ax, a.phi, [0,0], 'b'); drawnow;
			[~, hr] = contour(ax, a.phi, [0,0], 'r'); drawnow;
			
			I = 255 * normab2cd(double(a.Image));
% 			I = imgaussfilt(I, 2);
			g = imgradient(I, 'central'); % 梯度模
			
% 			[N, edges] = histcounts(g, 'Normalization', 'cdf');
% 			gThre = edges(find(N > 0.95, 1, 'first'));
% 			g(g >= gThre) = 1;
% 			g(g < gThre) = g(g < gThre) / gThre;
			
			g = 1 ./ (1 + g.^2); % 相当于一个边缘检测函数，梯度越大值越小
			[gx, gy] = gradient(g);
			
			b = ones(size(I));
			K = fspecial('gaussian', 17, 4);
			KONEI2 = I.^2 .* conv2(b, K, 'same');
			e = zeros([size(I), 2]);
			Mean = mean(I(a.phi < 0));
			for i = 1:a.iter_out
				a.phi = LevelSet.NeumannBoundCond(a.phi);
				KB1 = conv2(b, K, 'same');
				KB2 = conv2(b.^2, K, 'same');
				C = LevelSet.updateC(I, a.phi, KB1, KB2, a.epsilon);
% 				C(1) = Mean;
% 				C(2) = mean(I(a.phi > 0));
				
				for j = 1:2
					e(:,:,j) = KONEI2 - 2 * I .* C(j) .* KB1 + C(j)^2 * KB2;
				end
				
				[phi_x, phi_y] = gradient(a.phi);
				s = sqrt(phi_x.^2 + phi_y.^2);
				aa = (s > 0) & (s < 1);
				bb = (s >= 1);
				cc = (s == 0);
				ps = aa .* sin(2 * pi * s) / (2 * pi) + bb .* (s - 1);
				ps = (ps + cc) ./ (s + cc); % +cc 使得 s = 0 的地方 ps = 1
				
				smallNumber = 1e-16;
				Nx = phi_x./(s + smallNumber * cc);
				Ny = phi_y./(s + smallNumber * cc);
				curvature = LevelSet.div2(Nx, Ny); % 曲率
				
				d_phi = LevelSet.delta(a.phi, a.epsilon);
				
				A2_phi = -d_phi .* (e(:,:,1) - e(:,:,2));
				% 面积项
				A_phi = a.alpha .* d_phi;
				% 弧长项
% 				L_phi = a.lambda * d_phi .* curvature;
				L_phi =  a.lambda * d_phi .* ...
					(gx .* Nx + gy .* Ny + g .* curvature);
				% 正则化距离项
% 				R_phi = a.mu * (4 * del2(a.phi)- curvature);
				R_phi = a.mu * g .* (LevelSet.div2(ps .* phi_x - phi_x, ...
					ps .* phi_y - phi_y) + 4 * del2(a.phi));
				
% 				T4 = 20 * normalize01(abs(I - Mean));
% 				T4 = 0.5 * mean(abs(I(a.phi < 0) - Mean));

% 				CC = bwconncomp(a.phi < 0);
% 				T4 = 0.2 * CC.NumObjects;

				T4 = 0 * std(I((a.phi < 0)));

				m1 = mean(I(a.phi < 0));
				m2 = mean(I(a.phi > 0));
				I_phi = 0.001 / 255 * (m1 - m2) * ((m1 + m2)/2 - I);
				
				a.phi = a.phi + a.dt * (I_phi + A_phi + L_phi + R_phi);
% 				a.phi = a.phi + a.dt * (R_phi + A_phi + L_phi + A2_phi);
				
				b = LevelSet.updateB(a.phi, I, C, K, a.epsilon);
				
				delete(hr);
				[~, hr] = contour(ax, a.phi, [0,0], 'r'); drawnow;
			end
			
			
		end
		
		
		function Evolution_2D(a)
			% 2 维水平集演化
			
			a.Initialization;
			
			img = imshow(a.Image, [0, 255]);
			fig = gcf; fig.NextPlot = 'add';
			ax = gca; ax.NextPlot = 'add';
			fig.Units = 'pixels';
			fig.Position = [460,80,1000,900];
			ax.Units = 'pixels';
			ax.Position = [100,50,800,800];
			hold on; [~, hb] = contour(ax, a.phi, [0,0], 'b'); drawnow;
			[~, hr] = contour(ax, a.phi, [0,0], 'r'); drawnow;
			
			I = 255 * normab2cd(double(a.Image), 0, 255);
% 			I = imgaussfilt(I, 2);
			g = imgradient(I, 'central'); % 梯度模
% 			g = normab2cd(g);
			
			[N, edges] = histcounts(g, 'Normalization', 'cdf');
			gThre = edges(find(N > 0.95, 1, 'first'));
			g(g > gThre) = gThre;
			g = g / gThre * 10;
			g = 1 ./ (1 + g); % 相当于一个边缘检测函数，梯度越大值越小
			[gx, gy] = gradient(g);
			m1 = mean(I(a.phi < 0));
			s1 = std(I(a.phi < 0));
			for i = 1:a.iter_out
% 				a.phi = LevelSet.NeumannBoundCond(a.phi);
				
				[phi_x, phi_y] = gradient(a.phi);
				s = sqrt(phi_x.^2 + phi_y.^2);
				aa = (s > 0) & (s < 1);
				bb = (s >= 1);
				cc = (s == 0);
				ps = aa .* sin(2 * pi * s) / (2 * pi) + bb .* (s - 1);
				ps = (ps + cc) ./ (s + cc); % +cc 使得 s = 0 的地方 ps = 1
				
				smallNumber = 1e-16;
				Nx = phi_x./(s + smallNumber * cc);
				Ny = phi_y./(s + smallNumber * cc);
				curvature = LevelSet.div2(Nx, Ny); % 曲率
				
				d_phi = LevelSet.delta(a.phi, a.epsilon);
				
				
% 				m2 = mean(I(a.phi > 0));
% 				m1 = (110 - 0) / 255 * 255;
% 				m2 = (-110 - 0) / 255 * 255;
% 				I_phi = 0.01 / 255 * (m1 - m2) * ((m1 + m2)/2 - I);
				
				dIm = abs(medfilt2(I) - m1);
				
				% 面积项
				A_phi = a.alpha * g .* d_phi .*( 10 * s1 ./ (dIm + smallNumber));
				
				% 弧长项
				L_phi =  a.lambda * d_phi .* ...
					(gx .* Nx + gy .* Ny + g .* curvature);
				
				% 正则化距离项
% 				R_phi = a.mu * (4 * del2(a.phi) - curvature);
				R_phi = a.mu * g .* (LevelSet.div2(ps .* phi_x - phi_x, ...
					ps .* phi_y - phi_y) + 4 * del2(a.phi));
				

				
				a.phi = a.phi + a.dt * (A_phi + L_phi + R_phi);
				
				delete(hr);
				[~, hr] = contour(ax, a.phi, [0,0], 'r'); drawnow;
			end
		end
		
		
	end
	
	
	methods (Access = private)
		
	end
	
	
	methods (Static)
		function c = div2(fx, fy)
			% 2 维向量场的散度计算
			[fxx, ~] = gradient(fx);
			[~, fyy] = gradient(fy);
			c = fxx + fyy;
		end
		
		
		function f = delta(x, e)
			% δ函数
			b = (x <= e) & (x >= -e);
			f = (1 / 2 / e) * (1 + cos(pi * x / e)) .* b;
		end
		
		
		function h = Heaviside(x, e)
			b = (x <= e) & (x >= -e);
			c = (x > e);
			h = 0.5 * (1 + x / e + sin(pi / e * x) / pi) .* b + c;
			
		end
		
		
		function f = delta2(x, e)
			% δ函数
% 			b = (x <= e) & (x >= -e);
			f = (e / pi) ./ (e^2 + x.^2);
		end
		
		
		function h = Heaviside2(x, e)
% 			b = (x <= e) & (x >= -e);
% 			c = (x > e);
			h = 0.5 + atan(x ./ e) / pi;
		end
		
		
		function C = updateC(I, phi, KB1, KB2, epsilon)
			h_phi = LevelSet.Heaviside2(phi, epsilon);
			M(:,:,1) = h_phi;
			M(:,:,2) = 1 - h_phi;
			N_class = size(M, 3);
			for i = 1:N_class
				Nm2 = KB1 .* I .* M(:,:,i);
				Dn2 = KB2 .* M(:,:,i);
				C(i) = sum(Nm2(:)) / sum(Dn2(:));
			end
		end
		
		
		function b = updateB(phi, I, C, K, epsilon)
			h_phi = LevelSet.Heaviside2(phi, epsilon);
			M(:,:,1) = h_phi;
			M(:,:,2) = 1 - h_phi;
			PC1 = zeros(size(I));
			PC2 = PC1;
			N_class = size(M,3);
			for i = 1:N_class
				PC1 = PC1 + C(i) * M(:,:,i);
				PC2 = PC2 + C(i)^2 * M(:,:,i);
			end
			KNm1 = conv2(PC1 .* I, K, 'same');
			KDn1 = conv2(PC2, K, 'same');
			b = KNm1 ./ KDn1;
		end
		
		
		function g = NeumannBoundCond(f)
			[nrow, ncol] = size(f);
			g = f;
			g([1 nrow],[1 ncol]) = g([3 nrow-2], [3 ncol-2]);
			g([1 nrow], 2:end-1) = g([3 nrow-2], 2:end-1);
			g(2:end-1, [1 ncol]) = g(2:end-1, [3 ncol-2]);
		end
		
		
	end
	
end














