classdef DataNode < handle
	% ���ݽڵ�
	
	properties
		ID % ��¼�����ݽڵ��ǵڼ������� 1 ����
		Name char % �������ƣ��ַ���
		Parent DataNode % ���ڵ�
		Child DataNode % �ӽڵ�
		DataType char % �������ͣ��ַ�����{'ԭʼ', '�ָ�', '��', '����'}
		Channel % ͨ��������Ϊ��ͨ���Ļ���Ĭ��ΪRGBͼ��
		Data % ���ݿ�
		% �����������������Ͳ�ͬ�����п��ޣ���ʱ��ΪĬ��ֵ(��)
		Size % Data �� size��1*3
		Max % ���ֵ
		Min % ��Сֵ
		Matrix % �������3*3
		Spacing % ���ص��������࣬1*3
		Origin % ����ԭ�����꣬1*3
		EndPoint % ������ԭ����ԵĶԽǵ��������꣬1*3
		
		% ������ 4 �������ϵ���ʾ���󣬲�ͬ DataType �����ݿ���ֻ��ĳ��������������ʾ
		Fig(4,1) cell
		
		% �ڲ������� listeners
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
		Visible logical % �ɼ���
		Alpha % ��͸���ȣ�0 �� 1��0 ��ʾ��ȫ͸�������ɼ���1 ��ʾ��ȫ��͸��
		Color % ��ʾʱ���õ���ɫ��1*3��ɫ����
		DisplayRange % ��ʾ��Χ��[low, high], 1*2
		
% 		Index % ��ǰ���ָʾ����������������
		% ��ǰ���ָʾ���Ӧ�����ݽڵ����������
		X
		Y
		Z
	end %
	
	
	methods (Access = public)
		
		
		function a = DataNode
			% Ĭ�Ϲ��캯��
			a.Visible = 1; % Ĭ�Ͽɼ�
			a.Alpha = 1; % Ĭ�ϲ�͸����Ϊ 1����Ĭ����ȫ��͸��
			a.Color = [1,0,0];
		end
		
		
		function CreateListeners(a)
			% �����ڲ������� listeners
			
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
			% �ı�ɼ��� Visible ����Ӧ����
			
			if a.Visible % �����ص�����ʾʱ����Ҫ����ˢ��ͼ��
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
			% �ı�͸���� Alpha ����Ӧ����
			
			if strcmp(a.DataType, 'ԭʼ') % ԭʼ����Ϊ����͸���ȱ仯
				for i = 1:3
					if ~isempty(a.Fig{i}) && isvalid(a.Fig{i})
						set(a.Fig{i}, 'AlphaData', a.Alpha);
					end
				end
			elseif strcmp(a.DataType, '�ָ�') % �ָ�����Ϊ MASK �ڵ�͸���ȱ仯
				for i = 1:3
					if ~isempty(a.Fig{i}) && isvalid(a.Fig{i})
						mdata = logical(a.Fig{i}.CData);
						M = squeeze(mdata(:,:,1) | mdata(:,:,2) | mdata(:,:,3));
						alpha_mask = a.Alpha * M;
						set(a.Fig{i}, 'AlphaData', alpha_mask);
					end
				end
			else
				% ��������������δ����
			end
		end
		
		
		function ColorChangeFcn(a, ~, ~)
			% �ı���ɫ Color ����Ӧ����(ԭʼ����û�� Color ����)
			
			if strcmp(a.DataType, '�ָ�') % �ָ�����Ϊ MASK �ڵ�͸���ȱ仯
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
				% ��������������δ����
			end
		end
		
		
		function DisplayRangeChangeFcn(a, ~, ~)
			% �ı���ʾ��Χ DisplayRange ����Ӧ����
			
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

