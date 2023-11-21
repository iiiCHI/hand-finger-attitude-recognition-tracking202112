fs = 222;

for Fature_index = 1:6
    [PsLog_Tar(:,Fature_index),Psf_Tar(:,Fature_index)] = Func_GetPowerSpectrum(Tar(:,Fature_index),222);
    [PsLog_Act(:,Fature_index),Psf_Act(:,Fature_index)] = Func_GetPowerSpectrum(Act(:,Fature_index),222);
    [PsLog_Rst(:,Fature_index),Psf_Rst(:,Fature_index)] = Func_GetPowerSpectrum(Rst(:,Fature_index),222);

    [PsLog_After_Tar(:,Fature_index),Psf_After_Tar(:,Fature_index)] = Func_GetPowerSpectrum(After_Tar(:,Fature_index),222);
    [PsLog_After_Act(:,Fature_index),Psf_After_Act(:,Fature_index)] = Func_GetPowerSpectrum(After_Act(:,Fature_index),222);
    [PsLog_After_Rst(:,Fature_index),Psf_After_Rst(:,Fature_index)] = Func_GetPowerSpectrum(After_Rst(:,Fature_index),222);
end


% 如何做呢？画一下试试。
% 将数据分成12组

%% 这个是用来绘制直方图的
% num_bins = 12;
% figure;
% for Fature_index = 1:6
%     % 画图，滤波前后的信号
%     subplot(6,2,Fature_index*2-1)
%     [counts, edges] = histcounts(After_Rst(:,Fature_index), num_bins);
%     % 绘制直方图
%     bar(edges(1:end-1), counts, 'hist');
% 
%     xlabel('数据范围');
%     ylabel('频数');
%     title('Rst数据直方图');
%     subplot(6,2,Fature_index*2)
% 
%     [counts, edges] = histcounts(Rst(:,Fature_index), num_bins);
%     % 绘制直方图
%     bar(edges(1:end-1), counts, 'hist');
% end
% 
% figure;
% for Fature_index = 1:6
%     % 画图，滤波前后的信号
%     subplot(6,2,Fature_index*2-1)
%     [counts, edges] = histcounts(After_Act(:,Fature_index), num_bins);
%     % 绘制直方图
%     bar(edges(1:end-1), counts, 'hist');
% 
%     xlabel('数据范围');
%     ylabel('频数');
%     title('Act数据直方图');
%     subplot(6,2,Fature_index*2)
% 
%     [counts, edges] = histcounts(Act(:,Fature_index), num_bins);
%     % 绘制直方图
%     bar(edges(1:end-1), counts, 'hist');
% end
% 
% figure;
% for Fature_index = 1:6
%     % 画图，滤波前后的信号
%     subplot(6,2,Fature_index*2-1)
%     [counts, edges] = histcounts(After_Tar(:,Fature_index), num_bins);
%     % 绘制直方图
%     bar(edges(1:end-1), counts, 'hist');
% 
%     xlabel('数据范围');
%     ylabel('频数');
%     title('Tar数据直方图');
%     subplot(6,2,Fature_index*2)
% 
%     [counts, edges] = histcounts(Tar(:,Fature_index), num_bins);
%     % 绘制直方图
%     bar(edges(1:end-1), counts, 'hist');
% end
%% 这个是用来绘制频谱图的
figure;
for Fature_index = 1:6
    % 画图，滤波前后的信号
    subplot(6,2,Fature_index*2-1)
    plot(Psf_Rst(:,Fature_index),PsLog_Rst(:,Fature_index),'blue')
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    title('Rst');
    subplot(6,2,Fature_index*2)
    plot(Psf_After_Rst(:,Fature_index),PsLog_After_Rst(:,Fature_index),'red')
    legend('滤波后');
    xlabel('时间 s');
    ylabel([num2str(Fature_index),'角速度 deg/s']);
end
figure;
for Fature_index = 1:6
    % 画图，滤波前后的信号
    subplot(6,2,Fature_index*2-1)
    plot(Psf_Act(:,Fature_index),PsLog_Act(:,Fature_index),'blue')
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    title('Act');
    subplot(6,2,Fature_index*2)
    plot(Psf_After_Act(:,Fature_index),PsLog_After_Act(:,Fature_index),'red')
    legend('滤波后');
    xlabel('时间 s');
    ylabel([num2str(Fature_index),'角速度 deg/s']);
end
figure;
for Fature_index = 1:6
    % 画图，滤波前后的信号
    subplot(6,2,Fature_index*2-1)
    title('Tar');
    plot(Psf_Tar(:,Fature_index),PsLog_Tar(:,Fature_index),'blue')
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    title('Tar');
    subplot(6,2,Fature_index*2)
    plot(Psf_After_Tar(:,Fature_index),PsLog_After_Tar(:,Fature_index),'red')
    legend('滤波后');
    xlabel('时间 s');
    ylabel([num2str(Fature_index),'角速度 deg/s']);
end