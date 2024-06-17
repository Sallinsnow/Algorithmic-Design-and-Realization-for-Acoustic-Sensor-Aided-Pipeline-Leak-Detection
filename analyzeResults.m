
    clc;    
    clear;
    close all;

    % 窗口的宽度和高度
    global width;
    global height;
    width=550;
    height=450;
    %读取文件
    data_path = 'E:\本机\OneDrive\桌面\毕设代码\参数\';
    % 获取所有符合 'T*_*.mat' 模式的.mat文件
    files = dir(fullfile(data_path, 'T*_*'));
    
    %% 大循环，启动
for i = 1:length(files)

    data_file = fullfile(data_path, files(i).name); % 构造完整的文件路径
    file_data = load(data_file); % 加载文件到一个结构体
    
    
    % 单独处理变量 T1
    if isfield(file_data, 'T1')
        T1 = file_data.T1;
            caculation(T1);
        %网络测试，启动 
        pre=predictWithNetwork('trainedModelT1', T1);
        disp("T1测试断点");
        % 删除实际值的前15个数据点
        T1 = T1(16:end);
        e =abs(pre - T1);
        e2 = smoothdata(e, 'sgolay', 300);
        abp = abnormalAnalyze(e2,300);
        plotErrorWithAbnormalPoints(e2, abp);
        plotdata(T1,pre);
    end

        % 单独处理变量 T2
    if isfield(file_data, 'T2')
        T2 = file_data.T2;
        caculation(T2);
        %网络测试，启动
        pre=predictWithNetwork('trainedModel2', T2);
        disp("T2测试断点");
        % 删除实际值的前15个数据点
        T2 = T2(16:end);
        e =abs(pre - T2);
        e2 = smoothdata(e, 'sgolay', 300);
        abp = abnormalAnalyze(e2,300);
        plotErrorWithAbnormalPoints(e2, abp);
        plotdata(T2,pre);
    end


    disp("循环断点");



    close all;
end

    
    