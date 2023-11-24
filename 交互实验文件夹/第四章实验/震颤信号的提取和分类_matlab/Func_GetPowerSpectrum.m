function [PSlog,PSf] = Func_GetPowerSpectrum(RowData,fs)
%FUNC_GETPOWERSPECTRUM 这个函数是用来求功率谱的，输入为原始数据，输出为功率谱结果
%   输入参数为：原始数据和采样率
    [PSlog,PSf] = pwelch(RowData, [], [], [], fs);
    PSlog = 10*log10(PSlog);
    % 计算功率谱密度
%     window = hann(256); % 汉宁窗口，你也可以选择其他窗口函数
%     noverlap = 128; % 重叠的样本数
%     nfft = 1024; % FFT的点数
%     
%     [PSlog,PSf] = pwelch(RowData, window, noverlap, nfft, fs);
    
%     Fs = fs;
%     % 频域特征
%     nfft = length(RowData);
%     PSf = (0:nfft-1)*(Fs/nfft); % 计算频率
%     PSlog = abs(fft(RowData, nfft)).^2/nfft; % 功率谱密度


% %% 傅里叶变化
%     Fs = fs;  % 采样率
%     % 计算傅里叶变换
%     N = length(RowData);
%     Data = fft(RowData);
%     
%     % 计算单侧频谱（去除对称部分）
%     PSlog = (1/(Fs*N)) * abs(Data(1:N/2+1)).^2;
%     
%     % 计算频率向量
%     PSf = (0:(N/2)) * (Fs/N);
%     PSf = PSf';
end

