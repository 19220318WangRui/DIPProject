% Add Noise to Image (Gaussian Noise)
function noisyImg = AddGaussianNoise(image, noiseLevel)
    % image: 输入的图像数据
    % noiseLevel: 噪声的标准差，控制噪声的强度
    
    % 获取图像的尺寸
    [height, width, numChannels] = size(image);
    
    % 生成高斯噪声
    % randn 生成标准正态分布的随机数
    noise = noiseLevel * randn(height, width, numChannels);
    
    % 将噪声添加到原图像上
    noisyImg = double(image) + noise;
    
    % 确保图像像素值在 [0, 255] 范围内
    noisyImg = uint8(min(max(noisyImg, 0), 255));
end
