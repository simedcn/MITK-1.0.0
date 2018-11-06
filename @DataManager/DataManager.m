classdef DataManager < handle
	% ���ݹ�����
	
	properties (Access = public)
		DN DataNode	% �ڵ�����
		UI(1,1) Interactor
% 		cdata % ��ǰ�����������ݽڵ㣬ͨ���ǵ�ǰ����ʾ��������ݣ����������ã�
% 			  % ��ЧʱΪ DataNode, ��Чʱ����Ϊ []
		Line(4,1) cell
		
		EL_Index event.listener
		EL_cdata event.listener
		EL_LoadDataSuccess event.listener
	end
	
	properties (SetObservable)
		% ��������
		Index % ���浱ǰ���ָʾ������� [x, y, z]
		cdata % ��ǰ�����������ݽڵ㣬ͨ���ǵ�ǰ����ʾ��������ݣ����������ã�
			  % ��ЧʱΪ DataNode, ��Чʱ����Ϊ []
	end
	
	events
		LoadDataSuccess
	end
	
	methods
		function a = DataManager
			
		end
		
		function CreateListeners(a)
			a.EL_Index = addlistener(a, 'Index', 'PostSet', @a.IndexChangeFcn);
			a.EL_cdata = addlistener(a, 'cdata', 'PostSet', @a.cdataChangeFcn);
			a.EL_LoadDataSuccess = addlistener(a, 'LoadDataSuccess', ...
				@(src, event)DataManager.ShowNewData(src, event, a.cdata));
		end
		
		function LoadData(a, filepath, filename)
			[~, ~, ext] = fileparts(filename);
			dn = DataNode;
			% ����ļ���չ��Ϊ dcm ����û����չ���������� dicom �ļ��򿪣����Զ��ڸ�·���²��� dicom �����ļ�
			if isempty(ext) || strcmpi(ext, '.dcm')
				dn.ReadDicom(filepath);
			elseif strcmpi(ext, '.nii')
				
			elseif strcmpi(ext, '.mhd')
				
			else
				errordlg('��֧�ֵ����ݸ�ʽ��', '��������ʧ��', 'modal');
			end
			
			if isempty(dn.Data)
				errordlg('δ֪����', '��������ʧ��', 'modal');
			else
				n = length(a.DN) + 1; % �������ݽڵ���� + 1
				dn.ID = n;
				dn.CreateListeners;
				a.DN(n) = dn;
				a.cdata = dn; % Ĭ�Ͻ���ǰ�´򿪵�������Ϊ��ʾ���������
				notify(a, 'LoadDataSuccess');
				a.Index = [dn.X, dn.Y, dn.Z];
			end
		end
		
		
		% ��ͼ�񴰿ڽ���������ӵ�
		AddSeed(obj, cdata)
		
	end
	
	
	methods(Static)
		ShowNewData(src, event, dn) % ��ʾ���ݽڵ�
	end
	
	
	
	methods(Access = private)
		function IndexChangeFcn(a, ~, ~)
			X = a.Index(1);
			Y = a.Index(2);
			Z = a.Index(3);
			s = a.cdata.Size;
			
			ax = findobj('Tag', 'Axes1');
			Xmax = s(2);
			Ymax = s(1);
			delete(a.Line{1});
			xdata = [Y,1; Y, Xmax];
			ydata = [1,X; Ymax, X];
			a.Line{1} = line(ax, xdata, ydata, 'LineWidth', 0.2);
			a.Line{1}(1).Color = 'g';
			a.Line{1}(2).Color = 'b';
			
			ax = findobj('Tag', 'Axes2');
			Xmax = s(3);
			Ymax = s(1);
			delete(a.Line{2});
			xdata = [Z,1; Z, Xmax];
			ydata = [1,X; Ymax, X];
			a.Line{2} = line(ax, xdata, ydata, 'LineWidth', 0.2);
			a.Line{2}(1).Color = 'r';
			a.Line{2}(2).Color = 'b';
			
			ax = findobj('Tag', 'Axes3');
			Xmax = s(3);
			Ymax = s(2);
			delete(a.Line{3});
			xdata = [Z,1; Z, Xmax];
			ydata = [1,Y; Ymax, Y];
			a.Line{3} = line(ax, xdata, ydata, 'LineWidth', 0.2);
			a.Line{3}(1).Color = 'r';
			a.Line{3}(2).Color = 'g';
			
			h = findobj('Tag', 'TextCurrentPixel');
			h.String = {['Index : ',...
				'(', num2str(Y), ', ', num2str(X), ', ', num2str(Z), ')']
				['Value : ', num2str(a.cdata.Data(X, Y, Z, :))]};
		end
		
		
		function cdataChangeFcn(a, ~, ~)
			if isempty(a.cdata)
				h = findobj('Tag', 'TextCurrentPixel');
				h.String = {'Index : Out of image!';
					'Value : None!'};
				return;
			end
			ReArrangeUIStack(a) % ��������ͼ���ι�ϵ
			a.Index = [a.cdata.X, a.cdata.Y, a.cdata.Z];
		end


	end
	
end

