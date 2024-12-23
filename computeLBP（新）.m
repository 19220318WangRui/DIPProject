function features = computeLBP(inputImage)
    % 将图像转换为灰度图像（如果图像是彩色的）
    grayImage = rgb2gray(inputImage);
    
    % 获取图像的大小
    [rows, cols] = size(grayImage);
    
    % 初始化 LBP 特征图
    LBPImage = zeros(rows - 2, cols - 2); % 留出边缘，避免越界

    % LBP 算法：对每个像素周围 3x3 区域进行处理
    for i = 2:rows-1
        for j = 2:cols-1
            % 选择 3x3 区域，按顺序将中心点与其邻域像素进行比较
            neighborhood = grayImage(i-1:i+1, j-1:j+1);  % 提取 3x3 区域
            
            % 中心像素的灰度值
            centerPixel = neighborhood(2, 2);
            
            % 将邻域的像素值与中心像素值比较，生成二进制数
            binaryValues = neighborhood > centerPixel;
            
            % 将二进制数转换为十进制数
            LBPValue = binaryValues([1,2,3,4,6,7,8,9]);
            LBPValue = LBPValue * [2^7; 2^6; 2^5; 2^4; 2^3; 2^2; 2^1; 2^0];
            LBPValue = sum(LBPValue);
            
            % 存储计算出的 LBP 特征值
            LBPImage(i-1, j-1) = LBPValue;
        end
    end
    
    % 返回 LBP 特征图
    features = LBPImage;
end
