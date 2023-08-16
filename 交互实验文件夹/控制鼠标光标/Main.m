function Main()
    import java.awt.Robot;
    import java.awt.MouseInfo;
    import java.awt.Point;
    import java.awt.event.InputEvent;
    
    function funcControlMouse(q_hand)
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


    % 创建Robot对象
    robot = Robot();
    
    for i = 1:100
        a = eul2quat([pi/8,0,pi/8],'XYZ');
        funcControlMouse(a);
        pause(0.1)
    end

end
