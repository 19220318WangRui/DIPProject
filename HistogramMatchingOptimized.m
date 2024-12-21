function matchedImage = HistogramMatchingOptimized(sourceImage, targetImage)
    % 确保输入图像是灰度图像
    if size(sourceImage, 3) > 1
        sourceImage = rgb2gray(sourceImage);
    end
    if size(targetImage, 3) > 1
        targetImage = rgb2gray(targetImage);
    end

    % 计算源图像和目标图像的直方图
    srcHist = histcounts(sourceImage, 0:256);
    tgtHist = histcounts(targetImage, 0:256);

    % 计算累计分布函数 (CDF)
    srcCDF = cumsum(srcHist) / numel(sourceImage);
    tgtCDF = cumsum(tgtHist) / numel(targetImage);

    % 生成映射关系
    map = zeros(256, 1, 'uint8');
    tgtIndex = 1;
    for srcVal = 1:256
        while tgtIndex < 256 && tgtCDF(tgtIndex) < srcCDF(srcVal)
            tgtIndex = tgtIndex + 1;
        end
        map(srcVal) = tgtIndex - 1;
    end

    % 应用映射生成匹配后的图像
    matchedImage = map(double(sourceImage) + 1);
end
