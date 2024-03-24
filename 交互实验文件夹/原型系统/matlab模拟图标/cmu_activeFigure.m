close all;
% 设置随机数种子以保证结果的可重复性
rng(42);

% 设置图形窗口
% 创建一个新的Figure
fig = figure(1);
% 设置MenuBar属性为'none'以关闭文件一栏
set(fig, 'MenuBar', 'none');

% 自动最小化
set(fig, 'WindowState', 'minimized');

% 设置ToolBar属性为'none'以关闭图窗工具栏
set(fig, 'ToolBar', 'none');

% 生成四条初始随机线
num_lines = 4;
lines = cell(1, num_lines);
for i = 1:num_lines
    x = rand(1, 10); % 生成初始x坐标
    y = rand(1, 10); % 生成初始y坐标
    lines{i} = plot(x, y, 'LineWidth', 2); % 绘制初始线条
    hold on;
end

% 设置时间步数
num_steps = 1000;

% 循环更新线条位置
for step = 1:num_steps
    for i = 1:num_lines
        % 随机更新线条位置
        lines{i}.XData = lines{i}.XData + randn(1, 10)*0.1; % 在x方向上加入随机偏移
        lines{i}.YData = lines{i}.YData + randn(1, 10)*0.1; % 在y方向上加入随机偏移
    end
    
    % 刷新图形
    drawnow;
    
    % 添加短暂延迟以模拟时间推进
    pause(0.1);
end
