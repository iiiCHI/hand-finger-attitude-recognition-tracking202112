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
load('Xishu_8.mat');%把系数加载进来，名字为NiheA  一共有IMU_num列，6行，分别对应系数与偏差

Total_answer = zeros(20*3);
Tilt = [0,30,60];
Bend = [0,30,45,60,90];
for i = 0:14
Index_Tilt = floor(i/5)+1;
Index_Bend = mod(i,5)+1;
% Flagiii = mod(i,2);%奇数加约束，偶数不加约束   
Flagiii = 1; 
ReadFileName = "..\data\对比结果\"+num2str(Tilt(Index_Tilt))+"\"+num2str(Bend(Index_Bend))+".csv";
Data_row = xlsread(ReadFileName);    

P_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);

Hand_posture = zeros(size(Data_row,1),7*4);%用于存放 手部姿态，拇指两个关节姿态，食指两个关节姿态，中指两个关节姿态
%% 开始准备
format long g;
count=1;
buffer = [];
Dis_Count = 0;
%% 约束变量，姑且设置q4的范围为[-0.5，0.5]
All_number = length(Data_row(:,1));
%% 采集数据
while Dis_Count < All_number
        Dis_Count = Dis_Count + 1;
        if mod(Dis_Count,100) == 0
%             disp(Dis_Count)
%             disp(X_k')
        end
    Input = Data_row(Dis_Count,:);

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

%         
         %% 添加约束
%         %范围，sin 75°/2 = 0.608761429008721
%         %范围，sin 110°/2 = 0.819152044288992
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
        options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'active-set');% interior-point
        if Flagiii == 1
            [X_k, fval, exitflag, output, lambda, grad, hessian]=fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
        end
        %% 归一化
        for N=1:IMU_num
            X_k(4*N-3:4*N) = X_k(4*N-3:4*N)/norm(X_k(4*N-3:4*N));
        end
        %% 计算所需要的7个姿态信息
        Hand_posture(Dis_Count,1*4-3:1*4) =  X_k(6*4-3:6*4);%手部姿态信息
        Hand_posture(Dis_Count,2*4-3:2*4) = Func_getJointPosture(X_k,2,1);%拇指外关节
        Hand_posture(Dis_Count,3*4-3:3*4) = Func_getJointPosture(X_k,3,2);%拇指内关节        
        Hand_posture(Dis_Count,4*4-3:4*4) = Func_getJointPosture(X_k,5,4);%食指外关节
        Hand_posture(Dis_Count,5*4-3:5*4) = Func_getJointPosture(X_k,6,5);%食指内关节
        Hand_posture(Dis_Count,6*4-3:6*4) = Func_getJointPosture(X_k,7,8);%中指外关节
        Hand_posture(Dis_Count,7*4-3:7*4) = Func_getJointPosture(X_k,6,7);%中指内关节
%         buffer(end+1,:) =  X_k;
end
% Cos_angle = acos(abs(Hand_posture(:,4*4-3)))/pi*360;
Cos_angle = asin(abs(Hand_posture(:,4*4-2)))/pi*360;
% 标准差std(Cos_angle)
Rmse = sqrt(sum((Cos_angle-Bend(Index_Bend)).*(Cos_angle-Bend(Index_Bend)))/All_number);
disp(['倾斜角度:',num2str(Tilt(Index_Tilt)),',弯曲角度:',num2str(Bend(Index_Bend)),',平均值为:',num2str(mean(Cos_angle)),'°,均方误差为:',num2str(Rmse),',标准差为:',num2str(std(Cos_angle))])


%关闭文件
% disp('End...');
end