function EqualizedImage = HistogramEqualization(image)
    % 转换为灰度图像
    grayImg = rgb2gray(image);

    % 计算灰度直方图
    histogram = zeros(1, 256);
    for i = 1:size(grayImg, 1)
        for j = 1:size(grayImg, 2)
            intensity = grayImg(i, j) + 1;
            histogram(intensity) = histogram(intensity) + 1;
        end
    end

    % 计算累计分布函数 (CDF)
    cdf = cumsum(histogram);
    cdf_normalized = cdf / cdf(end); % 归一化到 [0, 1]

    % 映射到新灰度值
    newGrayLevels = uint8(cdf_normalized * 255);

    % 创建均衡化后的图像
    EqualizedImage = zeros(size(grayImg), 'uint8');
    for i = 1:size(grayImg, 1)
        for j = 1:size(grayImg, 2)
            EqualizedImage(i, j) = newGrayLevels(grayImg(i, j) + 1);
        end
    end

    % 显示均衡化后的图像
    figure;
    imshow(EqualizedImage);
    title('直方图均衡化后的图像');
end
