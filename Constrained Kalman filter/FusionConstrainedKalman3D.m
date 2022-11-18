%% 文件说明
% 文件主要是实时展示手部姿态
% 用于记录全手关节姿态信息
% 保存原始数据

%% 对得到的数据进行约束求解；

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
P_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);
Hand_posture = zeros(7*4, 1);%用于存放 手部姿态，拇指两个关节姿态，食指两个关节姿态，中指两个关节姿态


Unconstrained_P_k = eye(IMU_num*4, IMU_num*4);
Unconstrained_X_k = zeros(IMU_num*4, 1);
Unconstrained_Hand_posture = zeros(7*4, 1);

load('Xishu_8.mat');%把系数加载进来，名字为NiheA  一共有IMU_num列，6行，分别对应系数与偏差

%% 简约三指构型可视化
viewer = fusiondemo.OrientationViewer;
figure;
set (gcf,'Position',[150,170,2150,1170], 'color','w')
title('手部姿态');
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
ha1 = animatedline('DisplayName', 'hand_1', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hi1 = animatedline('DisplayName', 'index_1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hi2 = animatedline('DisplayName', 'index_2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
ha2 = animatedline('DisplayName', 'hand_2', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hm1 = animatedline('DisplayName', 'middle_1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hm2 = animatedline('DisplayName', 'middle_2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
ht0 = animatedline('DisplayName', 'ht0', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
ht1 = animatedline('DisplayName', 'ht1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
ht2 = animatedline('DisplayName', 'ht2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);

%% 开始准备
format long g;

%% 解除串口占用
delete(instrfindall);
delay = .000001;

%% 串口参数设置
serialPort = 'COM3';   %串口号，根据设备实际连接
s = serial(serialPort, 'BaudRate', 512000);

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


%% 新建或打开数据文件,文件路径根据实际
str1 = '%f';
for i = 2:IMU_num*9
    str1=strcat(str1, ',%f');
end
str1 = strcat(str1, ',%f\n');
fileID1 = fopen(strcat('.\data\','实验原始数据',num2str(ti),'.csv'),'a');
count=1;
Dis_Count = 0;

%% 采集数据
while true
    Input = fscanf(s,'%f')';
    if length(Input)==IMU_num*9+1
        Dis_Count = Dis_Count + 1;
        if mod(Dis_Count,100) == 0
            disp(Dis_Count)
        end
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
         %% 添加约束
%         %对三手指的外关节角进行约束
        x0 = X_k;
        fun=@(x)((x-x0)'*(x-x0));
        A=[];   %不等式约束系数  [-0.5,0.5]
        b=[];   %不等式约束常数
        Aeq=[]; %等式约束系数
        beq=[]; %等式约束常数
        lb=[];  %下界
        ub=[];  %上界
        nonlcon=@Func_getHandJointConstraints;% 这里存在非线性的不等式约束，即对关节角进行约束;
        options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'active-set');% interior-point % sqp
%         [X_k, fval, exitflag, output, lambda, grad, hessian]=fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
        %% 归一化
        for N=1:IMU_num
            X_k(4*N-3:4*N) = X_k(4*N-3:4*N)/norm(X_k(4*N-3:4*N));    
        end
        %% 计算所需要的7个姿态信息
        Hand_posture(1*4-3:1*4) =  X_k(6*4-3:6*4);%手部姿态信息
        Hand_posture(2*4-3:2*4) = Func_getJointPosture(X_k,2,1);%拇指外关节
        Hand_posture(3*4-3:3*4) = Func_getJointPosture(X_k,3,2);%拇指内关节        
        Hand_posture(4*4-3:4*4) = Func_getJointPosture(X_k,5,4);%食指外关节
        Hand_posture(5*4-3:5*4) = Func_getJointPosture(X_k,6,5);%食指内关节
        Hand_posture(6*4-3:6*4) = Func_getJointPosture(X_k,7,8);%中指外关节
        Hand_posture(7*4-3:7*4) = Func_getJointPosture(X_k,6,7);%中指内关节
        if mod(Dis_Count,2)==0 
            %% 简约三指构型可视化
            Func_ShowHand(X_k',ha1,hi1,hi2,ha2,hm1,hm2,ht0,ht1,ht2)
        end
        fprintf(fileID1, str1, Input);
    if Dis_Count == 1000
        break;
    end

    else
        disp(Input');  %显示数据，读取状态可见，可有可无
        disp(['序号 data:  ',num2str(count)]);
        count = count+1;
%         if count > 2+IMU_num
        if size(Input,1) == 0
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