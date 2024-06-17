function trainlstmmodel1()
    clc;
    close all;

    % data_path = 'E:\本机\OneDrive\桌面\毕设代码\参数\';
    % files = dir(fullfile(data_path, 'T*_*'));

    data_path = 'E:\本机\OneDrive\桌面\毕设代码\参数\';
    files = dir(fullfile(data_path, 'T*_*'));
    filenames = {files.name};
    sorted_filenames = natsortfiles(filenames);
    % 现在 sorted_filenames 将按照自然数顺序排列

    process_files(sorted_filenames, data_path);
end

function process_files(sorted_filenames, data_path)
    % 迭代已排序的文件名数组
    for i = 1:length(sorted_filenames)
        try
            % 拼接完整的文件路径
            full_path = fullfile(data_path, sorted_filenames{i});
            % 处理单个文件
            process_single_file(full_path);
        catch e
            % 记录错误日志
            log_error(sorted_filenames{i}, e.message);
        end
    end
end


function process_single_file(full_path)
    % 直接使用完整的文件路径加载数据
    file_data = load(full_path);

    % 指定需要处理的数据字段
    fields = {'T1', 'T2'};
    
    % 遍历每个字段，检查是否存在，并处理
    for field = fields
        if isfield(file_data, field{1})
            % 提取字段数据
            data = file_data.(field{1});

            % 数据预处理（假设 deletenum 函数返回处理后的数据）
            [TB, TA] = deletenum(data);

            % 使用处理后的数据训练 LSTM 模型
            trainLSTMModel(TA, field{1});
        end
    end
end


function trainLSTMModel(TA, sensor_id)
    % 数据预处理和模型训练
    [p_train, t_train, p_test, t_test,ps_output] = transformData(TA);
    modelName = ['trainedModel', sensor_id, '.mat'];
    net = createOrLoadLSTMModel(modelName, p_train, t_train,sensor_id);
    performPredictions(net, p_train, t_train, p_test, t_test, ps_output, sensor_id);
end


function [p_train, t_train, p_test, t_test,ps_output] = transformData(TA)
    %数据预处理
    num_samples = length(TA);
    kim = 15;  % 延时步长
    zim = 1;   % 预测间隔

    %划分数据集
    res = zeros(num_samples - kim - zim + 1, kim + 1);
    for i = 1:num_samples - kim - zim + 1
        res(i, :) = [reshape(TA(i:i + kim - 1), 1, kim), TA(i + kim + zim - 1)];
    end

    %划分训练集和测试集
    num_train = floor(0.75 * (num_samples - kim - zim + 1));
    P_train = res(1:num_train, 1:kim)';% 训练数据的特征
    T_train = res(1:num_train, end)';% 训练数据的目标值
    P_test = res(num_train + 1:end, 1:kim)';
    T_test = res(num_train + 1:end, end)';

    %数据归一化
    [P_train, ps_input] = mapminmax(P_train, 0, 1);
    P_test = mapminmax('apply', P_test, ps_input);
    [t_train, ps_output] = mapminmax(T_train, 0, 1);
    t_test = mapminmax('apply', T_test, ps_output);

    %数据格式转换为适合神经网络的格式 数据平铺
    M = size(P_train, 2);
    N = size(P_test, 2);
    P_train = double(reshape(P_train, 15, 1, 1, M));
    P_test = double(reshape(P_test, 15, 1, 1, N));
    t_train = t_train';
    t_test = t_test';
    
    %数据格式转换成元胞
    for i = 1:M
        p_train{i, 1} = P_train(:, :, 1, i);
    end
    for i = 1:N
        p_test{i, 1} = P_test(:, :, 1, i);
    end

end

function net = createOrLoadLSTMModel(modelName, p_train, t_train,sensor_id)
    % 检查模型文件是否存在
    if exist(modelName, 'file')
        load(modelName, 'net');
        disp(['加载现有网络 ', sensor_id, '...']);
        layers = defineNetworkLayers();
        options = defineTrainingOptions();
        net = trainNetwork(p_train, t_train, layers, options);
        save(modelName, 'net');
    else
        layers = defineNetworkLayers();
        options = defineTrainingOptions();
        disp(['创建新网络 ', sensor_id, '...']);
        net = trainNetwork(p_train, t_train, layers, options);
        save(modelName, 'net');
    end
end


function performPredictions(net, p_train, t_train, p_test, t_test, ps_output, sensor_id)
 % 执行预测
    t_sim_train = predict(net, p_train);
    t_sim_test = predict(net, p_test);

    % 数据反归一化
    T_sim_train = mapminmax('reverse', t_sim_train, ps_output);
    T_sim_test = mapminmax('reverse', t_sim_test, ps_output);
    T_train = mapminmax('reverse', t_train, ps_output);
    T_test = mapminmax('reverse', t_test, ps_output);

    % 计算均方误差
    trainMSE = mse(T_sim_train, T_train);
    testMSE = mse(T_sim_test, T_test);
    
    % % 显示预测结果
    % figure;
    % subplot(2,1,1);
    % plot(T_train, 'r');
    % hold on;
    % plot(T_sim_train, 'b');
    % legend('真实值', '预测值');
    % title([sensor_id, ' 训练数据预测']);
    % xlabel('样本编号');
    % ylabel('输出');
    % 
    % subplot(2,1,2);
    % plot(T_test, 'r');
    % hold on;
    % plot(T_sim_test, 'b');
    % legend('真实值', '预测值');
    % title([sensor_id, ' 测试数据预测']);
    % xlabel('样本编号');
    % ylabel('输出');
    
    % 输出误差信息
    disp(['训练集 MSE: ', num2str(trainMSE)]);
    disp(['测试集 MSE: ', num2str(testMSE)]);
end


function log_error(filename, message)
    % 记录错误到日志文件
    fid = fopen('error_log.txt', 'a');
    fprintf(fid, '%s: %s\n', filename, message);
    fclose(fid);
end

 function layers = defineNetworkLayers()
        layers = [
            sequenceInputLayer(15)              % 建立输入层
            lstmLayer(14, 'OutputMode', 'last')  % LSTM层
            reluLayer                           % Relu激活层
            fullyConnectedLayer(1)              % 全连接层
            regressionLayer];                   % 回归层
    end
    
    % 定义训练选项
function options = defineTrainingOptions()
        options = trainingOptions('adam', ...       % Adam 梯度下降算法
            'MaxEpochs', 1200, ...                  % 最大训练次数
            'InitialLearnRate', 0.005, ...           % 初始学习率
            'LearnRateSchedule', 'piecewise', ...   % 学习率下降
            'LearnRateDropFactor', 0.1, ...         % 学习率下降因子
            'LearnRateDropPeriod', 800, ...         % 经过 800 次训练后 学习率为 0.005 * 0.1
            'Shuffle', 'every-epoch', ...           % 每次训练打乱数据集
            'Plots', 'training-progress', ...       % 画出曲线
            'Verbose', false,...
            'ExecutionEnvironment', 'gpu');
    end
