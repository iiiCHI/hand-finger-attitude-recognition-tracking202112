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
% rotateMatrix = zeros(IMU_num*4, IMU_num*4);
P_k = eye(IMU_num*4, IMU_num*4);
% R_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);
% F_Z = zeros(IMU_num*4, 1);
% Z_k = zeros(IMU_num*4, 1);
% Euler_k = zeros(IMU_num*3, 1);
Hand_posture = zeros(7*4, 1);%用于存放 手部姿态，拇指两个关节姿态，食指两个关节姿态，中指两个关节姿态


Unconstrained_P_k = eye(IMU_num*4, IMU_num*4);
Unconstrained_X_k = zeros(IMU_num*4, 1);
Unconstrained_Hand_posture = zeros(7*4, 1);

load('Xishu_8.mat');%把系数加载进来，名字为NiheA  一共有IMU_num列，6行，分别对应系数与偏差

%% 绘制可视化图形的初始化操作
% % 使用fusion工具箱的可视化工具
% viewer = fusiondemo.OrientationViewer;
% figure;
% set (gcf,'Position',[100,0,1600,1000], 'color','w')
% subplot(3,3,1);
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
% Axis_num = 425;
% figure(1);
% set (gcf,'Position',[100,0,1600,1000], 'color','w')
% subplot(4,2,1);
% title('Hand');
% Color = ['r','g','b','k'];
% for N = 1:4
%     h(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% legend('Q1','Q2','Q3','Q4');
% axis([0,Axis_num,-1,1])
% subplot(4,2,2);
% title('拇指外关节');
% Color = ['r','g','b','k'];
% for N = 1:4
%     h2(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% %legend('Q1','Q2','Q3','Q4');
% axis([0,Axis_num,-1,1])
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
% figure(2);
% set (gcf,'Position',[100,0,1600,1000], 'color','w')
% subplot(2,1,1);
% Color = ['r','g','b','k'];
% for N = 1:4
%     h21(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% legend('Q1','Q2','Q3','Q4');
% axis([0,2255,-1,1])
% subplot(2,1,2);
% Color = ['r','g','b','k'];
% for N = 1:4
%     h22(N) = animatedline('Color',Color(N),'LineWidth',2);
% end
% axis([0,2255,-1,1])
%% 简约三指构型可视化
%融合约束卡尔曼
viewer = fusiondemo.OrientationViewer;
figure;
set (gcf,'Position',[100,100,2100,1100], 'color','w')
subplot(1,2,1);
title('融合约束卡尔曼系统');
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
%% 无约束卡尔曼
% figure;
% set (gcf,'Position',[100,0,1600,1000], 'color','w')
subplot(1,2,2);
title('无约束卡尔曼系统');
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
Hha1 = animatedline('DisplayName', 'hand_1', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
Hhi1 = animatedline('DisplayName', 'index_1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
Hhi2 = animatedline('DisplayName', 'index_2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
Hha2 = animatedline('DisplayName', 'hand_2', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
Hhm1 = animatedline('DisplayName', 'middle_1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
Hhm2 = animatedline('DisplayName', 'middle_2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
Hht0 = animatedline('DisplayName', 'ht0', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
Hht1 = animatedline('DisplayName', 'ht1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
Hht2 = animatedline('DisplayName', 'ht2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
%% 开始准备
% ti=tic;
format long g;
% ReadFileName = ".\data\原始数据242901344242.csv";
% Data_row = load(ReadFileName);

%% 解除串口占用
delete(instrfindall);
delay = .000001;

%% 串口参数设置
serialPort = 'COM3';   %串口号，根据设备实际连接
s = serial(serialPort, 'BaudRate', 115200);

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


%% 新建或打开数据文件,文件路径根据实际
% str1 = '%f';
% str2 = '%f';
% str3 = '%f';
% str4 = '%f';
% for i = 2:IMU_num*9
%     str1=strcat(str1, ',%f');
%     if(i<=IMU_num*3)
%        str2 = strcat(str2, ',%f'); 
%     end
%     if(i<=IMU_num*4)
%        str3 = strcat(str3, ',%f'); 
%     end
%     if(i<=4)
%        str4 = strcat(str4, ',%f'); 
%     end
% end
% str1 = strcat(str1, ',%f\n');
% str2 = strcat(str2, '\n');
% str3 = strcat(str3, '\n');
% str4 = strcat(str4, '\n');
% fileID1 = fopen(strcat('.\data\','原始数据',num2str(ti),'.csv'),'a');
% fileID2 = fopen(strcat('.\data\','角度结果',num2str(ti),'.csv'),'a');
% fileID3 = fopen(strcat('G:\myw\研究生阶段文档\毕业流程规范\约束求解方法\data\绕单个轴旋转约束\仅约束P4结果\','仅约束P4四元数结果',num2str(ti),'.csv'),'a');
% fileID8 = fopen(strcat('.\data\','两个IMU姿态差异结果',num2str(ti),'.csv'),'a');
count=1;
Dis_Count = 0;
%% 约束变量，姑且设置q4的范围为[-0.5，0.5]

%% 采集数据
while true
    Input = fscanf(s,'%f')';
    if length(Input)==IMU_num*9+1
        Dis_Count = Dis_Count + 1;
        if mod(Dis_Count,100) == 0
            disp(Dis_Count)
%             disp(X_k')
%             disp(asin(Hand_posture(4*4-2))/pi*360);
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
        [Unconstrained_X_k,Unconstrained_P_k] = Func_getSingleIMUattitude(Unconstrained_X_k,Unconstrained_P_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num);%%这个是更新的。
%         disp(count)
%         % 这个要做姿态解算 用四元数做差的形式进行姿态解算        
%         Q_diff_IK = Func_crossProductFu(X_k(5:8),X_k(1:4));%求一个圈X
%         
%         if count == 10
%             X_k(1:4) = -X_k(1:4);
%             count = count + 1 ;
%         end
         %% 添加约束
%         %范围，sin 75°/2 = 0.608761429008721
%         %范围，sin 110°/2 = 0.819152044288992
%         %对三手指的外关节角进行约束
        x0 = X_k;
        fun=@(x)((x-x0)'*(x-x0));
%         fun=@(x)(((x - x0)'/P_k) *(x - x0));
%         fun=@(x)((Func_crossProductFu(x(1:4),x(5:8)) -
%         Func_crossProductFu(x0(1:4),x0(5:8)))'*(Func_crossProductFu(x(1:4),x(5:8))
%         - Func_crossProductFu(x0(1:4),x0(5:8))));洗漱
        A=[];   %不等式约束系数  [-0.5,0.5]
        b=[];   %不等式约束常数
        Aeq=[]; %等式约束系数
        beq=[]; %等式约束常数
        lb=[];  %下界
        ub=[];  %上界
        nonlcon=@Func_getHandJointConstraints;% 这里存在非线性的不等式约束，即对关节角进行约束;
        options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'active-set');% interior-point % sqp
% %         options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');% interior-point % sqp
        [X_k, fval, exitflag, output, lambda, grad, hessian]=fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
        %% 归一化
        for N=1:IMU_num
            X_k(4*N-3:4*N) = X_k(4*N-3:4*N)/norm(X_k(4*N-3:4*N));
            Unconstrained_X_k(4*N-3:4*N) = Unconstrained_X_k(4*N-3:4*N)/norm(Unconstrained_X_k(4*N-3:4*N));            
        end
%         F_Z(1:4) = F_Z(1:4)/norm(F_Z(1:4));
%         F_Z(5:8) = F_Z(5:8)/norm(F_Z(5:8));
%         P_k = inv(hessian)*P_k*inv(hessian)';
%         Q_diff = Func_crossProductFu(X_k(1:4),X_k(5:8));
%         Q_diff2 = Func_crossProductFu(F_Z(1:4),F_Z(5:8));
        %% 计算所需要的7个姿态信息
        Hand_posture(1*4-3:1*4) =  X_k(6*4-3:6*4);%手部姿态信息
%         Hand_posture(1*4-3:1*4) = X_k(4*4-3:4*4);%手部姿态信息
        Hand_posture(2*4-3:2*4) = Func_getJointPosture(X_k,2,1);%拇指外关节
        Hand_posture(3*4-3:3*4) = Func_getJointPosture(X_k,3,2);%拇指内关节        
        Hand_posture(4*4-3:4*4) = Func_getJointPosture(X_k,5,4);%食指外关节
        Hand_posture(5*4-3:5*4) = Func_getJointPosture(X_k,6,5);%食指内关节
        Hand_posture(6*4-3:6*4) = Func_getJointPosture(X_k,7,8);%中指外关节
        Hand_posture(7*4-3:7*4) = Func_getJointPosture(X_k,6,7);%中指内关节
        %% 简约三指构型可视化
        Func_ShowHand(X_k',ha1,hi1,hi2,ha2,hm1,hm2,ht0,ht1,ht2)
        %% 无约束可视化
        Func_ShowHand(Unconstrained_X_k',Hha1,Hhi1,Hhi2,Hha2,Hhm1,Hhm2,Hht0,Hht1,Hht2)
        %% 朴素曲线可视化
% %         for N=1:7
% %             iplot_q(Hand_posture(4*N-3:4*N)', hx(N),hy(N),hz(N));
% %         end
% 
% %         N=2;
% %         iplot_q(X_k(5:8)', hx(N),hy(N),hz(N));
%         indexNumber = Dis_Count;
%         for N = 1:4
% %             %查看输出关节姿态的
%             addpoints(h(N),indexNumber,Hand_posture(N));
%             addpoints(h2(N),indexNumber,Hand_posture(1*4+N));
%             addpoints(h3(N),indexNumber,Hand_posture(2*4+N));
%             addpoints(h4(N),indexNumber,Hand_posture(3*4+N));
%             addpoints(h5(N),indexNumber,Hand_posture(4*4+N));
%             addpoints(h6(N),indexNumber,Hand_posture(5*4+N));
%             addpoints(h7(N),indexNumber,Hand_posture(6*4+N));
%             %查看单个IMU的
% %             addpoints(h(N),indexNumber,X_k(N)); 
% %             addpoints(h2(N),indexNumber,X_k(1*4+N));
% %             addpoints(h3(N),indexNumber,X_k(2*4+N));
% %             addpoints(h4(N),indexNumber,X_k(3*4+N));
% %             addpoints(h5(N),indexNumber,X_k(4*4+N));
% %             addpoints(h6(N),indexNumber,X_k(5*4+N));
% %             addpoints(h7(N),indexNumber,X_k(6*4+N));
% %             addpoints(h8(N),indexNumber,X_k(7*4+N));
%         end
%         if mod(indexNumber,Axis_num) == 0
%             for N = 1:8
%                 subplot(4,2,N);
%     %             axis([indexNumber-500,indexNumber,-1,1])
%                 axis([floor(indexNumber/Axis_num)*Axis_num,Axis_num*(1+floor(indexNumber/Axis_num)),-1,1])
%             end
%         end
%         drawnow limitrate nocallbacks
        %% 文件输出
%         str4 = Input+datestr(now);
%         fprintf(fileID1, str1, Input);
%         fprintf(fileID2, str2, Euler_k);
%         fprintf(fileID3, str3, X_k);
%         fprintf(fileID3, str4, F_Z);
%         fprintf(fileID8, str4, Q_diff);
%         disp(X_k(5:8)');

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