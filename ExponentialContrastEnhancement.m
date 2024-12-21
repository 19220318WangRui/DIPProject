% 指数对比度增强函数
function enhancedImg = ExponentialContrastEnhancement(grayImg, param)
    % 将灰度图像转为double类型
    grayImg = double(grayImg);

    % 计算指数增强的常数c
    c = 255 / exp(1); % 归一化常数

    % 应用指数变换
    enhancedImg = c * exp(grayImg / param);

    % 归一化到 [0, 255] 范围
    enhancedImg = uint8(enhancedImg);
end