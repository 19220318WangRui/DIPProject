% 对数对比度增强函数
function enhancedImg = LogarithmicContrastEnhancement(grayImg, param)
    % 检查输入图像的有效性
    if nargin < 2 || isempty(param)
        % 如果未提供参数，自动设置为图像灰度均值的倒数（增强平衡）
        param = 1 / mean(grayImg(:));
    end

    % 检查参数范围是否合理
    if param <= 0
        error('参数 param 必须为正数');
    end

    % 将灰度图像转为 double 类型
    grayImg = double(grayImg);

    % 计算对数增强的常数 c
    c = 255 / log(1 + max(grayImg(:))); % 动态归一化因子

    % 应用对数变换
    enhancedImg = c * log(1 + grayImg * param);

    % 将像素值裁剪到 [0, 255] 范围，避免溢出
    enhancedImg = max(0, min(255, enhancedImg));

    % 转换为 uint8 类型
    enhancedImg = uint8(enhancedImg);
end
