function [correlation, lags] = computeCrossCorrelation(x, y)
    % 确保输入是行向量
    if iscolumn(x)
        x = x';
    end
    if iscolumn(y)
        y = y';
    end
    
    % 获取序列长度
    nx = length(x);
    ny = length(y);
    
    % 计算互相关
    n = nx + ny - 1;  % 总长度
    correlation = ifft(fft(x, n) .* conj(fft(y, n)));
    
    % 互相关的输出通常需要对结果进行移动和修正
    correlation = fftshift(correlation);  % 使得负滞后和正滞后能正确显示
    correlation = correlation / max(abs(correlation));  % 归一化互相关值

    % 生成滞后向量
    lags = -(n-1)/2:(n-1)/2;  % 修正滞后计算，确保与correlation长度相同
end
