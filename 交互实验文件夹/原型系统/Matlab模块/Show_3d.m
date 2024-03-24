
% 创建3D坐标轴
figure;
hold on;
% 设置坐标轴的范围
xlim([-10, 10]);
ylim([-10, 10]);
zlim([-10, 10]);
% 创建一个新的图形窗口，并关闭菜单栏和工具栏
fig = figure('MenuBar', 'none', 'ToolBar', 'none');

% 绘制3D坐标轴
plot3(0, 0, 0, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
% 添加坐标轴标签
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
% 添加网格
grid on;
% 设置图形的视角
view(-30, 10);
hold off;
