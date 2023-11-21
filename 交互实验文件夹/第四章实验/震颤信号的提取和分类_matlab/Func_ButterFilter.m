%% 该方程是为了查看，原先的波形、功率谱等情况。

clear;
UserId = 8;
% 使用readmatrix函数读取CSV文件数据（包括表头）
dataIMU     = readmatrix(['./DataSet/UserId_',num2str(UserId),'_RowImu.csv']);
dataAction  = readmatrix(['./DataSet/UserId_',num2str(UserId),'_UserAction.csv']);



% 记录特征的矩阵
Features_Rst = [];%是6x人数x特征个数
Features_Act = [];%是6x人数x特征个数
Features_Tar = [];%是6x人数x特征个数
CountFeature = 1;
% 获取矩阵的行数
numRows = size(dataAction, 1);
% for index = 1:numRows
for index = 7
    currentRow = dataAction(index, :);    
    if currentRow(8) == 0
        continue;
    end
    % 获取第14列的数据
    column14 = dataIMU(:, 14);    
    % RstStart,RstEnd
    Rst = [];
    Act = [];
    Tar = [];
    
    
    % 创建逻辑索引，找到满足条件的行
    logicalIndex = column14 > currentRow(3) & column14 < currentRow(4);
    % 使用逻辑索引筛选矩阵的行
    Rst = dataIMU(logicalIndex, :);
    % 创建逻辑索引，找到满足条件的行
    logicalIndex = column14 > currentRow(5) & column14 < currentRow(6);
    % 使用逻辑索引筛选矩阵的行
    Act = dataIMU(logicalIndex, :);
    % 创建逻辑索引，找到满足条件的行
    logicalIndex = column14 > currentRow(7) & column14 < currentRow(8);
    % 使用逻辑索引筛选矩阵的行
    Tar = dataIMU(logicalIndex, :);
    
    
% % %     % 现在就使用一条波形的数据，就是第一条，的yaw角数据，
    Acc_Rst = sqrt(Rst(:,1).*Rst(:,1)+Rst(:,2).*Rst(:,2)+Rst(:,3).*Rst(:,3));
    Acc_Act = sqrt(Act(:,1).*Act(:,1)+Act(:,2).*Act(:,2)+Act(:,3).*Act(:,3));
    Acc_Tar = sqrt(Tar(:,1).*Tar(:,1)+Tar(:,2).*Tar(:,2)+Tar(:,3).*Tar(:,3));

    for Fature_index = 1:6
        [Features_Tar(CountFeature,Fature_index,:),After_Tar(:,Fature_index),Tar(:,Fature_index)] = Calu_Feature(Tar(:,Fature_index),222);
        [Features_Act(CountFeature,Fature_index,:),After_Act(:,Fature_index),Act(:,Fature_index)] = Calu_Feature(Act(:,Fature_index),222);
        [Features_Rst(CountFeature,Fature_index,:),After_Rst(:,Fature_index),Rst(:,Fature_index)] = Calu_Feature(Rst(:,Fature_index),222);
    end
    CountFeature = CountFeature+1;
end

% 均方根是均方根的平均强度（Mean Intensity，MI）：
% 这是用来量化震颤强度的参数。
% MI是三个轴上均方根（RMS）值的平均值。
% 在震颤分析中，RMS通常用来表示信号的振幅。
% 在Matlab中，你可以使用rms函数来计算信号的均方根值。
% 颤抖的主频率（Dominant Frequency of Tremor，FT）：
% 
% 这是用来量化震颤频率的参数。
% 使用SPECTROGRAM函数来生成时间-频率谱图，从中估计颤抖的主频率。

% wlable = ['x','y','z'];
% 
% AGIndex = 3;
% FeaIndex = 9;%1均值,2均方根,3-5四分位点【1，2，3】，6标准差，7峰值，8峰峰值，4-6hz强度，6-12hz强度、颤抖的主频率（Dominant Frequency of Tremor，FT）
% figure;
% for AGIndex = 4:6
%     subplot(3,1,AGIndex-3);
%     hold on
% %     plot(sort(Features_Act(:,AGIndex,FeaIndex),'descend'))
% %     plot(sort(Features_Rst(:,AGIndex,FeaIndex),'descend'))
% %     plot(sort(Features_Tar(:,AGIndex,FeaIndex),'descend'))
%     plot(Features_Act(:,AGIndex-3,FeaIndex))
%     plot(Features_Rst(:,AGIndex-3,FeaIndex))
%     plot(Features_Tar(:,AGIndex-3,FeaIndex))
%     % 添加标题和标签
% %     title(['陀螺仪',wlable(AGIndex-3),'轴：静止性震颤信号（4Hz-6Hz）']);
%     title(['陀螺仪',wlable(AGIndex-3),'轴：运动性震颤信号（6Hz-12hz）']);    
% end
% % 添加图例
% xlabel('交互轮数序号');
% legend('intention tremor', 'res area', 'target area');


figure;
for Fature_index = 1:6
    % 画图，滤波前后的信号
    subplot(6,2,Fature_index*2-1)
    plot((1:size(After_Rst,1))/222,Rst(:,Fature_index),'blue')
    legend('滤波前');
    ylabel([num2str(Fature_index),'角速度 deg/s']);
    title('Rst');
    subplot(6,2,Fature_index*2)
    plot((1:size(After_Rst,1))/222,After_Rst(:,Fature_index),'red')
    legend('滤波后');
    xlabel('时间 s');
    ylabel([num2str(Fature_index),'角速度 deg/s']);
end
figure;
for Fature_index = 1:6
    % 画图，滤波前后的信号
    subplot(6,2,Fature_index*2-1)
    plot((1:size(After_Act,1))/222,Act(:,Fature_index),'blue')
    legend('滤波前');
    ylabel([num2str(Fature_index),'角速度 deg/s']);
    title('Act');
    subplot(6,2,Fature_index*2)
    plot((1:size(After_Act,1))/222,After_Act(:,Fature_index),'red')
    legend('滤波后');
    xlabel('时间 s');
    ylabel([num2str(Fature_index),'角速度 deg/s']);
end
figure;
for Fature_index = 1:6
    % 画图，滤波前后的信号
    subplot(6,2,Fature_index*2-1)
    title('Tar');
    plot((1:size(After_Tar,1))/222,Tar(:,Fature_index),'blue')
    legend('滤波前');
    ylabel([num2str(Fature_index),'角速度 deg/s']);
    title('Tar');
    subplot(6,2,Fature_index*2)
    plot((1:size(After_Tar,1))/222,After_Tar(:,Fature_index),'red')
    legend('滤波后');
    xlabel('时间 s');
    ylabel([num2str(Fature_index),'角速度 deg/s']);
end
% AGIndex = 6;
% FeaIndex = 4;%1均值,均方根,2-4四分位点【1，2，3】，5标准差，6峰值，7峰峰值，4-6hz强度，6-12hz强度
% for FeaIndex = 1:10
%     figure(FeaIndex);
%     subplot(3,1,1);
%     plot(Features_Act(:,AGIndex,FeaIndex))
%     figure(FeaIndex);
%     subplot(3,1,2);
%     plot(Features_Rst(:,AGIndex,FeaIndex))
%     figure(FeaIndex);
%     subplot(3,1,3);
%     plot(Features_Tar(:,AGIndex,FeaIndex))
% end


function [Feature,bandpass_filtered_data,acceleration_data] = Calu_Feature(acceleration_data,Fs)
    % Example: Replace outliers with the mean of their neighbors
    % Adjust as needed    
    for i = 2:(length(acceleration_data) - 1)
        if abs(acceleration_data(i)-acceleration_data(i-1)) > 20 && abs(acceleration_data(i-1)-acceleration_data(i+1))<10
            acceleration_data(i) = mean([acceleration_data(i-1), acceleration_data(i+1)]);
        end
    end
    
    
    % 示例数据
    f1 = 4; % 高通滤波器截止频率，单位Hz
    f2 = 12; % 低通滤波器截止频率，单位Hz
    
    % 示例陀螺仪数据
    gyroscope_data = acceleration_data;
    
    % 设计10阶巴特沃斯高通滤波器
    order = 10;
    [b_high, a_high] = butter(order, f1/(Fs/2), 'high');
    
    % 应用高通滤波器
    highpass_filtered_data = filter(b_high, a_high, gyroscope_data);
    
    % 设计10阶巴特沃斯低通滤波器
    [b_low, a_low] = butter(order, f2/(Fs/2), 'low');
    
    % 应用低通滤波器
    bandpass_filtered_data = filter(b_low, a_low, highpass_filtered_data);

    %% 输出原始信号和滤波后信号

    % 设置采样率
    Fs = 222; % Hz
    
    % 生成示例数据（用你的实际数据替代这一部分）
    data = bandpass_filtered_data; % 示例数据
    
    % 时域特征
    mean_value = mean(data);
    %variance = var(data);
    mean_intensity  = mean(rms(data)); %求均方根的
    std_deviation = std(data);
    % 时域特征的四分位点
    quartiles = prctile(data, [25, 50, 75]);
    peak_value = max(data);
    peak_to_peak = peak_value - min(data);
    

    Feature(1:8) = [mean_value,mean_intensity,quartiles,std_deviation,peak_value,peak_to_peak];

%     disp('时域特征:');
%     disp(['均值: ', num2str(mean_value)]);
%     disp(['方差: ', num2str(variance)]);
%     disp(['标准差: ', num2str(std_deviation)]);
%     disp(['峰值: ', num2str(peak_value)]);%峰值（Peak Value）： 信号的峰值是信号振幅的最大值。对于周期性信号，它表示信号在一个周期内的最大正或负振幅。
%     disp(['峰-峰值: ', num2str(peak_to_peak)]);%峰-峰值（Peak-to-Peak Value）： 信号的峰-峰值是信号振幅的峰值与最小值之间的差值。它反映了信号在一个周期内的总振幅范围，即信号从最小值到最大值的全幅范围。
%     

    % 频域特征
    nfft = length(data);
    frequencies = (0:nfft-1)*(Fs/nfft); % 计算频率
    power_spectrum = abs(fft(data, nfft)).^2/nfft; % 功率谱密度
  
    freq_range_1 = [4, 6]; % 4Hz到6Hz
    freq_range_2 = [4, 12]; % 6Hz到12Hz

    % 找到对应的频率索引
    freq_index_1 = frequencies >= freq_range_1(1) & frequencies <= freq_range_1(2);
    freq_index_2 = frequencies >= freq_range_2(1) & frequencies <= freq_range_2(2);
    
    % 计算功率谱均值
    power_range1 = mean(power_spectrum(freq_index_1));
    power_range2 = mean(power_spectrum(freq_index_2));
    
%     disp('频域特征:');
%     disp(['功率范围[4Hz~6Hz]: ', num2str(power_range1)]);
%     disp(['功率范围[6Hz~12Hz]: ', num2str(power_range2)]);

    % 求颤抖的主频率
    window = hamming(256);
    noverlap = 128;
    nfft = 1024;
    
    [S, F, T] = spectrogram(data, window, noverlap, nfft, Fs);
    
    % 找到每个时间窗口内的主频率
    [~, idx] = max(abs(S), [], 1);
    dominant_frequencies = F(idx);
    
    % 可以根据需要选择具体的时间点，或者对整个时间序列取平均值
    average_dominant_frequency = mean(dominant_frequencies);

    Feature = [Feature,power_range1,power_range2,average_dominant_frequency];

end

%% 绘制原始、高通滤波和带通滤波后的数据
% figure;
% subplot(3,1,1);
% plot(t, gyroscope_data);
% title('原始陀螺仪数据');
% xlabel('时间 (s)');
% ylabel('角速度');
% 
% subplot(3,1,2);
% plot(t, highpass_filtered_data);
% title('经过10阶巴特沃斯高通滤波后的数据');
% xlabel('时间 (s)');
% ylabel('角速度');
% 
% subplot(3,1,3);
% plot(t, bandpass_filtered_data);
% title('经过10阶巴特沃斯带通滤波后的数据');
% xlabel('时间 (s)');
% ylabel('角速度');