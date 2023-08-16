function func_ControlMouse(q_hand)

    % 将四元数转化为空间坐标
    x = [1,0,0];%转的话应该是正负吧，
    y = [0,1,0];
    z = [0,0,1];
    
    x = quatrotate(q_hand, x);%表示上下//体现为z轴转的角度
    y = quatrotate(q_hand, y);%表示翻滚//但是体现为x轴转的角度
    z = quatrotate(q_hand, z);%表示偏转//体现为y轴转的角度
    
    disp(y(3));%X转看这个
    disp(z(1));%Y转看这个
    disp(x(2));%Z转看这个
    
    % 创建Robot对象
    robot = Robot();
    % 获取当前鼠标的位置
    mouseInfo = MouseInfo.getPointerInfo();
    currentLocation = mouseInfo.getLocation();
    currentX = currentLocation.getX();
    currentY = currentLocation.getY();
    % 让光标移动到目标位置
    robot.mouseMove(currentX+y(3)*10, currentY+x(2)*10);
end
