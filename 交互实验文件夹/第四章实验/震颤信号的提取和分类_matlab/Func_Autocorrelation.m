% **线性随机过程**的另一个特征是**自相关函数中振荡极值的指数衰减**。
% 
% 自相关函数的不对称衰减测量已被发现**可用于区分**生理性震颤和病理性震颤



% 生成一个示例信号
t = 0:0.01:1;  % 时间向量
signal = sin(2*pi*5*t) + 0.5*randn(size(t));  % 一个包含噪声的正弦信号

% 计算自相关函数
autocorr_values = xcorr(signal);

% 找到第一个最小值和第一个最大值的位置
[min_val, min_idx] = min(autocorr_values);
[max_val, max_idx] = max(autocorr_values);

% 计算幅度差
amplitude_difference = max_val - min_val;

% 输出结果
fprintf('第一个最小值的位置：%d，幅度：%f\n', min_idx, min_val);
fprintf('第一个最大值的位置：%d，幅度：%f\n', max_idx, max_val);
fprintf('幅度差：%f\n', amplitude_difference);


% 绘制自相关函数图
figure;

% 绘制自相关函数的曲线
subplot(2,1,1);
stem(autocorr_values);
title('自相关函数图');
xlabel('延迟');
ylabel('自相关幅度');

% 标记第一个最小值和第一个最大值
hold on;
stem(min_idx, min_val, 'r', 'LineWidth', 2);  % 第一个最小值
stem(max_idx, max_val, 'g', 'LineWidth', 2);  % 第一个最大值
hold off;

% 绘制信号的波形图
subplot(2,1,2);
plot(t, signal);
title('信号波形图');
xlabel('时间');
ylabel('信号幅度');

% 显示图例
legend({'信号'}, 'Location', 'Best');

% 调整图的布局
sgtitle('自相关函数及信号波形图');
