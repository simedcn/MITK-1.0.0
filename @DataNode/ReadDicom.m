function ReadDicom(a, dcmpath)
% ��ȡ DICOM �ļ�����ȡ���ݣ��������ݹ�����
%   a : DataNode ʵ��
%	dcmpath : DICOM �ļ�·��

% ��ȡ�ļ����б�
files = dir(dcmpath);
files = files(~[files.isdir]);
nFiles = size(files, 1);
if nFiles == 0
	tit = '��������ʧ��';
	msg = 'ָ��·����û���ļ�������·���Ƿ���ȷ��';
	errordlg(msg, tit, 'modal');
	return;
end
filenames = cell(nFiles, 1);
for i = 1:nFiles
	filenames{i} = [files(i).folder, '\', files(i).name];
end

% ��ȡ����
if nFiles == 1
	try
		V = dicomread(filenames{1});
	catch
		tit = '��������ʧ��';
		msg = '·���¿��ܴ��ڷ� dicom �ļ���';
		errordlg(msg, tit, 'modal');
		return;
	end
else
	try
		[V, S, ~] = dicomreadVolume(filenames);
	catch
		tit = '��������ʧ��';
		msg = '·���¿��ܴ��ڷ� dicom �ļ���';
		errordlg(msg, tit, 'modal');
		return;
	end
end

info = GetDicomInfo(filenames{1});
if isempty(info)
	tit = '��������ʧ��';
	msg = '��ȡ dicom �ļ�ͷ��Ϣʧ�ܡ�';
	errordlg(msg, tit, 'modal');
	return;
end

% ��ȡ������Ҫ�� dicom ��Ϣ
a.Name = dcmpath; % ��·����Ϊ���ݽڵ�����
% a.DataType = 'ԭʼ'; % ��������Ӧ����Ϊһ���������
a.Max = max(V(:));
a.Min = min(V(:));
if isfield(info, {'WindowCenter', 'WindowWidth'})
	low = floor(info.WindowCenter(1) - info.WindowWidth(1) / 2);
	high = ceil(info.WindowCenter(1) + info.WindowWidth(1) / 2);
else
	low = a.Min;
	high = a.Max;
end
if low < a.Min
	low = a.Min;
end
if high > a.Max
	high = a.Max;
end
a.DisplayRange = double([low, high]);
ss = size(V);
if nFiles == 1
	a.Size = [ss(1:2), 1];
	if length(ss) == 2
		a.Channel = 1;
	elseif length(ss) == 3
		a.Channel = ss(3);
		V = permute(V, [1,2,4,3]); % ���������ڵ�3��ά���ϣ���ͨ�������ڵ�4��ά����
	end
	z = info.ImageOrientationPatient;
	a.Matrix = [z(1), z(2), z(3); z(4), z(5), z(6);...
		cross([z(1), z(2), z(3)], [z(4), z(5), z(6)])];
	a.Spacing = [info.PixelSpacing(2), info.PixelSpacing(1), info.SliceThickness];
	a.Origin = (abs(a.Matrix) * info.ImagePositionPatient)';
	% ���� Matlab �����б�ʾ y ���꣬�б�ʾ x ����
	a.Origin = [a.Origin(2), a.Origin(1), a.Origin(3)];
else
	a.Size = ss([1,2,4]);
	a.Channel = ss(3);
	V = permute(V, [1,2,4,3]); % ���������ڵ�3��ά���ϣ���ͨ�������ڵ�4��ά����
	normdir = cross(S.PatientOrientations(1,:,1), S.PatientOrientations(2,:,1));
	a.Matrix = [S.PatientOrientations(:,:,1); normdir];
	[~, idx] = max(abs(normdir));
	SliceThickness = abs(S.PatientPositions(1,idx) - S.PatientPositions(2,idx));
	a.Spacing = [info.PixelSpacing(2), info.PixelSpacing(1), SliceThickness];
	a.Origin = (abs(a.Matrix) * S.PatientPositions(1,:)')';
	% ���� Matlab �����б�ʾ y ���꣬�б�ʾ x ����
	a.Origin = [a.Origin(2), a.Origin(1), a.Origin(3)];
end

% У�����ݷ���
M = round(a.Matrix); % ��ʱ���ԷǴ�ֱ�����᷽������⣬���ƫ�ƽǶȹ��󣬺����������ܻ����
aa = [1,2,3]; % ���ڼ��任ǰ���Ӧ��ά��size
R = [0,1,0; 1,0,0; 0,0,1]; % �������󣬽�����һ��������ڶ�����
T = R / M * R; % ����Matlab�����ʾʱΪ ysize * xsize, ���Ի��轫��һ��������ڶ����꽻��
aa = (T * aa')';
if ~isequal(abs(aa), [1,2,3]) % �� abs(aa) = [1,2,3], ˵���������Ϊ��abs��λ�����������ŷ���
	a.Matrix = [1,0,0; 0,1,0; 0,0,1];
	a.Size = (abs(T) * a.Size')';
	a.Spacing = (abs(T) * a.Spacing')';
	a.Origin = (abs(T) * a.Origin')';
	V = permute(V, [abs(aa), 4]);
end

% ����и��ģ���������������
if aa(1) < 0
	V(1:end,:,:,:) = V(end:-1:1,:,:,:);
	a.Origin(1) = a.Origin(1) - (a.Size(1) - 1) * a.Spacing(1);
end
if aa(2) < 0
	V(:,1:end,:,:) = V(:,end:-1:1,:,:);
	a.Origin(2) = a.Origin(2) - (a.Size(2) - 1) * a.Spacing(2);
end
if aa(3) < 0 % �˴�Ϊ������ʾ����Ϊ > 0 ���������ţ�����matlab�������
	V(:,:,1:end,:) = V(:,:,end:-1:1,:);
	a.Origin(3) = a.Origin(3) - (a.Size(3) - 1) * a.Spacing(3);
end
a.EndPoint = a.Origin + (a.Size - 1) .* a.Spacing;
% idx = round((1 + a.Size) / 2);
% a.X = idx(1);
% a.Y = idx(2);
% a.Z = idx(3);

if a.Channel == 3
	if a.Max > 1 && a.Max <= 255
		V = uint8(V); % 3 ͨ�������ֵ������ 255 ��ͼ����Ϊ�� RGB ͼ��
	end
end

% ����� CT ͼ����ת��Ϊ��׼�� CT ֵ
if isfield(info, {'RescaleSlope', 'RescaleIntercept'})
	k = info.RescaleSlope;
	b = info.RescaleIntercept;
	if k ~= 1 || b ~= 0
		V = int16(V); % uint ��ʹ��Щ�����и�ֵ��Ϊ 0
		V = k * V + b;
	end
end
a.Data = V;

end

function info = GetDicomInfo(filename)

try
	info = dicominfo(filename, 'UseDictionaryVR', true);
catch ME
	if strcmpi(ME.identifier, 'MATLAB:badsubscript')
		info = dicominfo(filename, 'UseDictionaryVR', true, 'UseVRHeuristic', false);
	else
		info = [];
		% Ŀǰ��δ֪�Ŀ��ܴ����ݲ�������
	end
end

end
