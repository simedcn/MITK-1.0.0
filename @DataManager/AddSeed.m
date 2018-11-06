function AddSeed(obj, cdata)
% 在图像窗口交互添加种子点
%   obj : MITK类实例
%   cdata : 当前显示数据，ImageData

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
             % 添加UserData储存该种子点显示于哪一个轴，以及位于哪一层
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
