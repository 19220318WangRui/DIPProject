% Rotate Image Callback
function RotateImageCallback(app, ~)
    if isempty(app.ImageData)
        uialert(app.UIFigure, '请先加载图像！', '错误');
        return;
    end

    % 获取用户输入的旋转角度
    angle = app.RotationAngleInput.Value;
    if isempty(angle)
        uialert(app.UIFigure, '请输入有效的旋转角度！', '错误');
        return;
    end

    % 将角度转换为弧度
    theta = deg2rad(angle);

    % 获取原图像的尺寸
    [origHeight, origWidth, numChannels] = size(app.ImageData);

    % 计算旋转后的图像尺寸
    % 计算旋转后的边界框，保证图像不会被裁剪
    newWidth = round(abs(origWidth * cos(theta)) + abs(origHeight * sin(theta)));
    newHeight = round(abs(origWidth * sin(theta)) + abs(origHeight * cos(theta)));

    % 创建一个新的空白图像，用于存储旋转后的图像
    rotatedImg = zeros(newHeight, newWidth, numChannels, 'uint8');

    % 计算原图像的中心点
    centerX = (origWidth + 1) / 2;
    centerY = (origHeight + 1) / 2;

    % 计算旋转后图像的中心点
    newCenterX = (newWidth + 1) / 2;
    newCenterY = (newHeight + 1) / 2;

    % 对每个像素点进行反向旋转
    for i = 1:newHeight
        for j = 1:newWidth
            % 计算当前像素在原图中的坐标
            x = (j - newCenterX) * cos(theta) + (i - newCenterY) * sin(theta) + centerX;
            y = -(j - newCenterX) * sin(theta) + (i - newCenterY) * cos(theta) + centerY;

            % 判断计算得到的坐标是否在原图像内
            if x >= 1 && x <= origWidth && y >= 1 && y <= origHeight
                % 使用双线性插值获取原图像对应位置的像素值
                x1 = floor(x);
                x2 = min(ceil(x), origWidth);
                y1 = floor(y);
                y2 = min(ceil(y), origHeight);

                % 计算插值权重
                wx = x - x1;
                wy = y - y1;

                % 获取四个邻域像素值并进行插值
                for c = 1:numChannels
                    rotatedImg(i, j, c) = uint8( ...
                        (1 - wx) * (1 - wy) * double(app.ImageData(y1, x1, c)) + ...
                        wx * (1 - wy) * double(app.ImageData(y1, x2, c)) + ...
                        (1 - wx) * wy * double(app.ImageData(y2, x1, c)) + ...
                        wx * wy * double(app.ImageData(y2, x2, c)) ...
                    );
                end
            end
        end
    end

    % 显示旋转后的图像
    imshow(rotatedImg, 'Parent', app.ImageAxes);
end
