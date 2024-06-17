function sig_out=loaddata(file_name_all, file_name, last_file_num, incident_start_pos, incident_end_pos)
% 加载并处理信号数据
% 输入参数：
% file_name_all - 包含所有文件信息的结构体数组
% file_name - 当前需要匹配的文件名
% last_file_num - 需要处理的文件数量
% incident_start_pos - 信号的起始位置
% incident_end_pos - 从信号末尾向前的结束位置

sig_out = [];  % 初始化输出信号数组
file_num = length(file_name_all);  % 获取文件数量


for loop1 = 1:file_num
    % 在文件名中搜索当前指定的文件名
    k = strfind(file_name_all(loop1).name, file_name);
    fprintf('正在检查: %s 与 %s\n', file_name_all(loop1).name, file_name);  % 调试输出
    if ~isempty(k)
        % 如果找到了匹配，加载匹配的文件
        fprintf('找到匹配文件：%s\n', file_name_all(loop1).name);  % 调试输出
        sig_out = load([file_name_all(loop1).folder, '\', file_name_all(loop1).name]);
        break;  % 找到匹配后退出循环
    end
end

if isempty(sig_out)
    error('未能加载任何数据。请检查文件名是否正确。');
end
% 检查信号向量是否为行向量，如果是则转置为列向量
if isvector(sig_out)
    if isrow(sig_out)
        sig_out = sig_out.';
    end
elseif size(sig_out, 2) >= 2
    % 如果信号是矩阵，只取第二列
    sig_out = sig_out(:,2);
    if isrow(sig_out)
        sig_out = sig_out.';
    end
else
    error('加载的数据不符合预期格式，无第二列数据');
end

% 获取信号长度
sig_point_num = length(sig_out);
start_pos = incident_start_pos;
end_pos_back = sig_point_num - incident_end_pos;

% 定义时间格式的正则表达式
pattern = '_20\d\d\d\d\d\d_\d\d\d\d';
for loop2 = 1:last_file_num
    % 应用正则表达式找到时间戳
    [startIndex,endIndex] = regexp(file_name, pattern);
    time1=file_name(startIndex:endIndex);
    t = datenum(datetime(time1,'InputFormat','_yyyyMMdd_HHmm'));
    file_name(startIndex:endIndex) = datetime(t+1.5/24/60,'ConvertFrom','datenum','Format','_yyyyMMdd_HHmm');
    
    for loop1 = 1:file_num
        % 再次在文件列表中查找更新后的文件名
        k = strfind(file_name_all(loop1).name, file_name);
        if ~isempty(k)
            sig_out_temp = load([file_name_all(loop1).folder, '\', file_name_all(loop1).name]);
            break;
        end
    end

    % 检查临时信号向量
    if isvector(sig_out_temp)
        if isrow(sig_out_temp)
            sig_out_temp = sig_out_temp.';
        end
    else
        sig_out_temp = sig_out_temp(:,2);
        if isrow(sig_out_temp)
            sig_out_temp = sig_out_temp.';
        end
    end
    
    % 连接信号数据
    sig_out = [sig_out; sig_out_temp];
end

% 安全检查起始和结束位置，确保不越界
if start_pos < 1
    start_pos = 1;
end
if end_pos_back > length(sig_out)
    end_pos_back = length(sig_out);
end

% 根据起始和结束位置截取信号
if start_pos <= length(sig_out) - end_pos_back
    sig_out = sig_out(start_pos:end-end_pos_back);
else
    sig_out = [];  % 如果条件不满足，返回空数组
end

end
