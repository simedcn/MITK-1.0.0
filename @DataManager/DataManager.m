classdef DataManager < handle
	% ���ݹ�����
	
	properties (Access = public)
		DN DataNode	% �ڵ�����
		UI(1,1) Interactor % ������������

		Line(4,1) cell % 4 �����ڵ�ʮ�ֽ�����
		
		EL_Index event.listener
		EL_cdata event.listener
		EL_LoadDataSuccess event.listener
	end
	
	properties (SetObservable, AbortSet)
		% ��������
		Index % ���浱ǰ���ָʾ���������������� [x, y, z]
		cdata % ��ǰ�����������ݽڵ㣬ͨ���ǵ�ǰ����ʾ��������ݣ����������ã�
			  % ��ЧʱΪ DataNode, ��Чʱ����Ϊ []
	end
	
	properties (SetObservable)
		% ��������
% 		Index % ���浱ǰ���ָʾ���������������� [x, y, z]
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
				@(src, event)DataManager.ShowNewData(src, event, src.DN(end)));
		end
		
		function LoadData(a, filepath, filename, datatype)
			[~, ~, ext] = fileparts(filename);
			dn = DataNode;
			% ����ļ���չ��Ϊ dcm ����û����չ���������� dicom �ļ��򿪣�
			% ���Զ��ڸ�·���²��� dicom �����ļ�
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
				dn.DataType = datatype;
				dn.CreateListeners;
				a.DN(n) = dn;
% 				notify(a, 'LoadDataSuccess');
				a.SetAxisLim(dn);
% 				a.Index = (round((1 + dn.Size) / 2) - 1) .* dn.Spacing + ...
% 					dn.Origin;
% 				a.Index = ([dn.X, dn.Y, dn.Z] - 1) .* dn.Spacing + ...
% 					dn.Origin;
				a.cdata = dn; % Ĭ�Ͻ���ǰ�´򿪵�������Ϊ��ʾ���������
				
				% �������ݹ�����
				TableDM = findobj('Tag', 'TableDM');
				if isempty(TableDM.Data)
					TableDM.Data = {dn.Name, dn.DataType, true};
				else
					n = size(TableDM.Data, 1) + 1;
					TableDM.Data(2:n, :) = TableDM.Data;
					TableDM.Data(1, :) = {dn.Name, dn.DataType, true}; % �´򿪵����ݷ�������
				end
			end
		end
		
		
		% ��ͼ�񴰿ڽ���������ӵ�
		AddSeed(obj, cdata)
		
	end
	
	
	methods(Static)
		ShowNewData(src, event, dn) % ��ʾ���ݽڵ�
	end
	 
	
	
	methods(Access = private)
		function SetAxisLim(a, dn)
			% ��������size��spacing�������������ķ�Χ
			
			ax = findobj('Tag', 'Axes1');
			[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
			ax.Color = [0.15, 0.15, 0.15];
			ax = findobj('Tag', 'Axes2');
			[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
			ax.Color = [0.15, 0.15, 0.15];
			ax = findobj('Tag', 'Axes3');
			[ax.XLim, ax.YLim] = GetAxisLim(dn, ax);
			ax.Color = [0.15, 0.15, 0.15];
			
			a.Index = (ax.UserData(1,:) + ax.UserData(2,:)) / 2;
		end
		
		
		function IndexChangeFcn(a, ~, ~)
			% ��� Index �ı����� DataNode ������ X, Y, Z �ĸı�
			for i = 1:length(a.DN)
				idx = xyz2ijk(a.Index, a.DN(i));
				a.DN(i).X = idx(1);
				a.DN(i).Y = idx(2);
				a.DN(i).Z = idx(3);
			end
			% ����ʮ�ֽ�����
			a.UpdateCrossLine;
			% ����״̬��
			a.UpdateStatusBar;
		end
		
		
		function cdataChangeFcn(a, ~, ~)
			if isempty(a.cdata)
				h = findobj('Tag', 'TextCurrentPixel');
				h.String = {'Data  : No Data!';
					'Index : Out of image!';
					'Value : None!'};
			else
				a.UpdateStatusBar;
			end
		end
		
		
		function UpdateStatusBar(a)
			found = false;
			for i = length(a.DN):-1:1
				if strcmp(a.DN(i).DataType, 'ԭʼ') && a.DN(i).Visible
					idx = xyz2ijk(a.Index, a.DN(i));
					if (idx >= 1) & (idx <= a.DN(i).Size) %#ok<AND2>
						h = findobj('Tag', 'TextCurrentPixel');
						h.String = {['Data  : ', a.DN(i).Name];
							['Index : ', '(', num2str(idx(2)), ', ', ...
							num2str(idx(1)), ', ', num2str(idx(3)), ')'];
							['Value : ', ...
							num2str(a.DN(i).Data(idx(1), idx(2), idx(3), :))]};
						found = true;
						break;
					end
				end
			end
			if ~found
				h = findobj('Tag', 'TextCurrentPixel');
				h.String = {'Data  : No Data!';
					'Index : Out of image!';
					'Value : None!'};
			end
		end
		
		
		function UpdateCrossLine(a)
			X = a.Index(1);
			Y = a.Index(2);
			Z = a.Index(3);
			if ~isempty(a.Line{1}) % �����ʱ����ִ����һ�飬��Ӧ����
				ax = findobj('Tag', 'Axes1');
				xdata = [Y, ax.UserData(1,2); Y, ax.UserData(2,2)];
				ydata = [ax.UserData(1,1), X; ax.UserData(2,1), X];
				a.Line{1}(1).XData = xdata(:,1)';
				a.Line{1}(1).YData = ydata(:,1)';
				a.Line{1}(2).XData = xdata(:,2)';
				a.Line{1}(2).YData = ydata(:,2)';
				
				ax = findobj('Tag', 'Axes2');
				xdata = [Z, ax.UserData(1,3); Z, ax.UserData(2,3)];
				ydata = [ax.UserData(1,1), X; ax.UserData(2,1), X];
				a.Line{2}(1).XData = xdata(:,1)';
				a.Line{2}(1).YData = ydata(:,1)';
				a.Line{2}(2).XData = xdata(:,2)';
				a.Line{2}(2).YData = ydata(:,2)';
				
				ax = findobj('Tag', 'Axes3');
				xdata = [Z, ax.UserData(1,3); Z, ax.UserData(2,3)];
				ydata = [ax.UserData(1,2), Y; ax.UserData(2,2), Y];
				a.Line{3}(1).XData = xdata(:,1)';
				a.Line{3}(1).YData = ydata(:,1)';
				a.Line{3}(2).XData = xdata(:,2)';
				a.Line{3}(2).YData = ydata(:,2)';
			else % ֻ�е�һ�δ��� Line ʱ��ִ����һ��
				ax = findobj('Tag', 'Axes1');
				xdata = [Y, ax.UserData(1,2); Y, ax.UserData(2,2)];
				ydata = [ax.UserData(1,1), X; ax.UserData(2,1), X];
				a.Line{1} = line(ax, xdata, ydata, 'LineWidth', 0.2);
				a.Line{1}(1).Tag = 'CrossLine1';
				a.Line{1}(2).Tag = 'CrossLine1';
				a.Line{1}(1).Color = 'g';
				a.Line{1}(2).Color = 'b';
				
				ax = findobj('Tag', 'Axes2');
				xdata = [Z, ax.UserData(1,3); Z, ax.UserData(2,3)];
				ydata = [ax.UserData(1,1), X; ax.UserData(2,1), X];
				a.Line{2} = line(ax, xdata, ydata, 'LineWidth', 0.2);
				a.Line{2}(1).Tag = 'CrossLine2';
				a.Line{2}(2).Tag = 'CrossLine2';
				a.Line{2}(1).Color = 'r';
				a.Line{2}(2).Color = 'b';
				
				ax = findobj('Tag', 'Axes3');
				xdata = [Z, ax.UserData(1,3); Z, ax.UserData(2,3)];
				ydata = [ax.UserData(1,2), Y; ax.UserData(2,2), Y];
				a.Line{3} = line(ax, xdata, ydata, 'LineWidth', 0.2);
				a.Line{3}(1).Tag = 'CrossLine3';
				a.Line{3}(2).Tag = 'CrossLine3';
				a.Line{3}(1).Color = 'r';
				a.Line{3}(2).Color = 'g';
			end
		end
		
		
	end
	
end

