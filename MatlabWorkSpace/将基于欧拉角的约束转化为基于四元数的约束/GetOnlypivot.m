%% 姿态围绕两轴转动，先绕x再绕z轴 不进行拆解，进行中间值的拆解
%% 程序入口
clc
close all
clear
%% 绘制可视化图形的初始化操作
figure;
set (gcf,'Position',[900,200,1400,700], 'color','w')
subplot(1,2,1);
grid;
% axis equal;
ax = gca;
ax.View = [30,30]; % 设置视角
axis([-2 2 -2 2 -2 2]);
hx(1) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(1) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(1) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('纯净值, X-blue, Y-red, Z-green');
subplot(1,2,2);
grid;
% axis equal;
ax = gca;
ax.View = [30,30]; % 设置视角
axis([-2 2 -2 2 -2 2]);
hx(2) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(2) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(2) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('计算值, X-blue, Y-red, Z-green');
figure;
set (gcf,'Position',[200,200,700,900], 'color','w')
subplot(4,1,1);
Color = ['k','b','r','g'];
for N = 1:4
    h(N) = animatedline('Color',Color(N),'LineWidth',2);
end
subplot(4,1,2);
% Color = ['k','b','r','g'];
for N = 1:4
    h2(N) = animatedline('Color',Color(N),'LineWidth',2);
end
subplot(4,1,3);
% Color = ['k','b','r','g'];
for N = 1:4
    h3(N) = animatedline('Color',Color(N),'LineWidth',2);
end
% figure;
subplot(4,1,4);
% Color = ['k','b','r','g'];
for N = 1:4
    h4(N) = animatedline('Color',Color(N),'LineWidth',2);
end
theata = [];
Beta = [];
%% 程序开始
Qter = [1,0,0,0]';           %表示当前状态的四元数
Stage1Value = [1,0,0,0]';     %阶段1的姿态
Stage2Value = [1,0,0,0]';     %阶段2的姿态

Theta = pi/(2*1.3*100);
P  = [cos(Theta), sin(Theta),0,0];  %绕x轴进行转动
PF = [cos(Theta),-sin(Theta),0,0];
Q  = [cos(Theta),0,0, sin(Theta)];  %绕Z轴进行转动
QF = [cos(Theta),0,0,-sin(Theta)];
W  = [cos(Theta),0, sin(Theta),0];  %绕Y轴进行转动
WF = [cos(Theta),0,-sin(Theta),0];



for i = 1:200
    if i <= 100
        Stage1Value = Func_crossProduct(PF,Stage1Value); 
%         StageValue = Qter;
        % 用角度去做
%         Qter = [1,0,0,0]';
        rotateMatrix =  Func_getGyroRotateMatrix([0,0,pi/(1.3*100)]);
        Phi = eye(4) + (1/2) * rotateMatrix;
        Qter = Phi * Qter;
    elseif i <= 200
        Stage1Value = Func_crossProduct(QF,Stage1Value);

        rotateMatrix =  Func_getGyroRotateMatrix([pi/(1.3*100),0,0]);
        Phi = eye(4) + (1/2) * rotateMatrix;
        Qter = Phi * Qter;
    else
%         Qter = Func_crossProduct(W,Qter);%内旋
        rotateMatrix =  Func_getGyroRotateMatrix([0,-pi/(1.1*100),-pi/(1.1*100)]);
        Phi = eye(4) + (1/2) * rotateMatrix;
        Qter = Phi * Qter;
    end
%     Stage2Value = Func_crossProduct(Qter,[StageValue(1),-StageValue(2),-StageValue(3),-StageValue(4)]);
    Stage2Value = [sqrt(Qter(1)^2+Qter(3)^2),sign(Qter(1))*sign(Qter(2))*sqrt(Qter(2)^2+Qter(4)^2),0,0]';

    StageValue = Func_crossProduct(Qter,[Stage2Value(1),-Stage2Value(2),-Stage2Value(3),-Stage2Value(4)]);
    
    [angle(1),angle(2),angle(3)] = quat2angle(Qter');
    angle(4) = 0;
%% 可视化
    for N = 1:4
        addpoints(h(N),i,Qter(N));%'r','g','b','k'红绿蓝黑
        addpoints(h2(N),i,StageValue(N));%'r','g','b','k'红绿蓝黑
        addpoints(h3(N),i,Stage2Value(N));%'r','g','b','k'红绿蓝黑
        addpoints(h4(N),i,angle(N));%'r','g','b','k'红绿蓝黑
    end
%         subplot(2,1,1);   
%     drawnow limitrate nocallbacks
    for N = 1:4
        subplot(4,1,N);
        axis([i-300,i,-1,1])
        if N == 4
        axis([i-300,i,-pi,pi])
        end

    end
    iplot_q(Qter', hx(1),hy(1),hz(1));
    iplot_q(Stage1Value', hx(2),hy(2),hz(2));
end

