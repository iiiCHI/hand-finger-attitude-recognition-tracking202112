function funcControlMouse(q_hand)
    % 将四元数转化为空间坐标
    phi = 30000;
    x = [-1,0,0];%转的话应该是正负吧，
    y = [0,1,0];
%     z = [0,0,1];    
    x = quatrotate(q_hand, x);%表示上下//体现为z轴转的角度
    y = quatrotate(q_hand, y);%表示翻滚//但是体现为x轴转的角度
%     z = quatrotate(q_hand, z);%表示偏转//体现为y轴转的角度    
    % 获取当前鼠标的位置
    mouseInfo = MouseInfo.getPointerInfo();
    currentLocation = mouseInfo.getLocation();
    currentX = currentLocation.getX();
    currentY = currentLocation.getY();
    % 让光标移动到目标位置
    %disp("----")
    x1 = sign(x(2))*(x(2)*x(2)*phi)+0.05;
    y1 = sign(y(3))*(y(3)*y(3)*phi);
    if abs(x1) < 0.1
        x1 = 0;
    end
    if abs(y1) < 0.1
        y1 = 0;
    end
    %中值滤波 window
    windowX = windowX(:,2:end);
    windowX = [windowX,x1];
    windowY = windowY(:,2:end);
    windowY = [windowY,y1];

    robot.mouseMove(currentX+median(sort(windowX)), currentY+median(sort(windowY)));
end