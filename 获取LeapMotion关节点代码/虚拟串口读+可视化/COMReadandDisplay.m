%% 对得到的数据进行约束求解；
% addpath('quaternion_library');      % include quaternion library
% close all;                          % close all figures
% clear;                              % clear all variables
% clear global;                       % clear all global
% clc;                                % clear the command terminal


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

%% 主程序开始
for i = 1:size(mtx)
    X_k = mtx(i,:);
    Func_ShowIndexFinger(X_k,ha1,hi1,hi2)
    Func_ShowIndexJoint(X_k,ha1Sys,hi1Sys,hi2Sys)
end