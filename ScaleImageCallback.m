% Scale Image Callback
function ScaleImageCallback(app, ~)
    if isempty(app.ImageData)
        uialert(app.UIFigure, '请先加载图像！', '错误');
        return;
    end

    % 获取用户输入的缩放系数
    scaleFactor = app.ScaleFactorInput.Value;
    if isempty(scaleFactor) || scaleFactor <= 0
        uialert(app.UIFigure, '请输入有效缩放系数！', '错误');
        return;
    end
    
    % 获取原图像的尺寸
    [origHeight, origWidth, numChannels] = size(app.ImageData);
    
    % 计算目标图像的尺寸
    newHeight = round(origHeight * scaleFactor);
    newWidth = round(origWidth * scaleFactor);
    
    % 创建一个新的图像矩阵用于存储缩放后的图像
    scaledImg = zeros(newHeight, newWidth, numChannels, 'uint8');
    
    % 最近邻插值
    for i = 1:newHeight
        for j = 1:newWidth
            % 计算对应于原图像中的像素位置
            origX = round(i / scaleFactor);
            origY = round(j / scaleFactor);
            
            % 确保索引在有效范围内
            origX = min(max(origX, 1), origHeight);
            origY = min(max(origY, 1), origWidth);
            
            % 将原图像的像素值赋给目标图像
            scaledImg(i, j, :) = app.ImageData(origX, origY, :);
        end
    end
    
    % 调整显示区域大小
    % 使图像自适应显示区域
    axis(app.ImageAxes, 'off'); % 隐藏坐标轴
    imshow(scaledImg, 'Parent', app.ImageAxes);
    
    % 使图像在显示区域居中
    % 获取图像显示区域的大小
    axesPos = app.ImageAxes.Position; % 获取坐标轴的位置
    imagePos = [axesPos(1) + (axesPos(3) - newWidth) / 2, ...
                axesPos(2) + (axesPos(4) - newHeight) / 2, ...
                newWidth, newHeight];
    set(app.ImageAxes, 'Position', imagePos); % 设置显示区域的位置
end
