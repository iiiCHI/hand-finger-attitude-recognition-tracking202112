% 生成一个示例波形
signal = After_Rst; % 信号（正弦波 + 噪声）
t = 1:size(signal,1);
% 计算信号的ACF
lags = -length(t)+1:length(t)-1; % 计算所有可能的滞后值
[acf, lags] = xcorr(signal, 'coeff'); % 'coeff'选项用于标准化ACF

% 绘制信号和ACF
figure;

subplot(2, 1, 1);
plot(t, signal);
title('Example Signal');

subplot(2, 1, 2);
stem(lags, acf);
title('Autocorrelation Function (ACF)');
xlabel('Lag');
ylabel('Correlation Coefficient');

sgtitle('Signal and Autocorrelation Function');
