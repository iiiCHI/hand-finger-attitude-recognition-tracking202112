% 导入Java的Robot类和Java的Point类
import java.awt.Robot;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.event.InputEvent;

try
    % 创建Robot对象
    robot = Robot();
    
    for i = 1:100
        % 获取当前鼠标的位置
        mouseInfo = MouseInfo.getPointerInfo();
        currentLocation = mouseInfo.getLocation();
        currentX = currentLocation.getX();
        currentY = currentLocation.getY();
        % 让光标移动到目标位置
        robot.mouseMove(currentX+13, currentY+13);
        pause(0.1)
    end


    % 可选：在目标位置点击一次鼠标左键
    robot.mousePress(InputEvent.BUTTON1_MASK);
    robot.mouseRelease(InputEvent.BUTTON1_MASK);
catch
    disp('发生错误，请确保已经导入Java的Robot类并且没有其他问题。');
end
