%% 验证提取关节角思路
function [angle] = Func_getROMEuler(A, B)

% 前提：
% 我们假设四元数A为中节指骨搭载的IMU测量值，
% 四元数B为近节指骨搭载的IMU测量值，
% 两数据都是基于大地坐标系的测量值。

% 主要思路：
% 输入的两个IMU四元数，均是基于大地坐标系的表示，
% 1. 根据第一个传感器基于大地坐标系的表示B，求得大地坐标系在B所在坐标系中的表示B_gToB，B的共轭四元数
% 2. 将B的共轭，与第二个传感器基于大地坐标系下的表示A，进行四元数的叉乘运算，求得第二个传感器在B所在坐标系下的表示A_gToB；参考自：《A
% LINEAR KALMAN FILTER FOR MARG ORIENTATION ESTIMATION USING AQUA》，equation
% 3:q_AToC = q_BToC X q_AToB;
% 3. 那么四元数A_gToB，是A在B坐标系下的表示，也可以认为是A与B的角度之差，所以最后将A_gToB转换为欧拉角即可得到我们所需要的pitch角

% 工作：
% 1. 利用大地坐标系下的四元数B，将大地坐标系下的四元数A，转化为A在B坐标系下的四元数；
% 2. 四元数转欧拉角公式；

q0 = B(1);
q1 = -B(2);
q2 = -B(3);
q3 = -B(4);

% 计算大地坐标系g在B所在坐标系下的表示
B_gToB = [q0; q1; q2; q3];

% 求解A在B所在坐标系下的表示
A_gToB = Func_crossProduct(B_gToB, A);

% 将四元数转换为欧拉角
% 这里需要注意旋转顺序，从函数quat2angle的介绍中可以得知，返回值依次是按照ZYX的顺序进行旋转
[yaw, roll, pitch]=quat2angle(A_gToB');
%俯仰、横滚、偏航
angle = [yaw; pitch; roll]*(180/pi);

end

