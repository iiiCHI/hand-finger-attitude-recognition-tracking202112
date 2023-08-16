function [Hand_posture_ans,Unconstrained_Hand_posture_ans] = Func_GetKalManData(RowData,IMU_num,NiheA)
% addpath('../../../Constrained Kalman filter/');
addpath('D:\MATLAB\WorkSpace\MaYongWei\无线传输代码\');
%% 函数说明
% 输入：
% RowData：原始数据
% IMU_num: IMU的数目
% NiheA： 系数矩阵
% 输出：
% Hand_posture_ans 融合约束的结果
% Unconstrained_Hand_posture_ans无约束的结果
%% 程序开始
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
    Hand_posture_ans = [];%用于存放 手部姿态，拇指两个关节姿态，食指两个关节姿态，中指两个关节姿态
    Unconstrained_P_k = eye(IMU_num*4, IMU_num*4);
    Unconstrained_X_k = zeros(IMU_num*4, 1);
    Unconstrained_Hand_posture_ans = [];
    %% 约束变量，姑且设置q4的范围为[-0.5，0.5]
    
    [rowCount, ~] = size(RowData);  % 获取矩阵的行数
    %% 采集数据
    for i=1:rowCount
        Input = RowData(i, :); 
            % 将IMU的原始数据接收到内存空间的变量中
            for N = 1:IMU_num
                a(:,N) = Input(N*9-9+1:N*9-9+3)';
                g(:,N) = Input(N*9-9+4:N*9-9+6)'*PI/180;
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
            [X_k, ~, ~, ~, ~, ~, ~]=fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
            %% 归一化
            for N=1:IMU_num
                X_k(4*N-3:4*N) = X_k(4*N-3:4*N)/norm(X_k(4*N-3:4*N));
                Unconstrained_X_k(4*N-3:4*N) = Unconstrained_X_k(4*N-3:4*N)/norm(Unconstrained_X_k(4*N-3:4*N));            
            end
            %% 计算所需要的7个姿态信息
            Hand_posture(1*4-3:1*4) = X_k(6*4-3:6*4);%手部姿态信息
            Hand_posture(2*4-3:2*4) = Func_getJointPosture(X_k,3,2);%拇指内关节    
            Hand_posture(3*4-3:3*4) = Func_getJointPosture(X_k,2,1);%拇指外关节    
            Hand_posture(4*4-3:4*4) = Func_getJointPosture(X_k,6,5);%食指内关节
            Hand_posture(5*4-3:5*4) = Func_getJointPosture(X_k,5,4);%食指外关节
            Hand_posture(6*4-3:6*4) = Func_getJointPosture(X_k,6,7);%中指内关节
            Hand_posture(7*4-3:7*4) = Func_getJointPosture(X_k,7,8);%中指外关节
            Hand_posture_ans(end+1,:) = Hand_posture;
            % 无约束的
            Unconstrained_Hand_posture(1*4-3:1*4) = Unconstrained_X_k(6*4-3:6*4);%手部姿态信息
            Unconstrained_Hand_posture(2*4-3:2*4) = Func_getJointPosture(Unconstrained_X_k,3,2);%拇指内关节      
            Unconstrained_Hand_posture(3*4-3:3*4) = Func_getJointPosture(Unconstrained_X_k,2,1);%拇指外关节  
            Unconstrained_Hand_posture(4*4-3:4*4) = Func_getJointPosture(Unconstrained_X_k,6,5);%食指内关节
            Unconstrained_Hand_posture(5*4-3:5*4) = Func_getJointPosture(Unconstrained_X_k,5,4);%食指外关节
            Unconstrained_Hand_posture(6*4-3:6*4) = Func_getJointPosture(Unconstrained_X_k,6,7);%中指内关节
            Unconstrained_Hand_posture(7*4-3:7*4) = Func_getJointPosture(Unconstrained_X_k,7,8);%中指外关节
            Unconstrained_Hand_posture_ans(end+1,:) = Unconstrained_Hand_posture;
    end
end

