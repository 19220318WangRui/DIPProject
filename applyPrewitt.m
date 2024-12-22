function edges = applyPrewitt(inputImage)
    % Prewitt 算子
    kernelX = [-1 0 1; -1 0 1; -1 0 1];
    kernelY = [-1 -1 -1; 0 0 0; 1 1 1];
    
    % 转换为灰度图像（如果是彩色图像）
    if size(inputImage, 3) == 3
        inputImage = rgb2gray(inputImage);
    end
    
    % 计算梯度
    gradX = conv2(double(inputImage), kernelX, 'same');
    gradY = conv2(double(inputImage), kernelY, 'same');
    
    % 计算梯度的幅值
    edges = sqrt(gradX.^2 + gradY.^2);
    edges = uint8(edges);
end
