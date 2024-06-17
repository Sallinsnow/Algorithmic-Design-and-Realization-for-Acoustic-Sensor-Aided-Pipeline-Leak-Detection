function smoothedData = smoothSignal2(data, methods, windowSize, sigma)
    % smoothSignal 平滑处理信号
    % 输入:
    %   data - 原始数据向量
    %   methods - 使用的滤波方法列表，可以是 {'gaussian', 'median', 'movingAvg'}
    %   windowSize - 滤波器窗口大小
    %   sigma - 高斯滤波的标准差 (仅当使用高斯滤波时需要)
    % 输出:
    %   smoothedData - 平滑处理后的数据
    %   figHandle - 绘图句柄

    % 应用高斯滤波
    if any(strcmp(methods, 'gaussian'))
        len = max(6 * sigma, windowSize);  % 确保核长度至少与窗口大小一致
        if mod(len, 2) == 0
            len = len + 1;  % 保证长度为奇数
        end
        gaussWindow = fspecial('gaussian', [1 len], sigma);
        data = conv(data, gaussWindow, 'same');  % 应用高斯滤波
    end
        % % 绘制结果
    figure;
    plot(data);
    title([strjoin(methods, ' -> ') ' 结果1']);
    xlabel('样本索引');
    ylabel('信号幅值');

    % 继续应用其他滤波
    % for method = methods
    %     switch char(method)
    %         case 'median'
    %             data = medfilt1(data, windowSize);
    %             plotTitle = '中值滤波结果';
    % 
    %         case 'movingAvg'
    %             data = movmean(data, windowSize);
    %             plotTitle = '移动平均滤波结果';
    %     end
    % end

    smoothedData = data;

    % 绘制结果
    figure;
    plot(smoothedData);
    title([strjoin(methods, ' -> ') ' 结果2']);
    xlabel('样本索引');
    ylabel('信号幅值');
end
