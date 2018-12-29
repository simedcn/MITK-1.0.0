function ReadDicom(a, dcmpath)
% 读取 DICOM 文件，获取数据，存入数据管理器
%   a : DataNode 实例
%	dcmpath : DICOM 文件路径

% 获取文件名列表
files = dir(dcmpath);
files = files(~[files.isdir]);
nFiles = size(files, 1);
if nFiles == 0
	tit = '导入数据失败';
	msg = '指定路径下没有文件！请检查路径是否正确。';
	errordlg(msg, tit, 'modal');
	return;
end
filenames = cell(nFiles, 1);
for i = 1:nFiles
	filenames{i} = [files(i).folder, '\', files(i).name];
end

% 读取数据
if nFiles == 1
	try
		V = dicomread(filenames{1});
	catch
		tit = '导入数据失败';
		msg = '路径下可能存在非 dicom 文件。';
		errordlg(msg, tit, 'modal');
		return;
	end
else
	try
		[V, S, ~] = dicomreadVolume(filenames);
	catch
		tit = '导入数据失败';
		msg = '路径下可能存在非 dicom 文件。';
		errordlg(msg, tit, 'modal');
		return;
	end
end

info = GetDicomInfo(filenames{1});
if isempty(info)
	tit = '导入数据失败';
	msg = '读取 dicom 文件头信息失败。';
	errordlg(msg, tit, 'modal');
	return;
end

% 读取其他必要的 dicom 信息
a.Name = dcmpath; % 以路径作为数据节点名称
% a.DataType = '原始'; % 后续这里应该作为一个输入参数
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
		V = permute(V, [1,2,4,3]); % 将张数放在第3个维度上，将通道数放在第4个维度上
	end
	z = info.ImageOrientationPatient;
	a.Matrix = [z(1), z(2), z(3); z(4), z(5), z(6);...
		cross([z(1), z(2), z(3)], [z(4), z(5), z(6)])];
	a.Spacing = [info.PixelSpacing(2), info.PixelSpacing(1), info.SliceThickness];
	a.Origin = (abs(a.Matrix) * info.ImagePositionPatient)';
	% 由于 Matlab 矩阵行表示 y 坐标，列表示 x 坐标
	a.Origin = [a.Origin(2), a.Origin(1), a.Origin(3)];
else
	a.Size = ss([1,2,4]);
	a.Channel = ss(3);
	V = permute(V, [1,2,4,3]); % 将张数放在第3个维度上，将通道数放在第4个维度上
	normdir = cross(S.PatientOrientations(1,:,1), S.PatientOrientations(2,:,1));
	a.Matrix = [S.PatientOrientations(:,:,1); normdir];
	[~, idx] = max(abs(normdir));
	SliceThickness = abs(S.PatientPositions(1,idx) - S.PatientPositions(2,idx));
	a.Spacing = [info.PixelSpacing(2), info.PixelSpacing(1), SliceThickness];
	a.Origin = (abs(a.Matrix) * S.PatientPositions(1,:)')';
	% 由于 Matlab 矩阵行表示 y 坐标，列表示 x 坐标
	a.Origin = [a.Origin(2), a.Origin(1), a.Origin(3)];
end

% 校正数据方向
M = round(a.Matrix); % 暂时忽略非垂直坐标轴方向的问题，如果偏移角度过大，后续操作可能会出错
aa = [1,2,3]; % 用于检测变换前后对应的维度size
R = [0,1,0; 1,0,0; 0,0,1]; % 交换矩阵，交换第一个坐标与第二坐标
T = R / M * R; % 由于Matlab矩阵表示时为 ysize * xsize, 所以还需将第一个坐标与第二坐标交换
aa = (T * aa')';
if ~isequal(abs(aa), [1,2,3]) % 若 abs(aa) = [1,2,3], 说明方向矩阵为的abs单位矩阵，无须重排方向
	a.Matrix = [1,0,0; 0,1,0; 0,0,1];
	a.Size = (abs(T) * a.Size')';
	a.Spacing = (abs(T) * a.Spacing')';
	a.Origin = (abs(T) * a.Origin')';
	V = permute(V, [abs(aa), 4]);
end

% 如果有负的，则做个逆向重排
if aa(1) < 0
	V(1:end,:,:,:) = V(end:-1:1,:,:,:);
	a.Origin(1) = a.Origin(1) - (a.Size(1) - 1) * a.Spacing(1);
end
if aa(2) < 0
	V(:,1:end,:,:) = V(:,end:-1:1,:,:);
	a.Origin(2) = a.Origin(2) - (a.Size(2) - 1) * a.Spacing(2);
end
if aa(3) < 0 % 此处为便于显示而设为 > 0 才逆向重排，由于matlab差异造成
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
		V = uint8(V); % 3 通道，最大值不超过 255 的图像，认为是 RGB 图像
	end
end

% 如果是 CT 图像，则转换为标准的 CT 值
if isfield(info, {'RescaleSlope', 'RescaleIntercept'})
	k = info.RescaleSlope;
	b = info.RescaleIntercept;
	if k ~= 1 || b ~= 0
		V = int16(V); % uint 会使有些数据中负值变为 0
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
		% 目前还未知的可能错误，暂不作处理
	end
end

end
