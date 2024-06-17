function [T_first_half, T_second_half] = deletenum(T)
    % 计算数组长度的一半
    halfIndex = floor(length(T) / 2);
    
    % 分割向量为两部分
    T_first_half = T(1:halfIndex);
    T_second_half = T(halfIndex+1:end);
    
    %% 调试代码，绘图方便查看

    
    %创建图形窗口并指定大小
    figure('Position', [100, 100, 1200, 400]);

    % 绘制第一部分向量（前半部分）
    subplot(1, 2, 1);
    plot(T_first_half, '-');  % 只使用线条来显示向量
    title('异常信号');
    ylim([min([T_first_half; T_second_half])-1, max([T_first_half; T_second_half])+1]); % 调整y轴范围以更好地查看向量

    % 绘制第二部分向量（后半部分）
    subplot(1, 2, 2);
    plot(T_second_half, '-');  % 只使用线条来显示向量
    title('正常信号');
    ylim([min([T_first_half; T_second_half])-1, max([T_first_half; T_second_half])+1]); % 使用与前半部分相同的y轴范围

    % 没有返回值，因为主要任务是展示和比较数据部分
end
