function model1(TA)
%% 数据分析
    num_samples = length(TA);      % 样本个数
    kim = 15;                      % 延时步长（kim个历史数据作为自变量）
    zim = 1;                       % 跨zim个时间点进行预测,预测间隔
    
    
    %% 划分数据集
    res = zeros(num_samples - kim - zim + 1, kim + 1);  % 初始化存储结构
    for i = 1: num_samples - kim - zim + 1
        res(i, :) = [reshape(TA(i: i + kim - 1), 1, kim), TA(i + kim + zim - 1)];
    end
    
    
    %% 划分训练集和测试集
    
    % 定义训练集和测试集的划分界限
    num_train = floor(0.75 * (num_samples - kim - zim + 1));  % 75% 作为训练数据
    
    P_train = res(1:num_train, 1:kim)';  % 训练数据的特征
    T_train = res(1:num_train, end)';    % 训练数据的目标值
    
    P_test = res(num_train+1:end, 1:kim)';  % 测试数据的特征
    T_test = res(num_train+1:end, end)';    % 测试数据的目标值
    
    
    %% 数据归一化
    [P_train, ps_input] = mapminmax(P_train, 0, 1);  % 归一化训练特征
    P_test = mapminmax('apply', P_test, ps_input);   % 应用相同的归一化到测试特征
    
    [t_train, ps_output] = mapminmax(T_train, 0, 1);  % 归一化训练目标
    t_test = mapminmax('apply', T_test, ps_output);   % 应用相同的归一化到测试目标
    
    %% 数据平铺
    % 将数据平铺成1维数据只是一种处理方式
    % 也可以平铺成2维数据，以及3维数据，需要修改对应模型结构
    % 但是应该始终和输入层数据结构保持一致
    M = size(P_train, 2);  % 计算训练样本的数量
    N = size(P_test, 2);   % 计算测试样本的数量
    
    P_train = double(reshape(P_train, 15, 1, 1, M));
    P_test = double(reshape(P_test, 15, 1, 1, N));
    
    t_train = t_train';
    t_test = t_test';
    
    %%  数据格式转换
    for i = 1 : M
        p_train{i, 1} = P_train(:, :, 1, i);
    end
    
    for i = 1 : N
        p_test{i, 1}  = P_test( :, :, 1, i);
    end
    % gpuDevice(1)  % 激活第一个 GPU 设备
    
    %%  创建模型

    % 检查训练次数文件是否存在
    countFile = 'trainCount1.txt';
    if isfile(countFile)
        fileId = fopen(countFile, 'r');  % 打开文件用于读取
        trainCount = fscanf(fileId, '%d');
        fclose(fileId);
    else
        trainCount = 0;  % 如果文件不存在，设置训练次数为0
    end

    modelName = 'trainedModel1.mat';
    layers = defineNetworkLayers();
    options = defineTrainingOptions();
    if trainCount == 0
        disp('Creating new network...');
        net = [];
    else
        disp('Loading existing network...');
        if isfile(modelName)
            load(modelName, 'net');
        else
            error('Model file does not exist. Set trainCount to 0 to create a new model.');
        end 
    end

    
    %%  训练模型

    net= trainNetwork(p_train, t_train, layers, options);
    %保存模型

    save(modelName, 'net');
    disp('Model1 saved successfully.');    
    % 更新训练次数
    trainCount = trainCount + 1;
    fileId = fopen(countFile, 'w');  % 打开文件用于写入
    fprintf(fileId, '%d', trainCount);
    fclose(fileId);
    disp('count1 saved successfully.');
    
    
    %%  仿真预测
    t_sim1 = predict(net, p_train);
    t_sim2 = predict(net, p_test );
    
    %%  数据反归一化
    T_sim1 = mapminmax('reverse', t_sim1, ps_output);
    T_sim2 = mapminmax('reverse', t_sim2, ps_output);
    
    % %%  均方根误差
    error1 = sqrt(sum((T_sim1' - T_train).^2) ./ M);
    error2 = sqrt(sum((T_sim2' - T_test ).^2) ./ N);

    %% 查看训练结果
    analyzeNetwork(net);

    % 绘制训练集预测结果对比
    figure;
    plot(1:M, T_train, 'r-', 1:M, T_sim1, 'b-', 'LineWidth', 1);
    legend('真实值', '预测值');
    xlabel('预测样本');
    ylabel('预测结果');
    title({'训练集预测结果对比'; ['RMSE=' num2str(error1)]});
    xlim([1, M]);
    grid on;
    
    % 绘制测试集预测结果对比
    figure;
    plot(1:N, T_test, 'r-', 1:N, T_sim2, 'b-', 'LineWidth', 1);
    legend('真实值', '预测值');
    xlabel('预测样本');
    ylabel('预测结果');
    title({'测试集预测结果对比'; ['RMSE=' num2str(error2)]});
    xlim([1, N]);
    grid on;

    %% 网络训练优化相关指标计算
    % R2
    R1 = 1 - norm(T_train - T_sim1')^2 / norm(T_train - mean(T_train))^2;
    R2 = 1 - norm(T_test  - T_sim2')^2 / norm(T_test  - mean(T_test ))^2;
    
    disp(['训练集数据的R2为：', num2str(R1)])
    disp(['测试集数据的R2为：', num2str(R2)])
    
    % MAE
    mae1 = sum(abs(T_sim1' - T_train)) ./ M ;
    mae2 = sum(abs(T_sim2' - T_test )) ./ N ;
    
    disp(['训练集数据的MAE为：', num2str(mae1)])
    disp(['测试集数据的MAE为：', num2str(mae2)])
    
    % MBE
    mbe1 = sum(T_sim1' - T_train) ./ M ;
    mbe2 = sum(T_sim2' - T_test ) ./ N ;
    
    disp(['训练集数据的MBE为：', num2str(mbe1)])
    disp(['测试集数据的MBE为：', num2str(mbe2)])
    
    %绘制散点图
    sz = 25;
    c = 'b';
    
    figure
    scatter(T_train, T_sim1, sz, c)
    hold on
    plot(xlim, ylim, '--k')
    xlabel('训练集真实值');
    ylabel('训练集预测值');
    xlim([min(T_train) max(T_train)])
    ylim([min(T_sim1) max(T_sim1)])
    title('训练集预测值 vs. 训练集真实值')
    
    figure
    scatter(T_test, T_sim2, sz, c)
    hold on
    plot(xlim, ylim, '--k')
    xlabel('测试集真实值');
    ylabel('测试集预测值');
    xlim([min(T_test) max(T_test)])
    ylim([min(T_sim2) max(T_sim2)])
    title('测试集预测值 vs. 测试集真实值')
end