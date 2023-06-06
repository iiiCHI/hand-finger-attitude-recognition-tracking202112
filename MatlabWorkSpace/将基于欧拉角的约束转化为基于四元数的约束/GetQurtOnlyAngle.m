%% 使用欧拉角进行转动。
%欧拉角的转动是整体转动，并不是按照坐标系下的某个轴进行转动。
%% 程序入口 
% addpath('quaternion_library');      % include quaternion library
close all;                          % close all figures
clear;                              % clear all variables
clc;                                % clear the command terminal
%% 绘制可视化图形的初始化操作
figure(2);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(1) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(1) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(1) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('KlmanIMU1, X-blue, Y-red, Z-green');
% figure(3);
% Color = ['r','g','b','k'];
% for N = 1:4
%     h5(N) = animatedline('Color',Color(N),'LineWidth',2);
% end

figure(1);
set (gcf,'Position',[200,200,700,900], 'color','w')
subplot(4,1,1);
Color = ['r','g','b','k'];
for N = 1:4
    h(N) = animatedline('Color',Color(N),'LineWidth',2);
end
axis([-inf,1000,-1,1])
subplot(4,1,2);
Color = ['r','g','b','k'];
for N = 1:4
    h2(N) = animatedline('Color',Color(N),'LineWidth',2);
end
axis([-inf,1000,-pi,pi])
subplot(4,1,3);
Color = ['r','g','b','k'];
for N = 1:4
    h3(N) = animatedline('Color',Color(N),'LineWidth',2);
end
axis([-inf,1000,-1,1])
% figure;
subplot(4,1,4);
Color = ['r','g','b','k'];
for N = 1:4
    h4(N) = animatedline('Color',Color(N),'LineWidth',2);
end
axis([-inf,1000,-1,1])
data = [];

X_k_JI = [1,0,0,0]';
M_ave_Count = 0;
deltatTime = 0.1;%这个地方改了，变成秒      
disp('Start');
%% 角度测算曼循环开始
while true    
    M_ave_Count = M_ave_Count+1;
    if M_ave_Count < 200
        Theta = 0.15/180*pi;
        Q = [cos(Theta),0,sin(Theta),0];
        X_k_JI = Func_crossProduct(Q,X_k_JI);
        
    elseif  M_ave_Count < 400
        g = [0,0,0.15];%每一次都只有每一轮的g           
        rotateMatrix =  Func_getGyroRotateMatrix(g);
        Phi = eye(4) + (1/2) * rotateMatrix * deltatTime;
        X_k_JI = Phi*X_k_JI;
        
    elseif  M_ave_Count < 600
        Theta = -0.15/180*pi;
        Q = [cos(Theta),0,sin(Theta),0];
        X_k_JI = Func_crossProduct(Q,X_k_JI);
        
    elseif  M_ave_Count < 800
        g = [0,0,-0.15];%每一次都只有每一轮的g   
        rotateMatrix =  Func_getGyroRotateMatrix(g);
        Phi = eye(4) + (1/2) * rotateMatrix * deltatTime;
        X_k_JI = Phi*X_k_JI;
        
%     elseif  M_ave_Count < 1000 
%         Theta = -0.5/180*pi;
%         Q = [cos(Theta),0,sin(Theta),0];
%         X_k_JI = Func_crossProduct(Q,X_k_JI);
%     else
%         if M_ave_Count < 81.4*2*4*0.3
%             g = [0,0,0.5];
%         elseif  M_ave_Count < 81.4*2*5*0.3
%             g = [0,0.3,0];%每一次都只有每一轮的g   
%         else
%             break;
%         end
    else
        break;
    end
%     deltatTime = 0.0193;%这个地方改了，变成秒     
    %% IMU姿态的先验估计计算矩阵
    X_k_JI = X_k_JI./norm(X_k_JI);
    %分解成偏航角和俯仰角
    X_Z = [sqrt(X_k_JI(1)^2+X_k_JI(3)^2),0,0,sqrt(X_k_JI(2)^2+X_k_JI(4)^2)];
    X_Y = [sqrt(X_k_JI(1)^2+X_k_JI(4)^2),0,sqrt(X_k_JI(2)^2+X_k_JI(3)^2),0];
    %纠正符号！
%     if sign(X_k_JI(1))*sign(X_k_JI(3))==-1
%     X_Y(1) = X_Y(1)*sign(X_k_JI(1));
%     X_Y(3) = X_Y(3)*sign(X_k_JI(3));
%     end
    X_k_JI2 = Func_crossProduct(X_Y,X_Z);
    X_k_JI2 = X_k_JI2.*sign(X_k_JI);
    
    Angel = [0,0,0,0];
    [Angel(1), Angel(2), Angel(3)]=quat2angle(X_k_JI','xzy');%'ZYX'
    Angel = real(Angel);
    %% 可视化
    for N = 1:4
        addpoints(h(N),M_ave_Count,X_k_JI(N));%'r','g','b','k'红绿蓝黑
        addpoints(h2(N),M_ave_Count,X_Z(N));%'r','g','b','k'红绿蓝黑
        addpoints(h3(N),M_ave_Count,X_Y(N));%'r','g','b','k'红绿蓝黑
        addpoints(h4(N),M_ave_Count,X_k_JI2(N));%'r','g','b','k'红绿蓝黑
    end
    
    
    
%         subplot(2,1,1);
%     drawnow limitrate nocallbacks
%     for N = 1:4
%         if N ~= 2
%             subplot(4,1,N);
%             axis([M_ave_Count-500,M_ave_Count,-1,1])
%         end
%     end
    iplot_q(X_k_JI(1:4)', hx(1),hy(1),hz(1));
    data(end+1,:) = X_k_JI';
end
% clear fileID1 fileID2 fileID3;
disp('End...');