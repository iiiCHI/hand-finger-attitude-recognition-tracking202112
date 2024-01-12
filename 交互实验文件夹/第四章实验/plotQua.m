% 生成一组包含100个连续的四元数
num_quaternions = 100;
delta_theta = 2*pi/num_quaternions;
theta_values = 0:delta_theta:(2*pi-delta_theta);

% 创建四元数数组
quaternions = [cos(theta_values'), sin(theta_values'), zeros(num_quaternions, 2)];

% 使用plot函数绘制四元数的轨迹
figure;
plot(quaternions);

% 设置图形标题和轴标签
title('Quaternion Trajectory');
xlabel('Index');
ylabel('Quaternion Value');

% 添加图例
legend('Real', 'i', 'j', 'k');
