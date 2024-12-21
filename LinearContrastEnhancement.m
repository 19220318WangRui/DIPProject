% 线性对比度增强函数
function enhancedImg = LinearContrastEnhancement(grayImg, param)
    % 获取灰度图像的最小值和最大值
    minVal = double(min(grayImg(:)));
    maxVal = double(max(grayImg(:)));

    % 线性变换的公式
    enhancedImg = (double(grayImg) - minVal) / (maxVal - minVal) * 255;

    % 将图像转为uint8类型
    enhancedImg = uint8(enhancedImg);
end