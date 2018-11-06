function AddSeed(obj, cdata)
% ��ͼ�񴰿ڽ���������ӵ�
%   obj : MITK��ʵ��
%   cdata : ��ǰ��ʾ���ݣ�ImageData

CurrentPoint = get(gca, 'CurrentPoint');
x = round(CurrentPoint(1,1));
y = round(CurrentPoint(1,2));
Tag = get(gca, 'Tag');
if strcmp(Tag, 'Axes1')
    if 1 <= x && x <= cdata.Size(2) && 1 <= y && y <= cdata.Size(1)
        n = size(obj.Seed, 1) + 1;
        obj.Seed(n,:) = [y, x, cdata.Index(3)];
        hold on;
        if n == 1
            obj.HSeed = plot(x, y, 'g*');
             % ���UserData��������ӵ���ʾ����һ���ᣬ�Լ�λ����һ��
            obj.HSeed.UserData = [1, cdata.Index(3)];
        else
            obj.HSeed(n) = plot(x, y, 'g*');
            obj.HSeed(n).UserData = [1, cdata.Index(3)];
        end
    end
elseif strcmp(Tag, 'Axes2')
    if 1 <= x && x <= cdata.Size(1) && 1 <= y && y <= cdata.Size(3)
        n = size(obj.Seed, 1) + 1;
        obj.Seed(n,:) = [x, cdata.Index(2), y];
        hold on;
        if n == 1
            obj.HSeed = plot(x, y, 'g*');
            obj.HSeed.UserData = [2, cdata.Index(2)];
        else
            obj.HSeed(n) = plot(x, y, 'g*');
            obj.HSeed(n).UserData = [2, cdata.Index(2)];
        end
    end
elseif strcmp(Tag, 'Axes3')
    if 1 <= x && x <= cdata.Size(2) && 1 <= y && y <= cdata.Size(3)
        n = size(obj.Seed, 1) + 1;
        obj.Seed(n,:) = [cdata.Index(1), x, y];
        hold on;
        if n == 1
            obj.HSeed = plot(x, y, 'g*');
            obj.HSeed.UserData = [3, cdata.Index(1)];
        else
            obj.HSeed(n) = plot(x, y, 'g*');
            obj.HSeed(n).UserData = [3, cdata.Index(1)];
        end
    end
end

end
