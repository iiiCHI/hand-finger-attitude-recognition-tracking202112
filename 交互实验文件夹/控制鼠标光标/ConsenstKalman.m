function ConsenstKalman()

%% 引入控制光标的文件
import java.awt.Robot;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.event.InputEvent;


addpath('D:\MATLAB\WorkSpace\MaYongWei\无线传输代码\');
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

%% 预分配内存空间，用于存储接收到的IMU原始数据
a = zeros(3, IMU_num);
g = zeros(3, IMU_num);
m = zeros(3, IMU_num);
P_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);
Hand_posture = zeros(7*4, 1);%用于存放 手部姿态，拇指两个关节姿态，食指两个关节姿态，中指两个关节姿态
NiheA=load('Xishu.mat').NiheA;%把系数加载进来，名字为NiheA  一共有IMU_num列，6行，分别对应系数与偏差
PreX = [1,0,0,0];%用来保存上一时刻的姿态的
%% 设置中值滤波
% window_size = 5;
% medians = zeros(5, 4); % 五行四列，
IsInClickDown = false;

%% 网络串口参数设置
% %% TCP连接
% disp('…………开始设置串口…………');
% s = tcpserver('192.168.1.103',8080,"Timeout",1);
% s.InputBufferSize = 30000;
% disp('等待网络串口接入：\n');
% while s.Connected == 0
%    pause(0.5);
% end
% disp('串口接入成功，循环读取数据:\n');
% flush(s)
%% UDP连接
% 创建 UDP 对象
udpPort = 8080;  % 选择一个未被使用的端口号
s = udp('192.168.1.103', udpPort, 'LocalPort', udpPort);
set(s, 'InputBufferSize', 4096); % 设置输入缓冲区大小
set(s, 'Timeout', 2); % 设置等待时间为 5 秒
% 打开 UDP 连接
fopen(s);
disp(['Listening on UDP port ', num2str(udpPort)]);


%% 约束变量，姑且设置q4的范围为[-0.5，0.5]
A=[];   %不等式约束系数  [-0.5,0.5]
b=[];   %不等式约束常数
Aeq=[]; %等式约束系数
beq=[]; %等式约束常数
lb=[];  %下界
ub=[];  %上界
nonlcon=@Func_getHandJointConstraints;% 这里存在非线性的不等式约束，即对关节角进行约束;
options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');% interior-point % sqp


%% 新建或打开数据文件,文件路径根据实际
str1 = '%f';
for i = 3:(7*4)%表示七个关节，每个关节四个数字
    str1=strcat(str1, ',%f');
end
str1 = strcat(str1, ',%f\n');
FileName = strcat('.\rowdata3.csv');
%fileID1 = fopen(FileName,'a');

%% 开始准备
drawnow limitrate nocallbacks
flag = 0;
dtm = datetime;
count_pre = 0;
count=1;
Dis_Count = 0;

% 创建Robot对象
robot = Robot();
%% 采集数据
while true
    count = count+1;
    try
        Input = fscanf(s,'%f')';   
        if length(Input)==IMU_num*9+1
            Dis_Count = Dis_Count + 1;
            if mod(Dis_Count,100) == 0
                disp(Dis_Count)
    %             disp(X_k')
    %             disp(asin(Hand_posture(4*4-2))/pi*360);
%                 disp(Hand_posture(4*4-3:4*4));
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
                m(:,N) = m(:,N)./norm(m(:,N));
            end
            deltatTime = Input(IMU_num*9+1);%这个地方改了，变成秒
            %% 单个IMU姿态求解        
            [X_k,P_k] = Func_getSingleIMUattitude(X_k,P_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num);%%这个是更新的。
             %% 添加约束
            %fun=@(x)((x-X_k)'*(x-X_k));
            %[X_k, fval, exitflag, output, lambda, grad, hessian]=fmincon(fun,X_k,A,b,Aeq,beq,lb,ub,nonlcon,options);
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
            %% 控制光标            
            funcControlMouse(Func_crossProductFu(Hand_posture(1:4),PreX)')
            %% 判断是否进入命令，执行相应的指令。
            if ~IsInClickDown && func_MeetCondition(Hand_posture(2*4-3:2*4),2,[0.5,1]) && func_MeetCondition(Hand_posture(4*4-3:4*4),2,[0.5,1])
                funcControlMouseClickDown()
                IsInClickDown=true;
                funcControlMouseClickUp()
            end
            if IsInClickDown&& func_MeetCondition(Hand_posture(2*4-3:2*4),2,[0,0.5]) && func_MeetCondition(Hand_posture(4*4-3:4*4),2,[0,0.5])
                
                IsInClickDown=false;
            end
            PreX = Hand_posture(1:4);
        %% 数据保存
            %fprintf(fileID1, str1, Hand_posture);
        else
            flag = flag + 1;
            disp(string(count)+'->'+string(flag)+'->'+string(length(Input))+"平均时间为:"+string(seconds(datetime - dtm)/(count-count_pre)));
            count_pre = count;
            disp(Input');
            dtm = datetime;
            if flag >= 21 
                break;
            end
        end
    catch err
        disp(err);
        disp('Error');
        break;
    end
end

disp('运行结束');
%关闭文件
close all
fclose('all');
fclose(instrfindall('RemoteHost', '192.168.1.103', 'RemotePort', 8080));  % 关闭连接
fclose(s);
% clear fileID1 fileID2 fileID3;
disp('End...');


function funcControlMouse(q_hand)
    % 将四元数转化为空间坐标
    x = [-1,0,0];%转的话应该是正负吧，
    y = [0,1,0];
%     z = [0,0,1];    
    x = quatrotate(q_hand, x);%表示上下//体现为z轴转的角度
    y = quatrotate(q_hand, y);%表示翻滚//但是体现为x轴转的角度
%     z = quatrotate(q_hand, z);%表示偏转//体现为y轴转的角度    
    % 获取当前鼠标的位置
    mouseInfo = MouseInfo.getPointerInfo();
    currentLocation = mouseInfo.getLocation();
    currentX = currentLocation.getX();
    currentY = currentLocation.getY();
    % 让光标移动到目标位置
    robot.mouseMove(currentX+x(2)*x(2)*x(2)*1000000, currentY+y(3)*y(3)*y(3)*1000000);
end


function funcControlMouseClickDown()
    robot.mousePress(InputEvent.BUTTON1_MASK);
end


function funcControlMouseClickUp()
    robot.mouseRelease(InputEvent.BUTTON1_MASK);
end

end


