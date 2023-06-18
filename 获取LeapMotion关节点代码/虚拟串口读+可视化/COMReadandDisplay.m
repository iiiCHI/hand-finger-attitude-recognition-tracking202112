%% 对得到的数据进行约束求解；
% addpath('quaternion_library');      % include quaternion library
close all;                          % close all figures
clear;                              % clear all variables
clear global;                       % clear all global
clc;                                % clear the command terminal
scoms = instrfindall;
stopasync(scoms);
fclose(scoms);
%% 读数据，读出来
SerialNumber2 = serial('COM20', 'BaudRate', 512000);
SerialNumber2.Timeout = 3;
SerialNumber2.InputBufferSize=4096;
SerialNumber2.OutputBufferSize=4096;
fopen(SerialNumber2);

%% 简约三指构型可视化
figure(1);
set (gcf,'Position',[500,200,1400,700], 'color','w')
subplot(1,2,1);
grid;
% axis equal;
ax = gca;
ax.View = [30,30]; % 设置视角
axis([-2 2 -2 2 -2 2]);
ha1 = animatedline('DisplayName', 'hand_1', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hi1 = animatedline('DisplayName', 'index_1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hi2 = animatedline('DisplayName', 'index_2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
subplot(1,2,2);
grid;
% axis equal;
ax = gca;
ax.View = [30,30]; % 设置视角
axis([-2 2 -2 2 -2 2]);
ha1Sys = animatedline('DisplayName', 'hand_1', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hi1Sys = animatedline('DisplayName', 'index_1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hi2Sys = animatedline('DisplayName', 'index_2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);

Count = 0;

%% 主程序开始
disp("准备等待接收数据");
while true
    Input = fscanf(SerialNumber2,'%f,')';
    if length(Input) == 60
        Func_ShowIndexFinger(Input(13:24),ha1,hi1,hi2)
%         Func_ShowIndexJoint(Input(25:36),ha1Sys,hi1Sys,hi2Sys)
    else
        Count =Count+1;
        disp("接收数据错误，目前计数:",int2str(Count))
        if Count > 5
            break;
        end
    end
end


scoms = instrfindall;
stopasync(scoms);
fclose(scoms);