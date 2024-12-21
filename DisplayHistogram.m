function DisplayHistogram(image)
    % 转换为灰度图像
    grayImg = rgb2gray(image);

    % 计算灰度直方图
    histogram = zeros(1, 256); % 初始化直方图数组
    for i = 1:size(grayImg, 1)
        for j = 1:size(grayImg, 2)
            intensity = grayImg(i, j) + 1; % MATLAB 索引从 1 开始
            histogram(intensity) = histogram(intensity) + 1;
        end
    end

    % 绘制灰度直方图
    figure;
    bar(0:255, histogram, 'BarWidth', 1, 'FaceColor', 'k');
    title('灰度直方图');
    xlabel('灰度值');
    ylabel('像素数量');
    xlim([0 255]);
end
