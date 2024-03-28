%一共输出了4个图像，分别表示了Klman和CkIMU之间的算法比较。
%用的是提前跑好的代码。

%% 程序入口 
addpath('quaternion_library');      % include quaternion library
close all;                          % close all figures
clear;                              % clear all variables
clc;                                % clear the command terminal

% 定义接入程序的IMU硬件数目
IMU_num = 2;
PI = 3.1415926;
sigma_g = 0.004; % 陀螺仪的噪声标准差
sigma_a = 0.014; % 加速度计的噪声标准差
sigma_m = 0.001; % 磁力计的f噪声标准差

Sigma_g = eye(IMU_num*3)*sigma_g*sigma_g; % 陀螺仪的标准差矩阵
Sigma_a = eye(3)*(sigma_a*sigma_a)/(9.81)^2; % 当地的重力加速度，使用9.8m/s2
Sigma_m = eye(3)*(sigma_m*sigma_m)/(0.53)^2; % 从网站获取西安市的磁场强度0.53G

Sigma_u = [Sigma_a,  zeros(3);
           zeros(3), Sigma_m];

% 预分配内存空间，用于存储接收到的IMU原始数据
a = zeros(3, IMU_num);
g = zeros(3, IMU_num);
m = zeros(3, IMU_num);

jointNum = 1;

rotateMatrix = zeros(IMU_num*4, IMU_num*4);
P_k = eye(IMU_num*4, IMU_num*4);
allP_k = eye(jointNum*4, jointNum*4);
R_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);

m00 = zeros(3,IMU_num);

Euler_k = zeros(IMU_num*3, 1);
load('Xishu.mat');

% load('俯仰角，上90°下90°.mat');
% load('得到的雅可比行列式JandQ.mat');
%% 绘制可视化图形的初始化操作
% % 使用fusion工具箱的可视化工具
% viewer = fusiondemo.OrientationViewer;
figure;
set (gcf,'Position',[100,0,1600,1000], 'color','w')
subplot(2,3,1);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(1) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(1) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(1) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('IKIMU1, X-blue, Y-red, Z-green');
% figure;
subplot(2,3,2);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(2) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(2) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(2) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('IKIMU2, X-blue, Y-red, Z-green');
% figure;
subplot(2,3,3);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(3) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(3) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(3) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('IKIMU_diff, X-blue, Y-red, Z-green');
subplot(2,3,4);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(4) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(4) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(4) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('MaIMU1, X-blue, Y-red, Z-green');
% figure;
subplot(2,3,5);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(5) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(5) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(5) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('MaIMU2, X-blue, Y-red, Z-green');
subplot(2,3,6);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(6) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(6) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(6) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('MaIMU_diff, X-blue, Y-red, Z-green');

%% 程序准备阶段
disp('Start...');
% format long g;
% AHRS(1) = MadgwickAHRS('SamplePeriod',0.02,'Beta',sqrt(3/4)*180*0.04/PI);%用来计算角度差异的
% AHRS(2) = MadgwickAHRS('SamplePeriod',0.02,'Beta',sqrt(3/4)*180*0.04/PI);%用来计算角度差异的
AHRS(1) = MadgwickAHRS('SamplePeriod',0.02,'Beta',sqrt(3/4)*180*0.04/PI);%用来计算角度差异的
AHRS(2) = MadgwickAHRS('SamplePeriod',0.02,'Beta',sqrt(3/4)*180*0.04/PI);%用来计算角度差异的

mager = [];
count=1;
ti=tic;

% Data_row = load('./data/单个IMU数据/偏航90°/包含奇异点的值/原始数据9413354805789.csv');
% Data_row = load('./data/单个IMU数据/翻滚90/旋转360°/原始数据9429855889624.csv');
% Data_row = load('./data/单个IMU数据/Qmag断层/原始数据9225873474198.csv');
% Data_row = load('./data/单个IMU数据/Qmag断层/断层2/原始数据9260621504406.csv');
Data_row = load('./data/单个IMU数据/大量数据/原始数据159347059366.csv');
% Data_row = load('./data/单个IMU数据/静止不动/原始数据9410881611780.csv');

quaternion = zeros(IMU_num, 4);  

%% 读入数据
for indexNumber = 1:length(Data_row)
        Input = Data_row(indexNumber,:);
        if mod(indexNumber,100) == 0
            disp(indexNumber);
        end
        %% 将IMU的原始数据接收到内存空间的变量中
        for N = 1:IMU_num
            a(:,N) = Input(N*9-9+1:N*9-9+3)';
            g(:,N) = Input(N*9-9+4:N*9-9+6)'*PI/180;
            m(:,N) = [Input(N*9-9+7),Input(N*9-9+8),Input(N*9-9+9)];
            m(1,N) = ((Input(N*9-9+8)-NiheA(2,N))*NiheA(5,N))*(1e-3);% here use 1e-3.
            m(2,N) = ((Input(N*9-9+7)-NiheA(1,N))*NiheA(4,N))*(1e-3);
            m(3,N) = -(Input(N*9-9+9)-NiheA(3,N))*NiheA(6,N)*(1e-3);
            
            a(:,N) = a(:,N)./norm(a(:,N));
            m(:,N) = m(:,N)./norm(m(:,N));
        end
        deltatTime = Input(IMU_num*9+1);%这个地方改了，变成秒，这个就是时间间隔。
        %% 总的卡尔曼的观测值求解
        [X_k,R_k] = Func_getSingleIMUattitude(X_k,R_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num);%%这个是更新的。
        % 这个要做姿态解算 用四元数做差的形式进行姿态解算
        Q_diff_IK = Func_crossProductFu(X_k(5:8),X_k(1:4));%求一个圈X

        %% 互补滤波的      
        for N = 1:IMU_num
            %磁场的问题，出现了漂移，这可咋办。  对两个IMU求解，所以用的%%原因，磁场没有拟合好
            AHRS(N).Update(g(:,N)', a(:,N)', m(:,N)');	% gyroscope units must be radians
            quaternion(N,:) = AHRS(N).Quaternion;
        end
        Q_diff_MA = Func_crossProductFu(quaternion(2,:),quaternion(1,:));%求一个圈X
        
        %% 可视化
        for N=1:IMU_num
            iplot_q(quaternConj(quaternion(N,:)), hx(N+3),hy(N+3),hz(N+3));
            iplot_q(X_k(N*4-3:N*4)', hx(N),hy(N),hz(N));
        end
        iplot_q(Q_diff_IK', hx(3),hy(3),hz(3));
        iplot_q(Q_diff_MA', hx(6),hy(6),hz(6));

end
disp('End...');