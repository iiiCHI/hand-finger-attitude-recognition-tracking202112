close all
% 生成一组包含100个连续的四元数
num_quaternions = 100;
delta_theta = 2*pi/num_quaternions;
theta_values = 0:delta_theta:(2*pi-delta_theta);

% 创建四元数数组
quaternions = [cos(theta_values'), sin(theta_values'), zeros(num_quaternions, 2)];

% 使用plot函数绘制四元数的轨迹
% 创建一个新的Figure
fig = figure(1);

% 设置MenuBar属性为'none'以关闭文件一栏
set(fig, 'MenuBar', 'none');

% 设置ToolBar属性为'none'以关闭图窗工具栏
set(fig, 'ToolBar', 'none');

plot(quaternions);

% 设置图形标题和轴标签
title('Quaternion Trajectory');
xlabel('Index');
ylabel('Quaternion Value');

% 添加图例
legend('Real', 'i', 'j', 'k');
