%% 对得到的数据进行约束求解；
% addpath('quaternion_library');      % include quaternion library
close all;                          % close all figures
clear;                              % clear all variables
clear global;                       % clear all global
clc;                                % clear the command terminal

%% 放置两个全局变量用于debug


% 定义接入程序的IMU硬件数目
IMU_num = 1;
PI = 3.1415926;
sigma_g = 0.02; % 陀螺仪的噪声标准差
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
P_k = eye(IMU_num*4, IMU_num*4);
% X_k = zeros(IMU_num*4, 1);
X_k = [1,0,0,0]';

Hand_posture = zeros(7*4, 1);%用于存放 手部姿态，拇指两个关节姿态，食指两个关节姿态，中指两个关节姿态

load('Xishu_sigl.mat');%把系数加载进来，名字为NiheA  一共有IMU_num列，6行，分别对应系数与偏差

%% 绘制可视化图形的初始化操作
% % 使用fusion工具箱的可视化工具
% figure;
% set (gcf,'Position',[100,0,1600,1000], 'color','w')
% % subplot(3,3,1);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(1) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(1) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(1) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('KlmanIMU1, X-blue, Y-red, Z-green');
% % figure;
% subplot(3,3,2);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(2) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(2) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(2) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('KlmanIMU2, X-blue, Y-red, Z-green');
% subplot(3,3,3);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(3) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(3) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(3) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('KlmanIMU3, X-blue, Y-red, Z-green');
% subplot(3,3,4);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(4) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(4) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(4) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('KlmanIMU4, X-blue, Y-red, Z-green');
% subplot(3,3,5);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(5) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(5) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(5) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('KlmanIMU5, X-blue, Y-red, Z-green');
% subplot(3,3,6);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(6) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(6) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(6) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('KlmanIMU6, X-blue, Y-red, Z-green');
% subplot(3,3,7);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(7) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(7) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(7) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('KlmanIMU7, X-blue, Y-red, Z-green');
% subplot(3,3,8);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(8) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(8) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(8) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('KlmanIMU8, X-blue, Y-red, Z-green');
%% 朴素曲线可视化
Axis_num = 425;
figure(1);
set (gcf,'Position',[100,0,1600,1000], 'color','w')
subplot(2,2,1);
title('Hand');
Color = ['r','g','b','k'];
for N = 1:4
    h(N) = animatedline('Color',Color(N),'LineWidth',2);
end
legend('Q1','Q2','Q3','Q4');
axis([0,Axis_num,-1,1])
subplot(2,2,2);
title('拇指外关节');
Color = ['r','g','b','k'];
for N = 1:4
    h2(N) = animatedline('Color',Color(N),'LineWidth',2);
end
%legend('Q1','Q2','Q3','Q4');
axis([0,Axis_num,-pi,pi])
% subplot(4,2,3);
% title('拇指内关节');
% Color = ['r','g','b','k'];
% for N = 1:4
%     h3(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% %legend('Q1','Q2','Q3','Q4');
% axis([0,Axis_num,-1,1])
% subplot(4,2,4);
% title('食指外关节');
% Color = ['r','g','b','k'];
% for N = 1:4
%     h4(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% %legend('Q1','Q2','Q3','Q4');
% axis([0,Axis_num,-1,1])
% subplot(4,2,5);
% title('食指内关节');
% Color = ['r','g','b','k'];
% for N = 1:4
%     h5(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% %legend('Q1','Q2','Q3','Q4');
% axis([0,Axis_num,-1,1])
% subplot(4,2,6);
% title('中指外关节');
% Color = ['r','g','b','k'];
% for N = 1:4
%     h6(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% %legend('Q1','Q2','Q3','Q4');
% axis([0,Axis_num,-1,1])
% subplot(4,2,7);
% title('中指内关节');
% Color = ['r','g','b','k'];
% for N = 1:4
%     h7(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% %legend('Q1','Q2','Q3','Q4');
% axis([0,Axis_num,-1,1])
% subplot(4,2,8);
% title('备用图表');
% Color = ['r','g','b','k'];
% for N = 1:4
%     h8(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% %legend('Q1','Q2','Q3','Q4');
% axis([0,Axis_num,-1,1])

% 
%% 简约三指构型可视化
figure(2);
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

%% 这是通过USB连接  开始准备
format long g;
% ReadFileName = ".\data\原始数据242901344242.csv";
% Data_row = load(ReadFileName);

%% 解除串口占用
delete(instrfindall);
delay = .000001;

%% 串口参数设置
serialPort = 'COM3';   %串口号，根据设备实际连接
s = serial(serialPort, 'BaudRate', 115200);
s.Timeout = 3;
% s = serial(serialPort, 'BaudRate', 512000);

% s.BytesAvailableFcnMode='byte';  % 串口设置
s.InputBufferSize=4096;
s.OutputBufferSize=4096;
%% 串口开始
fopen(s);
disp('Start...');
ti=tic;
format long g;
if s.BytesAvailable > 0
    % Empty buffer by reading all contents of the buffer.
    % this let plot the ONLY current data, throw away old data.
    fread(s, s.BytesAvailable);
end

%% 这是通过ESP8266连接 串口参数设置
% disp('…………开始设置串口…………');
% tc = tcpserver('192.168.1.103',8080,"Timeout",1);
% tc.InputBufferSize = 30000;
% disp('等待网络串口接入：\n');
% while tc.Connected == 0
%    pause(0.5);
% end
% disp('串口接入成功，循环读取数据:\n');
% flush(tc)

%% 约束变量，姑且设置q4的范围为[-0.5，0.5]
mtx = [];
flag = 0;
dtm = datetime;
count_pre = 0;
count=1;%记录数据总个数
Dis_Count = 0;%记录错误的数据个数
drawnow limitrate nocallbacks
TimePre = clock();
ti=tic;
K_k = [];
%% 采集数据
% while tc.Connected > 0
while true
    count = count+1;
%     try
        Input = fscanf(s,'%f')';        
%         Input = str2num(readline(tc));
%         if length(Input)==IMU_num*9+1
        if length(Input)==IMU_num*9+1
            Dis_Count = Dis_Count + 1;
            if mod(Dis_Count,100) == 0
                disp(Dis_Count)
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
                %a(:,N) = a(:,N)./norm(a(:,N));
                m(:,N) = m(:,N)./norm(m(:,N));
            end
            deltatTime = Input(IMU_num*9+1);%这个地方改了，变成秒//这个需要改，改成PC所获取的。
%             TimeNow = clock();
%             deltatTime = etime(TimeNow,TimePre);
%             TimePre = TimeNow;
            %% 单个IMU姿态求解        
            [Z_k,X_k,P_k] = Func_getSingleIMUattitude(X_k,P_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num);%%这个是更新的。
            %% 归一化
            for N=1:IMU_num
                X_k(4*N-3:4*N) = X_k(4*N-3:4*N)/norm(X_k(4*N-3:4*N));
            end
            %% 简约三指构型可视化
            iplot_q(X_k(1:4)',ha1,hi1,hi2)
            iplot_q(Z_k(1:4)',ha1Sys,hi1Sys,hi2Sys)
%             Func_ShowIndexFinger(X_k',ha1,hi1,hi2)
            [angle(1),angle(2),angle(3)] = quat2angle(X_k');
%             %% 朴素曲线可视化
%             indexNumber = Dis_Count;
%             for N = 1:4
%                 addpoints(h(N),indexNumber,X_k(N)); 
%                 if N ~= 4
%                     addpoints(h2(N),indexNumber,angle(N)); 
%                 end
%             end
%             if mod(indexNumber,Axis_num) == 0
%                 for N = 1:2
%                     subplot(2,2,N);
%                     axis([floor(indexNumber/Axis_num)*Axis_num,Axis_num*(1+floor(indexNumber/Axis_num)),-1,1])
%                     if N == 2
%                         axis([floor(indexNumber/Axis_num)*Axis_num,Axis_num*(1+floor(indexNumber/Axis_num)),-pi,pi])
%                     end
%                 end
%             end
%             drawnow limitrate nocallbacks
    
        else
            flag = flag + 1;
            disp(string(count)+'->'+string(flag)+'->'+string(length(Input))+"平均时间为:"+string(seconds(datetime - dtm)/(count-count_pre)));
            disp(Input');
            count_pre = count;
            dtm = datetime;
            if flag >= 5 
                break;
            end
        end
%     catch err
%         disp(err);
%         disp('Error');
%         break;
%     end
end

disp('运行结束');
toc(ti)
%关闭文件
% close all
fclose('all');
fclose(s);
% clear fileID1 fileID2 fileID3;
disp('End...');
