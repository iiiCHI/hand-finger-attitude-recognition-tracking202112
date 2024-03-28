 
%% 程序入口 
% addpath('quaternion_library');      % include quaternion library
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
rotateMatrix = zeros(IMU_num*4, IMU_num*4);
P_k = eye(IMU_num*4, IMU_num*4);
% R_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);
Z_k = zeros(IMU_num*4, 1);
Euler_k = zeros(IMU_num*3, 1);
load('Xishu.mat');%把系数加载进来，名字为NiheA  一共有IMU_num列，6行，分别对应系数与偏差

%% 绘制可视化图形的初始化操作
% % 使用fusion工具箱的可视化工具
% viewer = fusiondemo.OrientationViewer;
% figure;
% set (gcf,'Position',[100,0,1600,1000], 'color','w')
% subplot(1,3,1);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(1) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(1) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(1) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('KlmanIMU1, X-blue, Y-red, Z-green');
% % figure;
% subplot(1,3,2);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(2) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(2) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(2) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('ZK, X-blue, Y-red, Z-green');
% subplot(1,3,3);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(3) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(3) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(3) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('Qacc, X-blue, Y-red, Z-green');


figure;
set (gcf,'Position',[100,0,1600,1000], 'color','w')
% subplot(2,1,1);
Color = ['r','g','b','k'];
for N = 1:4
    h(N) = animatedline('Color',Color(N),'LineWidth',2);
end
% subplot(2,2,4);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(4) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(4) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(4) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('Qmag, X-blue, Y-red, Z-green');
%% 解除串口占用
delete(instrfindall);
delay = .000001;

%% 串口参数设置
serialPort = 'COM3';   %串口号，根据设备实际连接
s = serial(serialPort, 'BaudRate', 115200);

% s.BytesAvailableFcnMode='byte';  % 串口设置
s.InputBufferSize=4096;
s.OutputBufferSize=4096;

fopen(s);
disp('Start...');
ti=tic;
format long g;
if s.BytesAvailable > 0
    % Empty buffer by reading all contents of the buffer.
    % this let plot the ONLY current data, throw away old data.
    fread(s, s.BytesAvailable);
end

%% 新建或打开数据文件,文件路径根据实际
str1 = '%f';
str2 = '%f';
str3 = '%f';
str4 = '%f';
for i = 2:IMU_num*9
    str1=strcat(str1, ',%f');
    if(i<=IMU_num*3)
       str2 = strcat(str2, ',%f'); 
    end
    if(i<=IMU_num*4)
       str3 = strcat(str3, ',%f'); 
    end
    if(i<=4)
       str4 = strcat(str4, ',%f'); 
    end
end
str1 = strcat(str1, ',%f\n');
str2 = strcat(str2, '\n');
str3 = strcat(str3, '\n');
str4 = strcat(str4, '\n');
fileID1 = fopen(strcat('.\data\','原始数据',num2str(ti),'.csv'),'a');
fileID2 = fopen(strcat('.\data\','角度结果',num2str(ti),'.csv'),'a');
fileID3 = fopen(strcat('.\data\','四元数结果',num2str(ti),'.csv'),'a');
fileID8 = fopen(strcat('.\data\','两个IMU姿态差异结果',num2str(ti),'.csv'),'a');
count=1;
M_ave_Count = 0;
%% 采集数据
while true
    Input = fscanf(s,'%f')';
    if length(Input)==IMU_num*9+1
        M_ave_Count = M_ave_Count + 1;
        if mod(M_ave_Count,100) == 0
            disp(M_ave_Count)
            disp(X_k')
        end
%         Data_row(end+1,:) = Input;
        % check NaN data
        if any(isnan(Input))
            disp('NaN found in rawData')
            %rawData
            continue
        end
        
        % 将IMU的原始数据接收到内存空间的变量中
        for N = 1:IMU_num
            a(:,N) = Input(N*9-9+1:N*9-9+3)';
            g(:,N) = Input(N*9-9+4:N*9-9+6)'*PI/180;
            % 对于磁力计的数据，需要注意：
            % 磁力计的坐标系和陀螺仪加速度计的坐标系不同，
            % 需要在输入的时候将磁力计的坐标系转换到与陀螺仪和加速度计相同的坐标系下 X和Y互换，Z取反
            % 输入单位为uT（1e-6T）,地表磁场强度范围0.25--0.65 gauss（1e-4T）
            m(1,N) = ((Input(N*9-9+8)-NiheA(2,N))*NiheA(5,N))*(1e-3);% here use 1e-3.
            m(2,N) = ((Input(N*9-9+7)-NiheA(1,N))*NiheA(4,N))*(1e-3);
            m(3,N) = -(Input(N*9-9+9)-NiheA(3,N))*NiheA(6,N)*(1e-3);
            a(:,N) = a(:,N)./norm(a(:,N));
            m(:,N) = m(:,N)./norm(m(:,N));
        end
        deltatTime = Input(IMU_num*9+1);%这个地方改了，变成秒
        %% 单个IMU姿态求解        
        [X_k,P_k] = Func_getSingleIMUattitude(X_k,P_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num);%%这个是更新的。
        % 这个要做姿态解算 用四元数做差的形式进行姿态解算
        Q_diff = Func_crossProductFu(X_k(5:8),X_k(1:4));%求一个圈X

%         %% 角度换算
%         Euler_k = zeros(IMU_num*3,1);
%         for N = 1:IMU_num
%             X_k(N*4-3:N*4) = X_k(N*4-3:N*4)./norm(X_k(N*4-3:N*4));
%             % 转换为欧拉角
%             [yaw, pitch, roll]=quat2angle(X_k(N*4-3:N*4)','XYZ');%'ZYX'
%             Euler_k(N*3-2:N*3)=[yaw, pitch, roll]*(180/pi);
% %             disp(Euler_k');
%         end
%         
%         Q_diff = Func_crossProductFu(X_k(1:4),X_k(5:8));
        
        %% 添加约束试运行
        
%         %% 可视化
% %         for N=1:IMU_num
%         N=1;
%         iplot_q(X_k(1:4)', hx(N),hy(N),hz(N));
% %         end
%         N=2;
%         iplot_q(X_k(5:8)', hx(N),hy(N),hz(N));
%         N=3;
%         iplot_q(Q_diff', hx(N),hy(N),hz(N));
        
        for N = 1:4
            addpoints(h(N),M_ave_Count,Q_diff(N));%'r','g','b','k'红绿蓝黑
        end
%         subplot(2,1,1);
        drawnow limitrate nocallbacks
        axis([M_ave_Count-500,M_ave_Count,-1,1])
        
        %% 文件输出
%         str4 = Input+datestr(now);
        fprintf(fileID1, str1, Input);
%         fprintf(fileID2, str2, Euler_k);
        fprintf(fileID3, str3, X_k);
        fprintf(fileID8, str4, Q_diff);
        
%         disp(X_k(5:8)');
        
    else
        disp(Input);  %显示数据，读取状态可见，可有可无
        disp('error data');
        count = count+1;
        if count > 2+IMU_num
            disp('count error, break...');
            break;
        end
    end
end

%关闭文件
fclose('all');
fclose(s);
% clear fileID1 fileID2 fileID3;
disp('End...');