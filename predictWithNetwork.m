function P = predictWithNetwork(modelFileName, TB)
    % 加载训练好的网络模型
    load(modelFileName, 'net');
    % 数据处理
    [preparedData, S]= prepareDataForPrediction(TB);
    % 使用网络进行预测
    p = predict(net, preparedData);
    %反归一化
    P = mapminmax('reverse', p, S);
end

function [p,ps_output]= prepareDataForPrediction(TB)
    % 数据分析
    num_samples = length(TB);      % 样本个数
    kim = 15;                      % 延时步长（kim个历史数据作为自变量）
    zim = 1;                       % 跨zim个时间点进行预测,预测间隔
    
    % 划分数据集 特征加目标为一组
    res = zeros(num_samples - kim - zim + 1, kim);  % 初始化存储结构
    for i = 1: num_samples - kim - zim + 1
        res(i, :) = reshape(TB(i: i + kim - 1), 1, kim);
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
        p{i, 1} = P(:, :, 1, i);
    end
    % 返回处理好的数据和样本数量
end

