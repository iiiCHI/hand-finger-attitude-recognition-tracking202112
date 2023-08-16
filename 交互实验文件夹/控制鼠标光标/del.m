

% 使用parfeval并发地运行ceshi函数
numWorkers = 4; % 假设有4个核心，可根据实际情况调整
pool = gcp('nocreate'); % 检查是否已存在并行池
if isempty(pool)
    pool = parpool(numWorkers); % 开启并行池
end

% 提交多个parfeval任务
futures = cell(numWorkers, 1);
for i = 1:numWorkers
    futures{i} = parfeval(pool, @ceshi,0);
end

% 等待所有任务完成
for i = 1:numWorkers
    fetchNext(futures{i});
end


function funcControlMouse(q_hand)
    % 导入Java的Robot类和Java的Point类
    import java.awt.Robot;
    import java.awt.MouseInfo;
    import java.awt.Point;
    import java.awt.event.InputEvent;
    % 将四元数转化为空间坐标
    x = [1,0,0];%转的话应该是正负吧，
    y = [0,1,0];
    z = [0,0,1];
    
    x = quatrotate(q_hand, x);%表示上下//体现为z轴转的角度
    y = quatrotate(q_hand, y);%表示翻滚//但是体现为x轴转的角度
    z = quatrotate(q_hand, z);%表示偏转//体现为y轴转的角度
    
%         disp(y(3));%X转看这个
%         disp(z(1));%Y转看这个
%         disp(x(2));%Z转看这个
    
    % 获取当前鼠标的位置
    mouseInfo = MouseInfo.getPointerInfo();
    currentLocation = mouseInfo.getLocation();
    currentX = currentLocation.getX();
    currentY = currentLocation.getY();
    % 让光标移动到目标位置
    robot.mouseMove(currentX+x(2)*10, currentY+y(3)*10);
end

function ceshi()
    for i = 1:100
        a = eul2quat([pi/8, 0, pi/8], 'XYZ');
        funcControlMouse(a);
        pause(0.1);
    end
end