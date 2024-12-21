% 对数对比度增强函数
function enhancedImg = LogarithmicContrastEnhancement(grayImg, param)
    % 将灰度图像转为double类型
    grayImg = double(grayImg);
    
    % 计算对数增强的常数c
    c = 255 / log(1 + double(max(grayImg(:))));

    % 应用对数变换
    enhancedImg = c * log(1 + grayImg * param);

    % 归一化到 [0, 255] 范围
    enhancedImg = uint8(enhancedImg);
end