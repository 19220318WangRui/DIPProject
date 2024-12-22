function outputImage = applySpatialFilterManual(inputImage)
    if size(inputImage, 3) == 3
        % 初始化输出图像
        outputImage = zeros(size(inputImage), 'like', inputImage);
        % 对每个通道分别处理
        for channel = 1:3
            outputImage(:,:,channel) = spatialFilterGray(inputImage(:,:,channel));
        end
    else
        % 处理灰度图像
        outputImage = spatialFilterGray(inputImage);
    end
end

function filteredImage = spatialFilterGray(inputGray)
    [rows, cols] = size(inputGray);
    kernelSize = 3; % 3x3 滤波器
    paddingSize = floor(kernelSize / 2);
    paddedImage = zeros(rows + 2 * paddingSize, cols + 2 * paddingSize);
    paddedImage(1+paddingSize:end-paddingSize, 1+paddingSize:end-paddingSize) = inputGray;

    % 初始化输出图像
    filteredImage = zeros(rows, cols);

    % 手动实现卷积操作
    for i = 1:rows
        for j = 1:cols
            % 提取邻域区域
            region = paddedImage(i:i+2, j:j+2);
            % 均值滤波
            filteredImage(i, j) = sum(region(:)) / (kernelSize * kernelSize);
        end
    end

    filteredImage = uint8(filteredImage); % 确保输出为 uint8 类型
end
