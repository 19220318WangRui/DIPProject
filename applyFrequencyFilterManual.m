function outputImage = applyFrequencyFilterManual(inputImage)
    % 检查是否为彩色图像
    if size(inputImage, 3) == 3
        % 初始化输出图像
        outputImage = zeros(size(inputImage), 'like', inputImage);
        % 对每个通道分别进行频域滤波
        for channel = 1:3
            outputImage(:,:,channel) = frequencyFilterGray(inputImage(:,:,channel));
        end
    else
        % 如果是灰度图像，直接滤波
        outputImage = frequencyFilterGray(inputImage);
    end
end

function filteredChannel = frequencyFilterGray(inputGray)
    % 将图像转换为频域
    imageFFT = fft2(double(inputGray));
    imageFFTShifted = fftshift(imageFFT);

    % 构造一个简单的低通滤波器（圆形区域）
    [rows, cols] = size(inputGray);
    centerX = round(rows / 2);
    centerY = round(cols / 2);
    radius = 30; % 滤波器半径

    % 创建滤波器掩码
    [X, Y] = meshgrid(1:cols, 1:rows);
    distance = sqrt((X - centerX).^2 + (Y - centerY).^2);
    lowPassFilter = double(distance <= radius);

    % 应用滤波器
    filteredFFTShifted = imageFFTShifted .* lowPassFilter;

    % 转回空域
    filteredFFT = ifftshift(filteredFFTShifted);
    filteredChannel = ifft2(filteredFFT);
    filteredChannel = abs(filteredChannel); % 获取绝对值以消除复数部分
    filteredChannel = uint8(filteredChannel); % 确保图像为 uint8 类型
end
