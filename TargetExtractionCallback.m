% 目标提取回调函数
function TargetExtractionCallback(app, isTarget)
    if isempty(app.ImageData)
        uialert(app.UIFigure, '请先加载图像！', '错误');
        return;
    end

    % 获取选择的特征提取方法（LBP 或 HOG）
    method = app.FeatureTargetMethodDropdown.Value;
    
    % 从图像中提取目标
    if isTarget
        % 提取目标区域（这里使用简单的二值化方法提取目标）
        targetRegion = extractTarget(app.ImageData);
    else
        targetRegion = app.ImageData;
    end

    % 根据选择的特征提取方法进行处理
    switch method
        case 'LBP'
            features = computeLBP(targetRegion);  % LBP 特征提取
        case 'HOG'
            features = computeHOG(targetRegion);  % HOG 特征提取
        otherwise
            uialert(app.UIFigure, '请选择有效的特征提取方法！', '错误');
            return;
    end
    
    % 显示提取到的特征图像
    imshow(features, 'Parent', app.ImageAxes);
end
