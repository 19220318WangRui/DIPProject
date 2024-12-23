classdef ImageProcessingApp < matlab.apps.AppBase

    % Properties
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        OpenImageButton            matlab.ui.control.Button
        ShowHistogramButton        matlab.ui.control.Button
        EqualizeHistogramButton    matlab.ui.control.Button
        MatchHistogramButton       matlab.ui.control.Button
        ContrastEnhanceButton      matlab.ui.control.Button
        ContrastMethodDropdown     matlab.ui.control.DropDown
        ContrastParameterInput     matlab.ui.control.NumericEditField
        ScaleImageButton           matlab.ui.control.Button
        ScaleFactorInput           matlab.ui.control.NumericEditField
        RotateImageButton          matlab.ui.control.Button
        RotationAngleInput         matlab.ui.control.NumericEditField
        AddNoiseButton             matlab.ui.control.Button
        NoiseParameterInput        matlab.ui.control.NumericEditField
        FilterButton               matlab.ui.control.Button
        FilterMethodDropdown       matlab.ui.control.DropDown
        EdgeDetectionButton        matlab.ui.control.Button
        EdgeMethodDropdown         matlab.ui.control.DropDown
        ExtractTargetButton        matlab.ui.control.Button
        FeatureImageButton         matlab.ui.control.Button
        FeatureTargetButton        matlab.ui.control.Button
        FeatureImageMethodDropdown  matlab.ui.control.DropDown
        FeatureTargetMethodDropdown matlab.ui.control.DropDown
        ImageAxes                  matlab.ui.control.UIAxes
    end

    properties (Access = private)
        ImageData  %原始图像
    end

    %其他属性
    properties (Access = public)
        TargetImageData   %目标图像数据（新增的属性）
    end

    % 各功能的回调函数
    methods (Access = private)

        % 打开图像回调函数
        function OpenImageCallback(app, ~)
            [file, path] = uigetfile({'*.jpg;*.png;*.bmp'}, '选择图片');
            if isequal(file, 0)
                return;
            end
            app.ImageData = imread(fullfile(path, file));
            imshow(app.ImageData, 'Parent', app.ImageAxes);
        end

        % 展示灰度直方图回调函数
        function ShowHistogramCallback(app, ~)
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end
            grayImg = rgb2gray(app.ImageData);
            figure;
            imhist(grayImg);
            title('灰度直方图');
        end

        %直方图均衡化回调函数
        function EqualizeHistogramCallback(app, ~)
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end
            grayImg = rgb2gray(app.ImageData);
            equalizedImg = histeq(grayImg);
            imshow(equalizedImg, 'Parent', app.ImageAxes);
        end

        %直方图匹配回调函数
        function MatchHistogramCallback(app, ~)
            % 检查是否加载了源图像
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载源图像！', '错误');
                return;
            end
            % 弹出对话框让用户选择目标图像
            [filename, filepath] = uigetfile({'*.jpg;*.png;*.bmp', '图片文件 (*.jpg, *.png, *.bmp)'; '*.*', '所有文件 (*.*)'}, '选择目标图像');
            % 如果用户没有选择文件，则返回
            if filename == 0
                return;
            end
            % 加载目标图像
            targetImagePath = fullfile(filepath, filename);
            targetImage = imread(targetImagePath);
            % 确保目标图像是灰度图
            if size(targetImage, 3) > 1
                targetImage = rgb2gray(targetImage);
            end
            % 将目标图像存储到 app 对象的 TargetImageData 属性中
            app.TargetImageData = targetImage;
            % 调用直方图匹配函数
            matchedImage = HistogramMatchingOptimized(app.ImageData, app.TargetImageData);
            % 显示匹配后的图像
            imshow(matchedImage, 'Parent', app.ImageAxes);
            % 提示用户操作成功
            uialert(app.UIFigure, '直方图匹配完成！', '提示');
        end

        %对比度增强回调函数
        function ContrastEnhanceCallback(app, ~)
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end
            % 获取用户选择的增强方法
            method = app.ContrastMethodDropdown.Value;
            % 获取用户输入的增强参数
            param = app.ContrastParameterInput.Value;
            if isempty(param) || param <= 0
                uialert(app.UIFigure, '请输入有效参数！', '错误');
                return;
            end
            % 将源图像转换为灰度图
            grayImg = rgb2gray(app.ImageData);
            % 根据选择的增强方法执行不同的对比度增强
            switch method
                case '线性'
                    enhancedImg = LinearContrastEnhancement(grayImg);
                case '对数'
                    enhancedImg = LogarithmicContrastEnhancement(grayImg, param);
                case '指数'
                    enhancedImg = ExponentialContrastEnhancement(grayImg, param);
                otherwise
                    return;
            end
            % 显示增强后的图像
            imshow(enhancedImg, 'Parent', app.ImageAxes);
        end

        % 缩放图像回调函数
        function ScaleImageCallback(app, ~)
            % 确保图像已加载
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end

            % 获取用户输入的缩放系数
            scaleFactor = app.ScaleFactorInput.Value;
            if isempty(scaleFactor) || scaleFactor <= 0
                uialert(app.UIFigure, '请输入有效缩放系数！', '错误');
                return;
            end
            % 获取原图像的尺寸
            [origHeight, origWidth, numChannels] = size(app.ImageData);
            % 计算目标图像的尺寸
            newHeight = round(origHeight * scaleFactor);
            newWidth = round(origWidth * scaleFactor);
            % 使用插值缩放图像，保持图像的质量
            scaledImg = imresize(app.ImageData, [newHeight, newWidth]);
            % 获取显示区域的大小
            axesPos = app.ImageAxes.Position;
            % 设置图像的大小和位置，使其居中显示
            imagePos = [axesPos(1) + (axesPos(3) - newWidth) / 2, ...
                axesPos(2) + (axesPos(4) - newHeight) / 2, ...
                newWidth, newHeight];
            % 隐藏坐标轴
            axis(app.ImageAxes, 'off');
            % 显示缩放后的图像
            imshow(scaledImg, 'Parent', app.ImageAxes);
            % 调整显示区域以适应图像
            set(app.ImageAxes, 'Position', imagePos);
        end

        % 旋转图像回调函数
        function RotateImageCallback(app, ~)
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end
            angle = app.RotationAngleInput.Value;
            rotatedImg = imrotate(app.ImageData, angle);
            imshow(rotatedImg, 'Parent', app.ImageAxes);
        end

        % 加噪（高斯法）
        function AddNoiseCallback(app, ~)
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end
            noiseLevel = app.NoiseParameterInput.Value;
            if isempty(noiseLevel) || noiseLevel <= 0
                uialert(app.UIFigure, '请输入有效噪声系数！', '错误');
                return;
            end
            noisyImg = imnoise(app.ImageData, 'gaussian', 0, noiseLevel);
            imshow(noisyImg, 'Parent', app.ImageAxes);
        end

        % 滤波回调函数
        function FilterCallback(app)
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end
            % 获取用户选择的滤波方式
            filterMethod = app.FilterMethodDropdown.Value;
            switch filterMethod
                case '空域滤波'
                    % 调用空域滤波函数
                    filteredImage = applySpatialFilterManual(app.ImageData);
                case '频域滤波'
                    % 调用频域滤波函数
                    filteredImage = applyFrequencyFilterManual(app.ImageData);
                otherwise
                    uialert(app.UIFigure, '请选择有效的滤波方式！', '错误');
                    return;
            end
            % 显示滤波后的图像
            imshow(filteredImage, 'Parent', app.ImageAxes);
        end


        % 边缘提取
        function EdgeDetectionCallback(app, ~)
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end
            method = app.EdgeMethodDropdown.Value;
            grayImg = rgb2gray(app.ImageData);  % 转换为灰度图像（如果是彩色图像）
            switch method
                case 'Roberts'
                    edges = applyRoberts(grayImg);
                case 'Prewitt'
                    edges = applyPrewitt(grayImg);
                case 'Sobel'
                    edges = applySobel(grayImg);
                case 'Laplacian'
                    edges = applyLaplacian(grayImg);
                otherwise
                    return;
            end
            imshow(edges, 'Parent', app.ImageAxes);
        end

        % 提取目标回调函数
        function ExtractTargetCallback(app, ~)
            % 检查是否已加载图像
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end
            % 将图像转换为灰度图像
            grayImage = rgb2gray(app.ImageData);
            % 使用 Canny 边缘检测提取图像边缘
            edges = edge(grayImage, 'Canny');
            % 对边缘图像进行形态学操作，以填充目标区域
            se = strel('disk', 2);  % 创建一个结构元素，这里用的是半径为2的圆形元素
            dilatedEdges = imdilate(edges, se);  % 膨胀操作，填充边缘
            % 使用区域填充去除内部小孔
            filledEdges = imfill(dilatedEdges, 'holes');
            % 对图像进行清理，去除小的区域
            cleanedImage = bwareaopen(filledEdges, 500);  % 去除面积小于500的区域
            % 提取目标区域的边界
            targetRegion = bwboundaries(cleanedImage, 'noholes');  % 获取目标区域边界
            % 如果没有找到目标区域，提示用户
            if isempty(targetRegion)
                uialert(app.UIFigure, '未找到目标区域！', '错误');
                return;
            end
            % 显示提取的目标区域
            figure;
            imshow(cleanedImage);
            title('提取的目标区域');
            % 在原图中显示目标区域
            % 通过在原图上绘制目标区域的边界来突出显示目标
            figure;
            imshow(app.ImageData);  % 显示原图
            hold on;
            for k = 1:length(targetRegion)
                boundary = targetRegion{k};
                plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);  % 绘制绿色边界
            end
            hold off;
        end

        % 对图像进行特征提取
        function FeatureExtractionCallback(app, isTarget)
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end
            % 获取图像数据
            inputImage = app.ImageData;
            % 获取用户选择的特征提取方法（LBP 或 HOG）
            method = app.FeatureImageMethodDropdown.Value;  % 从下拉框中获取方法
            % 根据选择的特征提取方法进行特征提取
            switch method
                case 'LBP'
                    features = computeLBP(inputImage);  % 调用 LBP 计算函数
                case 'HOG'
                    features = computeHOG(inputImage);  % 调用 HOG 计算函数
                otherwise
                    uialert(app.UIFigure, '请选择有效的特征提取方法！', '错误');
                    return;
            end
            % 显示特征图（此处假设你想显示 LBP 或 HOG 特征）
            figure;
            imshow(features, []);  % 用imshow来显示特征图
            title([method, ' 特征图']);
        end

        function TargetExtractionCallback(app, isTarget)
            % 检查是否已加载图像
            if isempty(app.ImageData)
                uialert(app.UIFigure, '请先加载图像！', '错误');
                return;
            end
            inputImage = app.ImageData;
            % 将图像转换为灰度图像
            grayImage = rgb2gray(inputImage);
            % 使用 Canny 边缘检测提取图像边缘
            edges = edge(grayImage, 'Canny');
            % 对边缘图像进行形态学操作，以填充目标区域
            se = strel('disk', 2);  % 创建一个结构元素，这里用的是半径为2的圆形元素
            dilatedEdges = imdilate(edges, se);  % 膨胀操作，填充边缘
            % 使用区域填充去除内部小孔
            filledEdges = imfill(dilatedEdges, 'holes');
            % 对图像进行清理，去除小的区域
            cleanedImage = bwareaopen(filledEdges, 500);  % 去除面积小于500的区域
            % 提取目标区域的边界
            targetRegion = bwboundaries(cleanedImage, 'noholes');  % 获取目标区域边界
            % 如果没有找到目标区域，提示用户
            if isempty(targetRegion)
                uialert(app.UIFigure, '未找到目标区域！', '错误');
                return;
            end
            % 创建一个与原图大小相同的掩膜
            targetMask = false(size(inputImage, 1), size(inputImage, 2));  % 初始化掩膜
            % 生成掩膜：只对找到的目标区域生成掩膜
            for k = 1:length(targetRegion)
                boundary = targetRegion{k};
                % 确保目标边界坐标是整数，避免因坐标错误导致创建过大掩膜
                x = round(boundary(:,2));  % x 坐标
                y = round(boundary(:,1));  % y 坐标
                % 将目标区域对应的像素置为1（目标部分）
                targetMask = targetMask | poly2mask(x, y, size(inputImage, 1), size(inputImage, 2));
            end
            % 可视化提取的目标区域
            figure;
            imshow(targetMask);
            title('提取的目标区域掩膜');
            % 在原图上展示提取的目标区域
            figure;
            imshow(inputImage);
            hold on;
            % 用红色框标记目标区域
            [rows, cols] = find(targetMask);
            plot(cols, rows, 'r.', 'MarkerSize', 1);
            hold off;
            title('原图中的目标区域');
            % 提取目标区域图像
            targetImage = inputImage .* uint8(targetMask);  % 提取目标区域
            % 在提取目标后，进行特征提取
            if isTarget
                % 根据用户选择的特征提取方法（HOG 或 LBP）
                method = app.FeatureTargetMethodDropdown.Value;  % 获取用户选择的方法
                switch method
                    case 'HOG'
                        % 计算 HOG 特征
                        features = computeHOG(targetImage);
                        % 可视化 HOG 特征
                        figure;
                        imshow(features, []);  % 用imshow来显示特征图
                        title('HOG 特征图');
                    case 'LBP'
                        % 计算 LBP 特征
                        features = computeLBP(targetImage);
                        % 可视化 LBP 特征
                        figure;
                        imshow(features, []);  % 用imshow来显示特征图
                        title('LBP 特征图');
                    otherwise
                        uialert(app.UIFigure, '请选择有效的特征提取方法！', '错误');
                end
            end
        end
    end

    % App Initialization
    methods (Access = public)
        function app = ImageProcessingApp
            % Create UI Figure
            app.UIFigure = uifigure('Name', '图像处理', 'Position', [100, 100, 1200, 700]);
            % Axes
            app.ImageAxes = uiaxes(app.UIFigure, 'Position', [50, 350, 1100, 300]);
            % First row
            app.OpenImageButton = uibutton(app.UIFigure, 'push', 'Text', '打开图片', 'Position', [50, 300, 100, 30], 'ButtonPushedFcn', @(btn, event) OpenImageCallback(app));
            app.ShowHistogramButton = uibutton(app.UIFigure, 'push', 'Text', '显示灰度直方图', 'Position', [160, 300, 150, 30], 'ButtonPushedFcn', @(btn, event) ShowHistogramCallback(app));
            app.EqualizeHistogramButton = uibutton(app.UIFigure, 'push', 'Text', '直方图均衡化', 'Position', [320, 300, 150, 30], 'ButtonPushedFcn', @(btn, event) EqualizeHistogramCallback(app));
            app.MatchHistogramButton = uibutton(app.UIFigure, 'push','Text', '直方图匹配','Position', [480, 300, 150, 30],'ButtonPushedFcn', @(btn, event) MatchHistogramCallback(app));
            % Second row
            app.ContrastEnhanceButton = uibutton(app.UIFigure, 'push', 'Text', '对比度增强', 'Position', [50, 250, 100, 30], 'ButtonPushedFcn', @(btn, event) ContrastEnhanceCallback(app));
            app.ContrastMethodDropdown = uidropdown(app.UIFigure, 'Position', [160, 250, 150, 30], 'Items', {'线性', '对数', '指数'});
            app.ContrastParameterInput = uieditfield(app.UIFigure, 'numeric', 'Position', [320, 250, 100, 30]);
            % Third row
            app.ScaleImageButton = uibutton(app.UIFigure, 'push', 'Text', '缩放图像', 'Position', [50, 200, 100, 30], 'ButtonPushedFcn', @(btn, event) ScaleImageCallback(app));
            app.ScaleFactorInput = uieditfield(app.UIFigure, 'numeric', 'Position', [160, 200, 100, 30]);
            app.RotateImageButton = uibutton(app.UIFigure, 'push', 'Text', '旋转图像', 'Position', [320, 200, 100, 30], 'ButtonPushedFcn', @(btn, event) RotateImageCallback(app));
            app.RotationAngleInput = uieditfield(app.UIFigure, 'numeric', 'Position', [430, 200, 100, 30]);
            % Fourth row
            app.AddNoiseButton = uibutton(app.UIFigure, 'push', 'Text', '添加噪声', 'Position', [50, 150, 100, 30],'ButtonPushedFcn', @(btn, event) AddNoiseCallback(app));
            app.NoiseParameterInput = uieditfield(app.UIFigure, 'numeric', 'Position', [160, 150, 100, 30]);
            app.FilterButton = uibutton(app.UIFigure, 'push', 'Text', '滤波', 'Position', [320, 150, 100, 30],'ButtonPushedFcn', @(btn, event) FilterCallback(app));
            app.FilterMethodDropdown = uidropdown(app.UIFigure, 'Position', [430, 150, 100, 30],'Items', {'空域滤波', '频域滤波'});
            % Fifth row
            app.EdgeDetectionButton = uibutton(app.UIFigure, 'push', 'Text', '边缘提取', 'Position', [50, 100, 100, 30], 'ButtonPushedFcn', @(btn, event) EdgeDetectionCallback(app));
            app.EdgeMethodDropdown = uidropdown(app.UIFigure, 'Position', [160, 100, 150, 30], 'Items', {'Roberts', 'Prewitt', 'Sobel', 'Laplacian'});
            app.ExtractTargetButton = uibutton(app.UIFigure, 'push', 'Text','提取目标',  'Position', [320, 100, 100, 30],'ButtonPushedFcn', @(btn, event) ExtractTargetCallback(app));
            % Sixth row
            app.FeatureImageButton = uibutton(app.UIFigure, 'push', 'Text', '特征提取（图像）', 'Position', [50, 50, 150, 30], 'ButtonPushedFcn', @(btn, event) FeatureExtractionCallback(app, false));
            app.FeatureImageMethodDropdown = uidropdown(app.UIFigure, 'Position', [220, 50, 100, 30], 'Items', {'LBP', 'HOG'}, 'Value', 'LBP');
            app.FeatureTargetButton = uibutton(app.UIFigure, 'push', 'Text', '特征提取（目标）', 'Position', [350, 50, 150, 30], 'ButtonPushedFcn', @(btn, event) TargetExtractionCallback(app, true));
            app.FeatureTargetMethodDropdown = uidropdown(app.UIFigure, 'Position', [520, 50, 100, 30], 'Items', {'LBP', 'HOG'}, 'Value', 'LBP');
        end
    end
end
