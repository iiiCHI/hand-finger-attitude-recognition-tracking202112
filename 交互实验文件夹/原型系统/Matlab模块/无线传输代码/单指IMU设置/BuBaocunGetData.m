%% 该脚本是仅仅用来观测实际数据的，没有添加约束
%% 程序入口 
% addpath('quaternion_library');      % include quaternion library
close all;                          % close all figures
clear;                              % clear all variables
clc;                                % clear the command terminal

% 定义接入程序的IMU硬件数目
IMU_num = 8;
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
load('Xishu8IMU.mat');%把系数加载进来，名字为NiheA  一共有IMU_num列，6行，分别对应系数与偏差

%% 绘制可视化图形的初始化操作


figure;
set (gcf,'Position',[100,0,1600,1000], 'color','w')
% subplot(3,1,1);
% subplot(1,1,1);
Color = ['r','g','b','k'];
for N = 1:4
    h(N) = animatedline('Color',Color(N),'LineWidth',2);
end
% 
% subplot(3,1,2);
% Color = ['r','g','b','k'];
% for N = 1:4
%     h2(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% 
% subplot(3,1,3);
% Color = ['r','g','b','k'];
% for N = 1:4
%     h3(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
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
        [X_k,P_k,Z_k] = Func_getSingleIMUattitude(X_k,P_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num);%%这个是更新的。
        % 这个要做姿态解算 用四元数做差的形式进行姿态解算
%         Q_diff = Func_crossProductFu(X_k(5:8),X_k(1:4));%求一个圈X

                %% 添加约束
%         x0 = Q_diff;
% %         fun=@(x)((x-x0)'/diag([1,1,1,1]))*(x-x0);
%         fun=@(x)((x-x0)'*(x-x0));
%         A=[0,1,0,0;0,-1,0,0];   %不等式约束系数  [-0.5,0.5]
%         b=[0.7;0.7];   %不等式约束常数
% %         A=[];   %不等式约束系数  [-0.5,0.5]
% %         b=[];   %不等式约束常数
% %         Aeq=[0,0,1,0;0,1,0,0]; %等式约束系数
% %         beq=[0;0]; %等式约束常数
%         Aeq=[]; %等式约束系数
%         beq=[]; %等式约束常数
%         lb=[];  %下界
%         ub=[];  %上界
%         nonlcon=@nonfunction;% 这里存在非线性的不等式约束，即其模为1;
%         options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'active-set');% interior-point % sqp
% %         options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');% interior-point % sqp
%         [Q_diff_const, fval, exitflag, output, lambda, grad, hessian]=fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
        
        
        
        %% 角度换算
%         Euler_k = zeros(IMU_num*3,1);
%         for N = 1:IMU_num
%             X_k(N*4-3:N*4) = X_k(N*4-3:N*4)./norm(X_k(N*4-3:N*4));
%             % 转换为欧拉角
%             [yaw, pitch, roll]=quat2angle(X_k(N*4-3:N*4)','XYZ');%'ZYX'
%             Euler_k(N*3-2:N*3)=[yaw, pitch, roll]*(180/pi);
% %             disp(Euler_k');
%         end
        
%         Q_diff = Func_crossProductFu(X_k(1:4),X_k(5:8));
        
%         Angle = [yaw, pitch, roll,0];
        
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
            addpoints(h(N),M_ave_Count,X_k(N));%'r','g','b','k'红绿蓝黑
%             addpoints(h2(N),M_ave_Count,X_k(4+N));%'r','g','b','k'红绿蓝黑
%             addpoints(h3(N),M_ave_Count,Q_diff_const(N));%'r','g','b','k'红绿蓝黑
        end
        drawnow limitrate nocallbacks
%         subplot(3,1,1);
        axis([M_ave_Count-500,M_ave_Count,-1,1])
%         subplot(3,1,2);
%         axis([M_ave_Count-500,M_ave_Count,-1,1])
%         subplot(3,1,3);
%         axis([M_ave_Count-500,M_ave_Count,-1,1])

        
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
% fclose('all');
fclose(s);
% clear fileID1 fileID2 fileID3;
disp('End...');