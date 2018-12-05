%#ok<*DEFNU>
%#ok<*INUSL>
%#ok<*INUSD>
function varargout = MITK(varargin)
% MITK MATLAB code for MITK.fig
%      MITK, by itself, creates a new MITK or raises the existing
%      singleton*.
%
%      H = MITK returns the handle to a new MITK or the handle to
%      the existing singleton*.
%
%      MITK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MITK.M with the given input arguments.
%
%      MITK('Property','Value',...) creates a new MITK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MITK_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MITK_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MITK

% Last Modified by GUIDE v2.5 30-Nov-2018 10:36:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
	'gui_Singleton',  gui_Singleton, ...
	'gui_OpeningFcn', @MITK_OpeningFcn, ...
	'gui_OutputFcn',  @MITK_OutputFcn, ...
	'gui_LayoutFcn',  [] , ...
	'gui_Callback',   []);
if nargin && ischar(varargin{1})
	gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
	[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
	gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before MITK is made visible.
function MITK_OpeningFcn(hObject, eventdata, app, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MITK (see VARARGIN)

% Choose default command line output for MITK
app.output = hObject;

% ���������������ݣ��Լ�һЩ��Ҫ�ĳ�ʼ��
app.TableDM.Data = {};
app.DM = DataManager;
app.DM.CreateListeners;

% ���һЩ·��
addpath('./C++ code');

% ���� Tab ҳ��
% app.TabGP = uitabgroup(app.PanLevelSet);
% app.TabReg = uitab(app.TabGP, 'Title', '��׼', 'Tag', 'TabReg');
% app.TabSeg = uitab(app.TabGP, 'Title', '�ָ�', 'Tag', 'TabSeg');
% app = TabReg_CreateFcn(app.TabReg, [], app);

% Update handles structure
guidata(hObject, app);

% UIWAIT makes MITK wait for user response (see UIRESUME)
% uiwait(handles.MITK);
end


% --- Outputs from this function are returned to the command line.
function varargout = MITK_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% ��Test����ť��Ӧ����������������
function Test_Callback(hObject, eventdata, app)

hObject.Enable = 'off'; drawnow;
filepath = 'E:\DCMDATA\20171117-SH0021-0007-ZSM\MR\data\PV1';
filename = 'E:\DCMDATA\20171117-SH0021-0007-ZSM\MR\data\PV1\IM0';
app.DM.LoadData(filepath, filename, 'ԭʼ');
return


hObject.Enable = 'off'; drawnow;
filepath = 'E:\DCMDATA\CVH\416x469_Gray';
filename = 'E:\DCMDATA\CVH\416x469_Gray\001.dcm';
app.DM.LoadData(filepath, filename);
drawnow;
filepath = 'E:\DCMDATA\CVH\416x469_RGB';
filename = 'E:\DCMDATA\CVH\416x469_RGB\001.dcm';
app.DM.LoadData(filepath, filename);

end


function SliderHigh_Callback(hObject, eventdata, app)

end


function SliderHigh_CreateFcn(hObject, eventdata, app)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end


function SliderLow_Callback(hObject, eventdata, app)

% app.Axes1.

end


function SliderLow_CreateFcn(hObject, eventdata, app)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end


function EditLow_Callback(hObject, eventdata, app)

end


function EditLow_CreateFcn(hObject, eventdata, app)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end

end


function EditHigh_Callback(hObject, eventdata, app)

end


function EditHigh_CreateFcn(hObject, eventdata, app)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end
end


function MenuFile_Callback(hObject, eventdata, app)

end


function MenuFile_Open_Callback(hObject, eventdata, app)

[filename, filepath] = uigetfile('*.*', '���DICOM�ļ�');
if filepath == 0
	return;
end

app.DM.LoadData(filepath, filename, 'ԭʼ');

end


function TableDM_CellEditCallback(hObject, event, app)

row = event.Indices(1);
col = event.Indices(2);
n = 0;

if col == 1 % �޸�����ʱ����Ҫͨ���¼�����ȡ�޸�ǰ������
	for i = 1:length(app.DM.DN)
		if strcmp(app.DM.DN(i).Name, event.PreviousData) % ͨ���������������ұ༭�����ĸ�����
			n = i;
			break;
		end
	end
	if n
		app.DM.DN(n).Name = event.NewData;
	end
else % �����޸�����ʱ��ֱ��ʹ�ñ�������
	for i = 1:length(app.DM.DN)
		if strcmp(app.DM.DN(i).Name, hObject.Data(row,1)) % ͨ���������������ұ༭�����ĸ�����
			n = i;
			break;
		end
	end
	
	
	if n
		if col == 4 % �޸Ĳ�͸���� % Ŀǰֻ��3�У�ɾ���˲�͸������ֵ�༭��һ�У���������Ч
			temp = double(event.NewData);
			if temp < 0 || temp > 100 % ���� 0 �� 100 ���򲻸ı�
				hObject.Data{row,3} = event.PreviousData;
			else
				app.DM.DN(n).Alpha = hObject.Data{row,4} / 100;
			end
		elseif col == 3 % �޸Ŀɼ���
			app.DM.DN(n).Visible = event.NewData;
			% ���µ�ǰ���ڶ�������ݽڵ�
			FOUND = false;
			for i = 1:size(hObject.Data, 1)
				if hObject.Data{i,3}
					for ii = 1:length(app.DM.DN)
						if strcmp(app.DM.DN(ii).Name, hObject.Data{i,1})
							app.DM.cdata = app.DM.DN(ii);
							app.Axes1.CLim = app.DM.cdata.DisplayRange;
							app.Axes2.CLim = app.DM.cdata.DisplayRange;
							app.Axes3.CLim = app.DM.cdata.DisplayRange;
							break;
						end
					end
					FOUND = true;
					break;
				end
			end
			if ~FOUND % ��� TableDM ��û�����ݱ�ѡ����ʾ
				app.DM.cdata = [];
			end
		end
	end
end

end


% ���̰�������
function MITK_WindowKeyPressFcn(hObject, eventdata, app)

if isempty(app.DM.cdata)
	return;
end

if strcmp(eventdata.Key, 'control')
	app.DM.UI.CtrlPressDown = 1;
end

end


% ���̰�������
function MITK_WindowKeyReleaseFcn(hObject, eventdata, app)

if isempty(app.DM.cdata)
	return;
end

if strcmp(eventdata.Key, 'control')
	app.DM.UI.CtrlPressDown = 0;
end

end


% ������
function MITK_WindowScrollWheelFcn(hObject, eventdata, app)

if isempty(app.DM.cdata)
	return;
end

ChangeIndexByWheel(app.DM, eventdata.VerticalScrollCount);

end


% ��갴������
function MITK_WindowButtonDownFcn(hObject, eventdata, app)

if isempty(app.DM.cdata)
	return;
end

clicktype = get(gcbf, 'SelectionType');
if strcmp(clicktype, 'normal') % �������
% 	fprintf('���\n')
	app.DM.UI.LeftButtonDown = 1;
	ChangeIndexByClick(app.DM);
elseif strcmp(clicktype, 'extend') % 3�������(1)Shift+�����(2)Shift+�Ҽ���(3)�м�
% 	fprintf('���Ҽ�\n')
elseif strcmp(clicktype, 'alt') % 2�������(1)Ctrl+�����(2)�Ҽ�
% 	fprintf('Ctrl+������Ҽ�\n')
elseif strcmp(clicktype, 'open') % ˫�������
% 	fprintf('˫��\n')
end

end


% ��갴��̧��
function MITK_WindowButtonUpFcn(hObject, eventdata, app)

if isempty(app.DM.cdata)
	return;
end

clicktype = get(gcbf, 'SelectionType');
if strcmp(clicktype, 'normal') % ����������
	app.DM.UI.LeftButtonDown = 0;
elseif strcmp(clicktype, 'alt')
	
end

end


% ����ƶ�
function MITK_WindowButtonMotionFcn(hObject, eventdata, app)

if isempty(app.DM.cdata)
	return;
end

cp = get(gcf, 'CurrentPoint'); % CurrentPointOnFigure��������Ϊ��λ��
ax1 = findobj('Tag', 'Axes1');
ax2 = findobj('Tag', 'Axes2');
ax3 = findobj('Tag', 'Axes3');
ax4 = findobj('Tag', 'Axes4');
% ����ʵ�֣�����ƶ����ĸ������ᣬ�ͽ��ĸ���������Ϊ��ǰ���������
if  cp(1) >= ax1.Position(1) && cp(1) <= ax1.Position(1) + ax1.Position(3) &&...
		cp(2) >= ax1.Position(2) && cp(2) <= ax1.Position(2) + ax1.Position(4)
	set(gcf, 'CurrentAxes', ax1);
elseif cp(1) >= ax2.Position(1) && cp(1) <= ax2.Position(1) + ax2.Position(3) &&...
		cp(2) >= ax2.Position(2) && cp(2) <= ax2.Position(2) + ax2.Position(4)
	set(gcf, 'CurrentAxes', ax2);
elseif cp(1) >= ax3.Position(1) && cp(1) <= ax3.Position(1) + ax3.Position(3) &&...
		cp(2) >= ax3.Position(2) && cp(2) <= ax3.Position(2) + ax3.Position(4)
	set(gcf, 'CurrentAxes', ax3);
elseif cp(1) >= ax4.Position(1) && cp(1) <= ax4.Position(1) + ax4.Position(3) &&...
		cp(2) >= ax4.Position(2) && cp(2) <= ax4.Position(2) + ax4.Position(4)
	set(gcf, 'CurrentAxes', ax4);
end

if app.DM.UI.LeftButtonDown % �������Ǵ��ڰ��µ�״̬
% 	ChangeIndexByClick(app.DM);
	ChangeIndexByMove(app.DM);
end

if app.DM.UI.PaintbrushOn
	ax = gca;
	CurrentPoint = get(ax, 'CurrentPoint');
	x = CurrentPoint(1,2);
	y = CurrentPoint(1,1);
	if x < ax.YLim(1) || x > ax.YLim(2) || y < ax.XLim(1) || y > ax.XLim(2)
		delete(app.DM.UI.cc);
		return; % �㵽����������Ч
	end
	dn = app.DM.cdata;
	if strcmp(ax.Tag, 'Axes1')
		p = xyz2ijk([x, y, dn.Z], dn);
		if isempty(p)
			delete(app.DM.UI.cc);
			return;
		end
		i = p(1); j = p(2); k = p(3);
		I = double(dn.Data(:,:,k));
		M = zeros(dn.Size(1), dn.Size(2));
		seed = [i,j];
		seedtype = 1;
		neibtype = 4;
		threlow = 40;
		threhigh = 30;
		radius = 20;
		DeformableBrush(I, M, seed, seedtype, neibtype, threlow, threhigh, radius);
		se = strel('disk', 2);
		M = imclose(logical(M), se);
		% DeformableBrush(I, M, seed, seedtype, neibtype, threlow, threhigh, radius)
		% I : ����ͼ��
		% M : ���ͼ��
		% seed : ���ӵ����꣬1*2
		% seedtype : ���ӵ����͡�0, 1, 2, 3,...
		% neibtype : �������͡�4, 8; 6, 18, 26
		% threlow : ����ֵ
		% threhigh : ����ֵ
		% radius : ��ˢ�뾶
		
% 		v = I(i,j);
% 		M(i,j) = 1;
% 		
% 		for ii = -r:r
% 			for jj = -r:r
% 				if ii^2 + jj^2 <= r^2
% 					xx = i + ii;
% 					yy = j + jj;
% 					if xx >= 1 && xx <= dn.Size(1) && ...
% 							yy >= 1 && yy <= dn.Size(2)
% 						if abs(I(xx,yy) - v) < Thre
% 							M(xx,yy) = 1;
% 						end
% 					end
% 				end
% 			end
% 		end
		delete(app.DM.UI.cc);
		[~, app.DM.UI.cc] = contour(ax, double(M), [0.5,0.5], 'r');
		app.DM.UI.cc.XData = (app.DM.UI.cc.XData - 1) * dn.Spacing(2) + ...
			dn.Origin(2);
		app.DM.UI.cc.YData = (app.DM.UI.cc.YData - 1) * dn.Spacing(1) + ...
			dn.Origin(1);
		drawnow;
	end
end

end


function RegTest_Callback(hObject, eventdata, app)

fprintf('��׼�����ѽ���\n');
hObject.Enable = 'off'; drawnow;
return

filepath = '.\TESTDATA\mr';
filename = '.\TESTDATA\mr\IM32';
app.DM.LoadData(filepath, filename);
drawnow;
filepath = '.\TESTDATA\ct';
filename = '.\TESTDATA\ct\02568091';
app.DM.LoadData(filepath, filename);
drawnow;
% 
ct = double(app.DM.DN(2).Data);
mr = double(app.DM.DN(1).Data);
ct = imgaussfilt(ct);
mr = imgaussfilt(mr);
test = RegTest(mr, ct);
test.Update;
save('test.mat', 'test');

end




function PopMenuAlgNav1_Callback(hObject, eventdata, handles)

end


function PopMenuAlgNav1_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function PopMenuAlgNav2_Callback(hObject, eventdata, handles)

end


function PopMenuAlgNav2_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function PanLevelSet_PopMenuSegData_Callback(hObject, eventdata, handles)

end


function PanLevelSet_PopMenuSegData_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function PanLevelSet_EditSegName_Callback(hObject, eventdata, handles)

end


function PanLevelSet_EditSegName_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function PanLevelSet_PopMenuSegColor_Callback(hObject, eventdata, handles)

end


function PanLevelSet_PopMenuSegColor_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function PanLevelSet_ButtonSegColor_Callback(hObject, eventdata, handles)

c = uisetcolor(hObject);
hObject.BackgroundColor = c;
g = sum([0.299, 0.587, 0.114] .* c);
if g < 0.3
	hObject.ForegroundColor = [1,1,1];
else
	hObject.ForegroundColor = [0,0,0];
end
end


function PanLevelSet_PopMenuSegDim_Callback(hObject, eventdata, handles)

end


function PanLevelSet_PopMenuSegDim_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function Paintbrush_Callback(hObject, eventdata, app)

% if isempty(app.DM.cdata)
% 	return;
% end

if app.DM.UI.PaintbrushOn
	app.DM.UI.PaintbrushOn = 0;
	hObject.BackgroundColor = [0.94, 0.94, 0.94];
else
	app.DM.UI.PaintbrushOn = 1;
	hObject.BackgroundColor = [0.4, 0.8, 1];
end

end
