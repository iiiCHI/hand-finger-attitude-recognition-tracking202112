%% 用来展示滤波前后震颤信号差异的。

clear;

% UserId = 8;
% 记录特征的矩阵
Features_Rst = [];%是难度x轮数x人数x6x特征个数
Features_Act = [];%是难度x轮数x人数x6x特征个数
Features_Tar = [];%是难度x轮数x人数x6x特征个数

% RstStart,RstEnd
Rst = [];
Act = [];
Tar = [];
AFRst = [];% 滤波后的Rst
AFAct = [];% 滤波后的Act
AFTar = [];% 滤波后的Tar

%FistFea = reshape(Features_Tar(1,:,:,:,:),[30*9,6*14]);//用来提取某一个难度的特征的
                                         % 怎么分的呢，先按照轮数，1-30轮，往后是人数，
                                         % 后面是，先按照IMU的6个参数，再按照特征去划分。

                                         
% for UserId = 7:7                     
for UserId = 6:6
    disp(['UserId:',num2str(UserId)])
    % 指定CSV文件路径
    % 使用readmatrix函数读取CSV文件数据（包括表头）
    dataIMU     = readmatrix(['./DataSet/UserId_',num2str(UserId),'_RowImu.csv']);
    dataAction  = readmatrix(['./DataSet/UserId_',num2str(UserId),'_UserAction.csv']);
    CountFeature = 1;
    
    fileAfterImu = ones(size(dataIMU,1),6);

    %% 进行滤波
     % Example: Replace outliers with the mean of their neighbors
    for j = 1:6
        % Adjust as needed    
        for i = 2:(length(dataIMU(:,j)) - 1)
            if j<=3 && abs(dataIMU(i,j)-dataIMU(i-1,j)) > 1 && abs(dataIMU(i,j)-dataIMU(i+1,j)) > 1
                dataIMU(i,j) = mean([dataIMU(i-1,j), dataIMU(i+1,j)]);
            elseif abs(dataIMU(i,j)-dataIMU(i-1,j)) > 10 && abs(dataIMU(i,j)-dataIMU(i+1,j)) > 10
                dataIMU(i,j) = mean([dataIMU(i-1,j), dataIMU(i+1,j)]);
            end
        end
    
        % 示例数据
        f1 = 4; % 高通滤波器截止频率，单位Hz
        f2 = 12; % 低通滤波器截止频率，单位Hz
        Fs = 222;
        % 示例陀螺仪数据
        gyroscope_data = dataIMU(:,j);
        
        % 设计10阶巴特沃斯高通滤波器
        order = 10;
        [b_high, a_high] = butter(order, f1/(Fs/2), 'high');
        
        % 应用高通滤波器
        highpass_filtered_data = filter(b_high, a_high, gyroscope_data);
        
        % 设计10阶巴特沃斯低通滤波器
        [b_low, a_low] = butter(order, f2/(Fs/2), 'low');
        
        % 应用低通滤波器
        fileAfterImu(:,j) = filter(b_low, a_low, highpass_filtered_data);
    end
    %%  获取第14列的数据
    numRows = size(dataAction, 1);
%         for index = 1:numRows
    for index = 1:1
        currentRow = dataAction(index, :);    
        if currentRow(8) == 0
            continue;
        end
        column14 = dataIMU(:, 14);  
        % 创建逻辑索引，找到满足条件的行
        logicalIndex = column14 > currentRow(3) & column14 < currentRow(4);
        % 使用逻辑索引筛选矩阵的行
        Rst = dataIMU(logicalIndex, 1:6);
        AFRst = fileAfterImu(logicalIndex, 1:6);
        % 创建逻辑索引，找到满足条件的行
        logicalIndex = column14 > currentRow(5) & column14 < currentRow(6);
        % 使用逻辑索引筛选矩阵的行
        Act = dataIMU(logicalIndex, 1:6);
        AFAct = fileAfterImu(logicalIndex, 1:6);
        % 创建逻辑索引，找到满足条件的行
        logicalIndex = column14 > currentRow(7) & column14 < currentRow(8);
        % 使用逻辑索引筛选矩阵的行
        Tar = dataIMU(logicalIndex, 1:6);    
        AFTar = fileAfterImu(logicalIndex, 1:6);
    end
    disp(['ID:',num2str(currentRow(1)),'  Round',num2str(currentRow(2))])
    
    titles = ["RT","IAT","PAT"];
    titlesIndex = ["加速度计x轴","加速度计y轴","加速度计z轴","陀螺仪x轴","陀螺仪y轴","陀螺仪z轴"];
    ylablesSet = ["加速度/(m/s^2)","角速度/(deg/s)"];
    figure;
    Row = [Act;];
    AfRow = [AFAct;];
    for i = 1:6
        subplot(2,3,i)
        plot((1:size(Row(:,i),1))/222,Row(:,i))
        hold on
        plot((1:size(Row(:,i),1))/222,AfRow(:,i))
        xlabel("时间/s")
        ylabel(ylablesSet(floor(i/4)+1))
        title([titles(2),titlesIndex(i)])
    end
    legend("滤波前信号","滤波后信号")
end

%% 准备区分不同的IAT
 %%  获取第14列的数据
    numRows = size(dataAction, 1);
%         for index = 1:numRows
    for index = 4:4
        currentRow = dataAction(index, :);
        column14 = dataIMU(:, 14);  
        % 创建逻辑索引，找到满足条件的行
        logicalIndex = column14 > currentRow(5) & column14 < currentRow(6);
        % 使用逻辑索引筛选矩阵的行
        IatHigh = dataIMU(logicalIndex, 1:6);
        AFIatHigh = fileAfterImu(logicalIndex, 1:6);


        currentRow = dataAction(index+10, :);
        column14 = dataIMU(:, 14);  
        % 创建逻辑索引，找到满足条件的行
        logicalIndex = column14 > currentRow(5) & column14 < currentRow(6);
        % 使用逻辑索引筛选矩阵的行
        IatMid = dataIMU(logicalIndex, 1:6);
        AFIatMid = fileAfterImu(logicalIndex, 1:6);


        currentRow = dataAction(index+20, :);
        column14 = dataIMU(:, 14); 
        % 创建逻辑索引，找到满足条件的行
        logicalIndex = column14 > currentRow(5) & column14 < currentRow(6);
        % 使用逻辑索引筛选矩阵的行
        IatLow = dataIMU(logicalIndex, 1:6);    
        AFIatLow = fileAfterImu(logicalIndex, 1:6);
    end
    disp(['ID:',num2str(currentRow(1)),'  Round',num2str(currentRow(2))])


titles = ["高","中","低"];
ylablesSet = ["加速度/(m/s^2)","角速度/(deg/s)"];
figure;
i = 2;

subplot(3,1,1)
RowData = AFIatHigh;
plot((1:size(RowData(:,i),1))/222,RowData(:,i))
xlabel("时间/s")
ylabel(ylablesSet(1))
title(titles(1))
xlim([0, size(RowData(:,i),1)/222]);


subplot(3,1,2)
RowData = AFIatMid;
plot((1:size(RowData(:,i),1))/222,RowData(:,i))
xlabel("时间/s")
ylabel(ylablesSet(1))
title(titles(2))
xlim([0, size(RowData(:,i),1)/222]);

subplot(3,1,3)
RowData = AFIatLow;
plot((1:size(RowData(:,i),1))/222,RowData(:,i))
xlabel("时间/s")
ylabel(ylablesSet(1))
title(titles(3))
xlim([0, size(RowData(:,i),1)/222]);

legend("震颤信号")

%% 准备画三个在同一幅图里

titles = ["RT","IAT","PAT"];
titlesIndex = ["加速度计x轴","加速度计y轴","加速度计z轴","陀螺仪x轴","陀螺仪y轴","陀螺仪z轴"];
ylablesSet = ["加速度/(m/s^2)","角速度/(deg/s)"];
figure;
i = 1;
Row = [AFRst;];
subplot(1,3,1)
plot((1:size(Row(:,i),1))/222,Row(:,i))
xlabel("时间/s")
ylabel(ylablesSet(floor(i/4)+1))
title("RT")
xlim([0, size(Row(:,i),1)/222]);
ylim([-0.1,0.1]);

Row = [AFAct;];
subplot(1,3,2)
plot((1:size(Row(:,i),1))/222,Row(:,i))
xlabel("时间/s")
ylabel(ylablesSet(floor(i/4)+1))
title("IAT")
xlim([0, size(Row(:,i),1)/222]);
ylim([-0.1,0.1]);

Row = [AFTar;];
subplot(1,3,3)
plot((1:size(Row(:,i),1))/222,Row(:,i))
xlabel("时间/s")
ylabel(ylablesSet(floor(i/4)+1))
title("PAT")
xlim([0, size(Row(:,i),1)/222]);
ylim([-0.1,0.1]);
