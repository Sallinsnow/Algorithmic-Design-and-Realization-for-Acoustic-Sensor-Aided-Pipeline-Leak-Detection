function plotdata(actualValues, predictions)
    global width height;
    % 创建一个新的图形窗口
    figure(3);set(gcf, 'Position', [100 + 2 * (width + 20), 100, width, height]);
    % 绘制实际值
    plot(actualValues,'r', 'LineWidth', 1);
    hold on; % 保持当前图像，允许在同一图形上绘制额外的数据
    % 绘制预测值
    plot(predictions, 'b', 'LineWidth', 1);
    % 添加图例
    legend('实际值', '预测值');
    % 添加标题和轴标签
    title('实际值预测值比较');
    xlabel('时间');
    ylabel('赋值');
    % 开启网格
    grid on;
    % 保持图像
    hold off;
end