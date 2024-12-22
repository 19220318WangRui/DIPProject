function edges = applyLaplacian(inputImage)
    % Laplacian 算子 (Laplacian of Gaussian)
    kernel = [0 1 0; 1 -4 1; 0 1 0];
    
    % 转换为灰度图像（如果是彩色图像）
    if size(inputImage, 3) == 3
        inputImage = rgb2gray(inputImage);
    end
    
    % 应用 Laplacian 滤波器
    edges = conv2(double(inputImage), kernel, 'same');
    edges = uint8(edges);
end
