clc;
clear;
close;
%% 定义全局变量，方便操作

%% 读取文件
xls_file = '96-97.xlsx';
xlspathname = 'E:\本机\OneDrive\桌面\毕设代码\数据文件\数据索引\'; %xlsx地址
savepathname = 'E:\本机\OneDrive\桌面\毕设代码\测试数据\图片记录\'; %图片存储地址

file_list0 = readcell([xlspathname, xls_file]);  %读取索引列表
tablelist = file_list0(1, :);    %提取样本索引表
file_list0(1, :) = [];   %删除样本索引表，留下数据 
% 过滤特定文件名
% pattern = 'OutDat_80';  %定义要匹配的模式
% file_list = file_list0(contains(file_list0(:, 1), pattern), :);
file_list = file_list0;

searchChar = '**/*.txt';    %搜索样本名
% pathname = 'E:\本机\OneDrive\桌面\毕设代码\数据文件\数据样本\阜康（80）-石化（90）\'; %txt文件地址
pathname = 'E:\本机\OneDrive\桌面\毕设代码\数据文件\数据样本\4#阀室（96）-风城首站（97）\'; %txt文件地址
file_name_all = dir([pathname, searchChar]);    %读取样本列表

%% 开始循环处理样本
data_file_num = size(file_list, 1);%读取样本数量

for loop_data_file = 1:2:data_file_num  %步长为2，因为样本按照索引以两个样本数据为一个处理对象
    %读取样本
    datainfo = file_list(loop_data_file, :);    %提取样本信息

    data_file1_name = file_list{loop_data_file, 1}; %提取样本1名
    data_file2_name = file_list{loop_data_file + 1, 1}; %提取样本2名

    last_file_num1 = file_list{loop_data_file, 4};  %提取样本1第四行，文件持续时间
    last_file_num2 = file_list{loop_data_file + 1, 4};  %提取样本2第四行，同理

    incident_start_pos1 = file_list{loop_data_file, 2}; %提取样本1第二行，泄漏开始时间
    incident_start_pos2 = file_list{loop_data_file + 1, 2}; %提取样本2第二行，同理

    incident_end_pos1 = file_list{loop_data_file, 3};   %提取样本1第三行，泄漏结束时间
    incident_end_pos2 = file_list{loop_data_file + 1, 3};   %提取样本2第三行，同理

    sampleT = file_list{loop_data_file, 5}; %提取样本1第五行，采样时间

%% 传感器1数据处理
    
    %读取样本1数据
    sig1 = loaddata(file_name_all, data_file1_name, last_file_num1, incident_start_pos1, incident_end_pos1);    
    time=(1:length(sig1))*sampleT/1000; %时间轴


    %数据处理
    MaxNumChanges=4;    %最大变化点数
    TF1 = ischange(sig1, 'MaxNumChanges', MaxNumChanges);   %检测样本1数据变化点
    sig1_detrend = detrend(sig1,'linear');   %线性去趋势

    
    % 应用高斯滤波，然后是中值和移动平均滤波
    T1= smoothSignal1(sig1_detrend, {'gaussian', 'median', 'movingAvg'}, 300, 50);

%% 传感器2数据处理
    
    sig2 = loaddata(file_name_all, data_file2_name, last_file_num2, incident_start_pos2, incident_end_pos2);    %读取样本1数据
    time=(1:length(sig2))*sampleT/1000; %时间轴


    %数据处理   
    MaxNumChanges=4;    %最大变化点数
    TF2 = ischange(sig2, 'MaxNumChanges', MaxNumChanges);   %检测样本1数据变化点
    sig2_detrend = detrend(sig2,'linear');   %线性去趋势

    % 应用高斯滤波，然后是中值和移动平均滤波
    T2= smoothSignal2(sig2_detrend, {'gaussian', 'median', 'movingAvg'}, 120, 50);


    %% 可视化
   
    % 计算第一、二子图（原始信号）的最大值和最小值  
    min_y_raw = min([min(sig1), min(sig2)]);
    max_y_raw = max([max(sig1), max(sig2)]);

    % 计算第三、四子图（处理后信号）的最大值和最小值  
    min_y_processed = min([min(T1), min(T2)]);
    max_y_processed = max([max(T1), max(T2)]);

    %可视化
    figure(1);  %打开画布1
    set(gcf,'Position',[0,0,1600,800]); %设置画布大小
    subplot(2, 2, 1);
    plot(time, sig1); 
    % hold on;
    % plot(time(TF1), sig1(TF1), 'ro', 'LineWidth', 2); hold off;
    title('传感器1原始信号');xlabel('时间(s)');ylabel('幅度');
    ylim([min_y_raw, max_y_raw]); % 设置纵坐标范围  

    subplot(2, 2, 3);
    plot(time, T1);
    title('处理后信号'); xlabel('时间(s)'); ylabel('幅度');
    ylim([min_y_processed, max_y_processed]); % 设置纵坐标范围  


    subplot(2, 2, 2);
    plot(time, sig2); 
    % hold on;
    % plot(time(TF2), sig2(TF2), 'ro', 'LineWidth', 2); hold off;
    title('传感器2原始信号');xlabel('时间(s)');ylabel('幅度');
    ylim([min_y_raw, max_y_raw]); % 设置纵坐标范围  

    subplot(2, 2, 4);
    plot(time, T2);
    title('处理后信号'); xlabel('时间(s)'); ylabel('幅度');
    ylim([min_y_processed, max_y_processed]); % 设置纵坐标范围  


    % 转换文件名，将下划线转义,保证格式
    formattedFilename1 = strrep(datainfo{1}, '_', '\_');
    sgtitle({[datainfo{end},'-',formattedFilename1]; ...
        [tablelist{5},':',num2str(datainfo{5}),'/', ...
        tablelist{7},':',num2str(datainfo{7}),'/', ...
        tablelist{9},':',num2str(datainfo{9}),'/', ...
        tablelist{10},':',num2str(datainfo{10})]; ...
        [tablelist{15},':',num2str(datainfo{15}),'/',...
        tablelist{17},':',num2str(datainfo{17})]}, ...
        'FontSize',10);

    saveas(figure(1), [savepathname, data_file1_name], 'jpeg'); %保存图片

    
    % 保存数据    
    filePath='E:\本机\OneDrive\桌面\毕设代码\参数';
    i=(1+loop_data_file)/2;
    filename1 = fullfile(filePath, sprintf('T1_%d.mat', i));
    save(filename1, 'T1');
    filename2 = fullfile(filePath, sprintf('T2_%d.mat', i));
    save(filename2, 'T2');
     disp("测试断点");
end
