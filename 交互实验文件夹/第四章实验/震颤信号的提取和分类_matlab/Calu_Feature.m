
function [Feature,bandpass_filtered_data] = Calu_Feature(acceleration_data,Fs)
    % Example: Replace outliers with the mean of their neighbors
    % Adjust as needed    
    for i = 2:(length(acceleration_data) - 1)
        if abs(acceleration_data(i)) > 500
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
    freq_range_2 = [6, 12]; % 6Hz到12Hz

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

    %% 计算偏度和峰度
    Feature = [Feature,Func_GetFeature(data)];
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

