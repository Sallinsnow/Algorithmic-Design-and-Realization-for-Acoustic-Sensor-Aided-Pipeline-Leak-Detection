function [adjustedT1, adjustedT2] = alignSequences(T1, T2)
    % 假设的数据生成
    fs = 100;               % 采样频率
    % 确定T1的长度，从而动态生成时间向量t
    nSamples = length(T1);  % T1的样本点数
    t = 0:1/fs:(nSamples-1)/fs;  % 动态时间向量，长度与T1相匹配
    f = 0.1;                % 信号频率

    % 接收输入数据
    x = T1';
    y = T2';  

    % 计算互相关
    [correlation, lags] = computeCrossCorrelation(x, y);
    [maxCorr, idx] = max(correlation);
    timeShift = lags(idx);

    % 根据时间延迟调整数据
    if timeShift > 0
        shiftedY = [zeros(1, timeShift), y(1:end-timeShift)];
        fprintf('序列y需要向右移动%d个采样点以最佳匹配序列x\n', timeShift);
    elseif timeShift < 0
        shiftedY = [y(-timeShift+1:end), zeros(1, -timeShift)];
        fprintf('序列y需要向左移动%d个采样点以最佳匹配序列x\n', abs(timeShift));
    else
        shiftedY = y;
        fprintf('序列y与序列x已对齐，无需移动\n');
    end

    % 控制台输出最大相关性和时间延迟
    timeShiftSeconds = timeShift / fs;
    fprintf('最大相关性为：%.2f\n', maxCorr);
    fprintf('对应的时间延迟为：%.3f 秒\n', timeShiftSeconds);

    % 绘制图像
    figure(2);
    subplot(3, 1, 1);
    plot(t, x, 'b', 'DisplayName', 'Signal x');
    hold on;
    plot(t, y, 'r', 'DisplayName', 'Original Signal y');
    title('Original Signals');
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    hold off;
    legend show;

    subplot(3, 1, 2);
    plot(t, x, 'b', 'DisplayName', 'Signal x');
    hold on;
    plot(t, shiftedY, 'g', 'DisplayName', 'Shifted Signal y');
    title('Adjusted Signals for Time Delay');
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    hold off;
    legend show;

    subplot(3, 1, 3);
    stem(lags, correlation, 'k');
    title('Cross-Correlation');
    xlabel('Lags');
    ylabel('Correlation Value');
    hold off;
    % 返回调整后的序列
    adjustedT1 = x;  % T1 remains unchanged
    adjustedT2 = shiftedY;  % T2 is adjusted
end
