function targetRegion = extractTarget(inputImage)
    % 假设目标是背景与前景的简单二值化
    grayImage = rgb2gray(inputImage);  % 转为灰度图像
    binaryImage = imbinarize(grayImage);  % 使用自动阈值化方法进行二值化

    % 提取目标区域（前景部分）
    targetRegion = binaryImage;  % 此处可以根据需要进一步处理（如去噪、边缘检测等）
    
    % 对提取的目标进行填充（可选）
    targetRegion = imfill(targetRegion, 'holes');  % 填充目标区域的孔洞
end
