function performanceMetrics(T_test, T_sim2, N, fileName)
    % 验证输入维度
    if numel(T_test) ~= numel(T_sim2)
        error('测试集的实际值与预测值向量必须长度相同。');
    end
    
    % 计算测试集的MSE及RMSE
    MSE_test = mean((T_test - T_sim2').^2);
    RMSE_test = sqrt(MSE_test);
    
    % 计算R²
    R2 = 1 - norm(T_test  - T_sim2')^2 / norm(T_test  - mean(T_test))^2;
    
    % 计算MAE
    MAE_test = sum(abs(T_sim2' - T_test)) / N;
    
    % 计算MBE
    MBE_test = sum(T_sim2' - T_test) / N;
    
    % 显示测试集的指标
    disp(['测试集R²: ', num2str(R2)]);
    disp(['测试集MAE: ', num2str(MAE_test)]);
    disp(['测试集MBE: ', num2str(MBE_test)]);
    
    % 将指标附加到文件
    if exist(fileName, 'file')
        fileID = fopen(fileName, 'a');
    else
        fileID = fopen(fileName, 'w');
        fprintf(fileID, '测试集MSE,测试集RMSE,测试集R²,测试集MAE,测试集MBE\n'); % 如果文件不存在，则写入表头
    end
    fprintf(fileID, '%f,%f,%f,%f,%f\n', MSE_test, RMSE_test, R2, MAE_test, MBE_test);
    fclose(fileID);
    
    % 绘制测试集的散点图
    figure;
    scatter(T_test, T_sim2, 25, 'b');
    hold on;
    plot(xlim, ylim, '--k');
    xlabel('测试集实际值');
    ylabel('测试集预测值');
    title('测试集预测值 vs. 实际值');
end
