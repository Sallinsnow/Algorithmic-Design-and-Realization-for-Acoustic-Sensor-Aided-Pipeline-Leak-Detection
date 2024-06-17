function dataAnalysisModule()
    % 数据加载和模型加载
    [net1, net2,filesT1,filesT2] = loadDataAndModels();
    fs=100;
   for i = 1:length(filesT1)
        % 循环加载每一批数据
        dataPath = 'E:\本机\OneDrive\桌面\毕设代码\参数\';
        T1 = load(fullfile(dataPath, filesT1(i).name)).T1;
        T2 = load(fullfile(dataPath, filesT2(i).name)).T2;
        %对数据进行互相关计算，调整时域对齐
        % [T1, T2] = alignSequences(T1, T2);
        % T1=T1';
        % T2=T2';
        % 预测与绝对误差数据获得
        [pre1, absError1, isAnomaly1] = predictAndEvaluate(T1, net1);
        [pre2, absError2, isAnomaly2] = predictAndEvaluate(T2, net2);

        % 能量与能量异常值数据获得
        E1 = T1.^2;
        E2 = T2.^2;
        E1error = abnormalAnalyze(E1);
        E2error = abnormalAnalyze(E2);

        E1error1 = double(E1) .* double(E1error);
        E2error1 = double(E2) .* double(E2error);
        [E1_max, E1_max_idx] = findpeaks(E1error1, 'MinPeakHeight', 1e-6); % MinPeakHeight用于过滤由于乘以0造成的0值
        [E2_max, E2_max_idx] = findpeaks(E2error1, 'MinPeakHeight', 1e-6);

                
        % 转换索引为时间（假设采样率 fs 已知）
        E1_time_max = E1_max_idx / fs;  % 计算异常最大值对应的时间点
        E2_time_max = E2_max_idx / fs;
        
        % 控制台打印
        fprintf('疑似泄露的时间点（T1）：%.3f 秒，能量值：%.3f\n', E1_time_max, E1_max);
        fprintf('疑似泄露的时间点（T2）：%.3f 秒，能量值：%.3f\n', E2_time_max, E2_max);

        %% 数据可视化和存储结果
        figure(1);
        clf;  % 清除之前的图形，确保每次绘图都是清晰的
        set(gcf, 'Position', [0, 0, 1600, 800]); % 设置图形窗口大小
    
        % T1 传感器的预测值与实际值比较
        subplot(3, 2, 1);
        plot(pre1, 'b');
        hold on;
        % 删除实际值的前15个数据点
        T1 = T1(16:end);
        plot(T1, 'r');
        legend('预测值', '真实值');
        title('传感器T1 - 预测值与真实值比较');
        xlabel('时间');
        ylabel('值');
        hold off;
    
        % T1 传感器的绝对误差与异常区间
        subplot(3, 2, 3);
        plot(absError1, 'b');
        hold on;
        plot(find(isAnomaly1), absError1(isAnomaly1), 'ro');
        title('传感器T1 - 绝对误差与异常点');
        xlabel('时间');
        ylabel('绝对误差');
        hold off;
    
        % T1 传感器的能量与异常区间
        subplot(3, 2, 5);
        plot(E1, 'b');
        hold on;
        plot(find(E1error), E1(E1error), 'ro');
        plot(E1_max_idx, E1_max, 'ko', 'MarkerSize', 10, 'LineWidth', 2);  % 黑色圆圈标记最大点
        title('传感器T1 - 能量与异常点');
        xlabel('时间');
        ylabel('能量');
        hold off;
    
        % T2 传感器的预测值与实际值比较
        subplot(3, 2, 2);
        plot(pre2, 'b');
        hold on;
        % 删除实际值的前15个数据点
        T2 = T2(16:end);
        plot(T2, 'r');
        legend('预测值', '真实值');
        title('传感器T2 - 预测值与真实值比较');
        xlabel('时间');
        ylabel('值');
        hold off;
    
        % T2 传感器的绝对误差与异常区间
        subplot(3, 2, 4);
        plot(absError2, 'b');
        hold on;
        plot(find(isAnomaly2), absError2(isAnomaly2), 'ro');
        title('传感器T2 - 绝对误差与异常点');
        xlabel('时间');
        ylabel('绝对误差');
        hold off;
    
        % T2 传感器的能量与异常区间
        subplot(3, 2, 6);
        plot(E2, 'b');
        hold on;
        plot(find(E2error), E2(E2error), 'ro');
        plot(E2_max_idx, E2_max, 'ko', 'MarkerSize', 10, 'LineWidth', 2);  % 同上
        title('传感器T2 - 能量与异常点');
        xlabel('时间');
        ylabel('能量');
        hold off;

        % 保存图像
        savepathname = 'E:\本机\OneDrive\桌面\毕设代码\测试数据\判定结果\';
        saveas(figure(1), fullfile(savepathname, sprintf('result_image_%d.jpeg', i)), 'jpeg');

            disp("测试断点");
   end

    
    % 双传感器 一次判定，二次确认，三次交叉验证
    %decisionTreeProcess(sensorData1, sensorData2, pre1, pre2, isAnomaly1, isAnomaly2, E1, E2, E1error, E2error);

end





function [net1, net2,filesT1,filesT2] = loadDataAndModels()
    % 定义数据和模型的文件路径
    dataPath = 'E:\本机\OneDrive\桌面\毕设代码\参数\';

    % 加载传感器数据
    % 假设数据以 'T1_*' 和 'T2_*' 格式保存，对应两个传感器的数据
    filesT1 = dir(fullfile(dataPath, 'T1_*'));
    filesT2 = dir(fullfile(dataPath, 'T2_*'));

    % 加载LSTM模型
    net1 = load('trainedModelT1.mat', 'net').net;
    net2 = load('trainedModelT2.mat', 'net').net;
end


function [predictions, absError, isAnomaly] = predictAndEvaluate(sensorData, net)

    % 数据处理
    num_samples = length(sensorData);      % 样本个数
    kim = 15;                      % 延时步长（kim个历史数据作为自变量）
    zim = 1;                       % 跨zim个时间点进行预测,预测间隔
    
    % 划分数据集 特征加目标为一组
    res = zeros(num_samples - kim - zim + 1, kim);  % 初始化存储结构
    for i = 1: num_samples - kim - zim + 1
        res(i, :) = reshape(sensorData(i: i + kim - 1), 1, kim);
    end
    num = num_samples - kim - zim + 1;

    P = res(1:num, 1:kim)';   %数据的特征
    T = res(1:num, end)'; %数据的目标

    %% 数据归一化 懂得都懂
    [P,  ps_input] = mapminmax(P, 0, 1);  % 归一化特征
    [t, ps_output] = mapminmax(T, 0, 1);  % 归一化目标

    %% 数据平铺 变成一维数组
    M = size(P, 2);  % 计算数据样本的数量
    P = double(reshape(P, 15, 1, 1, M));
    %%  数据格式转换 变成一维元胞
    for i = 1 : M
        preparedData{i, 1} = P(:, :, 1, i);
    end
    % 返回处理好的数据和样本数量
    
    % 使用网络进行预测
    P = predict(net, preparedData);
    
    %反归一化
    predictions = mapminmax('reverse', P, ps_output);
    % 删除实际值的前15个数据点
    sensorData = sensorData(16:end);

    % 计算绝对误差
    % absError = abs(predictions - sensorData);
    absError = predictions - sensorData;

    % 使用异常分析函数来判定异常
    isAnomaly = abnormalAnalyze(absError);
end

function isAnomaly = abnormalAnalyze(absError)
    % 计算窗口的平均值和标准差
    window_mean = mean(absError);
    window_std = std(absError);

    % 设定阈值为平均值加上3倍的标准差
    % threshold = window_mean + 3 * window_std;
    % 设置上下阈值
    upperThreshold = window_mean + 3 * window_std; % 上阈值
    lowerThreshold = window_mean - 3 * window_std; % 下阈值

    % 比较每个点的误差是否大于阈值
    % isAnomaly = absError > threshold;
    isAnomaly = (absError > upperThreshold) | (absError < lowerThreshold);
end







