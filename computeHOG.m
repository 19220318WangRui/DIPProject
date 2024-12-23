function hogFeatures = computeHOG(inputImage)
    % 确保输入是灰度图像
    if size(inputImage, 3) == 3
        inputImage = rgb2gray(inputImage);  % 转换为灰度图像
    end

    % 计算梯度
    [gradX, gradY] = gradient(double(inputImage));
    
    % 计算梯度幅值和方向
    magnitude = sqrt(gradX.^2 + gradY.^2);
    direction = atan2(gradY, gradX) * 180 / pi;  % 转换为角度

    % 将方向范围映射到[0, 180)
    direction(direction < 0) = direction(direction < 0) + 180;

    % 创建方向直方图
    numBins = 9;  % 方向直方图的数量
    hogFeatures = zeros(size(inputImage));

    % 迭代图像中的每一个 8x8 块，确保不会越界
    for i = 1:size(inputImage, 1)-7  % 避免越界，i的最大值为size(inputImage, 1)-7
        for j = 1:size(inputImage, 2)-7  % 避免越界，j的最大值为size(inputImage, 2)-7
            % 获取每个8x8块的梯度方向
            blockMagnitude = magnitude(i:i+7, j:j+7);
            blockDirection = direction(i:i+7, j:j+7);
            
            % 计算每个块的方向直方图
            hist = zeros(1, numBins);
            for m = 1:8
                for n = 1:8
                    % 确保 bin 的索引不会超出范围
                    bin = floor(blockDirection(m,n) / (180 / numBins));
                    bin = min(bin, numBins - 1);  % 保证 bin 的最大值为 numBins - 1
                    hist(bin+1) = hist(bin+1) + blockMagnitude(m,n);
                end
            end
            hogFeatures(i,j) = sum(hist);  % 这里将特征向量简化为直方图的总和
        end
    end
end
