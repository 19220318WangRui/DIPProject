function lbpFeatures = computeLBP(inputImage)
    % 确保输入是灰度图像
    if size(inputImage, 3) == 3
        inputImage = rgb2gray(inputImage);  % 转换为灰度图像
    end
    
    % 获取图像的大小
    [rows, cols] = size(inputImage);
    
    % 初始化 LBP 特征图（去除边缘像素，进行 3x3 卷积）
    lbpImage = zeros(rows-2, cols-2);  

    % 遍历图像中每一个像素，计算其 LBP 值
    for i = 2:rows-1
        for j = 2:cols-1
            % 提取 3x3 邻域
            neighborhood = inputImage(i-1:i+1, j-1:j+1);
            center = neighborhood(2,2);  % 获取中心像素值

            % 将邻域像素与中心像素进行比较，生成二进制模式
            binaryPattern = neighborhood >= center;
            binaryPattern(2,2) = 0;  % 中心像素不参与计算

            % 将二进制模式转换为十进制值
            lbpValue = 0;  % 初始化为零
            for k = 1:9
                lbpValue = lbpValue + binaryPattern(k) * 2^(k-1);
            end

            % 存储 LBP 值（这里确保只有一个数值）
            lbpImage(i-1, j-1) = lbpValue;
        end
    end
    
    % 返回整个图像的 LBP 特征图
    lbpFeatures = lbpImage;
end
