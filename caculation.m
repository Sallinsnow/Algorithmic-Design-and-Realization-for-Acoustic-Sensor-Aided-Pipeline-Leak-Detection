function  caculation(T)
%% 时域特征参数

    % 音波相关的取值
    %    detparam.DetTraingCellTime = 50;    %训练单元
    %    detparam.DetNumGuardCellTime = 10;  %保护单元
    %    detparam.DetrendWinTime=60; %去趋势窗口时间
    %    detparam.SmoothWinTime = 3; %平滑窗口时间
    %    detparam.IntegWinTime=5;    %积分窗口时间 
    %    detparam.DiffWinTime = 0;   %差分窗口时间
    %    detparam.DetectingThresholdFactor = 1225;   %检测阈值
    %    detparam.DetectingRankFactor = 10;  %检测排名阈值
    global width height;
    num= length(T);
    times = (0:num-1) * 0.01;
    MaxNumChanges = 4;

    %原图
    figure(1);set(gcf, 'Position', [100, 100, width, height]);
    subplot(3,3,1);
    plot(times,T); 
    title('原始数据');

    %平均值
    E = movmean(T,300);

    TFE = ischange(E, 'MaxNumChanges', MaxNumChanges);
    subplot(3,3,2);
    plot(times, E); hold on;
    plot(times(TFE), E(TFE), 'ro', 'LineWidth', 2); hold off;
    title('平均值','信号平均强度');
%方差
    D = movvar(T,300);

    TFD = ischange(D, 'MaxNumChanges', MaxNumChanges);
    subplot(3,3,3);
    plot(times, D); hold on;
    plot(times(TFD), D(TFD), 'ro', 'LineWidth', 2); hold off;
    title('方差','信号波动程度');

%均方根
    RMS = movrms(T,200);

    TFRMS = ischange(RMS, 'MaxNumChanges', MaxNumChanges);
    subplot(3,3,4);
    plot(times,RMS); hold on;
    plot(times(TFRMS), RMS(TFRMS), 'ro', 'LineWidth', 2); hold off;
    title('均方根','泄露引起波动的强度');
%能量
    P = T.^2; 
    % 计算平均值和标准差
    meanP = mean(P);
    stdP = std(P);
    % 设定阈值为平均值加上2倍的标准差（这个阈值可以根据需要调整）
    threshold = meanP + 2 * stdP;
    % 找到异常值
    outliers = P > threshold;
    subplot(3,3,5);
    plot(times, P); hold on;
    % 使用红色圆圈标记异常值
    plot(times(outliers), P(outliers), 'ro', 'LineWidth', 1);
    hold off;
    title('Power Signal');

    % subplot(3,3,5);
    % plot(times, P); hold on;
    % plot(find(errorp), P(errorp), 'ro', 'LineWidth', 1); hold off;
    % title('Power Signal');
%有效值
    R = movsqrt(T,300);

    TFR = ischange(R, 'MaxNumChanges', MaxNumChanges);
    subplot(3,3,6);
    plot(times, R); 
    hold on;
    plot(times(TFR), R(TFR), 'ro', 'LineWidth', 2); hold off;
    title('有效值','振动能量大小');
%% 形状特征参数
% 峭度
    K = calculate_moving_kurtosis(T,200);

    TFK = ischange(K, 'MaxNumChanges', MaxNumChanges);
    subplot(3,3,7);
    plot(times, K); hold on;
    plot(times(TFK), K(TFK), 'ro', 'LineWidth', 2); hold off;
    title('峭度','赋值分布状况');
%峰值系数
    peak_factor = calculate_moving_peak_factor(T,200);

    TFPEAK = ischange(peak_factor, 'MaxNumChanges', MaxNumChanges);
    subplot(3,3,8);
    plot(times, peak_factor); hold on;
    plot(times(TFPEAK), peak_factor(TFPEAK), 'ro', 'LineWidth', 2); hold off;
    title('峰值系数','信号幅值变化');
% 脉冲因子
    imf = moving_impulse_factor(T,500);
 

    TFIMF = ischange(imf, 'MaxNumChanges', MaxNumChanges);
    subplot(3,3,9);
    plot(times, imf); hold on;
    plot(times(TFIMF), imf(TFIMF), 'ro', 'LineWidth', 2); hold off;
    title('脉冲因子','泄露声波剧变冲击特性');
end

function moving_rms = movrms(data, window_size)
    % 计算移动窗口内的均方根
    % 参数:
    %     data: 输入的时间序列数据
    %     window_size: 移动窗口的大小
    % 返回值:
    %     moving_rms: 移动窗口内的均方根序列

    % 初始化移动均方根序列
    moving_rms = zeros(1, length(data));

    % 计算每个窗口内的移动均方根
    for i = 1:length(data)
        start_index = max(1, i - window_size + 1);
        end_index = min(length(data), i + window_size - 1);
        window_data = data(start_index:end_index);
        moving_rms(i) = rms(window_data);
    end
end

function moving_sqrt = movsqrt(data, window_size)
    % 计算移动窗口内的平方根
    % 参数:
    %     data: 输入的时间序列数据
    %     window_size: 移动窗口的大小
    % 返回值:
    %     moving_sqrt: 移动窗口内的平方根序列

    % 初始化移动平方根序列
    moving_sqrt = zeros(1, length(data));

    % 计算每个窗口内的移动平方根
    for i = 1:length(data)
        start_index = max(1, i - window_size + 1);
        end_index = min(length(data), i + window_size - 1);
        window_data = data(start_index:end_index);
        moving_sqrt(i) = sqrt(mean(window_data.^2));
    end
end

function moving_kurtosis = calculate_moving_kurtosis(data, window_size)
    % 计算移动窗口内的峭度
    % 参数:
    %     data: 输入的时间序列数据
    %     window_size: 移动窗口的大小
    % 返回值:
    %     moving_kurtosis: 移动窗口内的峭度序列

    % 初始化移动峭度序列
    moving_kurtosis = zeros(1, length(data));

    % 计算每个窗口内的移动峭度
    for i = 1:length(data)
        start_index = max(1, i - window_size + 1);
        end_index = min(length(data), i + window_size - 1);
        window_data = data(start_index:end_index);
        moving_kurtosis(i) = kurtosis(window_data);
        moving_kurtosis(i) = mean(window_data.^4).^(1/4);
    end
end

function moving_peak_factor = calculate_moving_peak_factor(data, window_size)
    % 计算移动峰值系数
    % 参数:
    %     data: 输入的时间序列数据
    %     window_size: 移动窗口的大小
    % 返回值:
    %     moving_peak_factor: 移动峰值系数序列

    % 初始化移动峰值系数序列
    moving_peak_factor = zeros(1, length(data));

    % 计算每个窗口内的移动峰值系数
    for i = 1:length(data)
        start_index = max(1, i - window_size + 1);
        end_index = min(length(data), i + window_size - 1);
        window_data = data(start_index:end_index);
        peak_value = max(window_data);
        below_value = min(window_data);
        moving_peak_factor(i) = sqrt(mean(window_data.^2))/(peak_value-below_value);
    end
end

function moving_impulse = moving_impulse_factor(data, window_size)
    % 计算移动脉冲因子
    % 参数:
    %     data: 输入的时间序列数据
    %     window_size: 移动窗口的大小
    % 返回值:
    %     moving_impulse: 移动脉冲因子序列

    % 初始化移动脉冲因子序列
    moving_impulse = zeros(1, length(data));
    
    % 计算每个窗口内的移动脉冲因子
    for i = 1:length(data)
        start_index = max(1, i - window_size + 1);
        end_index = min(length(data), i + window_size - 1);
        window_data = data(start_index:end_index);
        moving_impulse(i) = max(abs(window_data))/mean(abs(window_data));
    end
end