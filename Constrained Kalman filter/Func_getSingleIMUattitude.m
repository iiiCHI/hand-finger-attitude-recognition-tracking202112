function [X_K,P_K] = Func_getSingleIMUattitude(X_k,P_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num)
%% 函数是卡尔曼滤波器进行姿态求解的集成函数
% 输入变量：
%       X_k：上一轮的姿态值
%       P_k：先验的误差协方差
%       a,m,g,deltatTime 测得九轴数据以及采样时间
%       Sigma_g,Sigma_u,误差矩阵，分别是陀螺仪以及加速度计与磁力计得误差矩阵
%       IMU_num 传感器数目
% 输出变量：
%       X_K： 本轮得到的姿态值
%       P_k： 系统的误差协方差矩阵
% 作者：温豪
% 
% %% 获取单个IMU姿态
% while true
    %% IMU姿态的先验估计计算矩阵
    for N = 1:IMU_num
        rotateMatrix(N*4-3:N*4,N*4-3:N*4) =  Func_getGyroRotateMatrix(g(:,N));
        omega(N*4-3:N*4,N*3-2:N*3) = Func_getOmega(X_k(N*4-3:N*4,1));
    end
    Phi = eye(IMU_num*4) + (1/2) * rotateMatrix * deltatTime;

    %% 计算先验估计，更新先验估计误差协方差矩阵
    % 注意：X_k内部每一个IMU的四元数姿态均使用4*1的形式记录
    X_k = Phi * X_k;
    Q_kminus1 = (deltatTime/2) * (deltatTime/2) * omega * Sigma_g * omega';
    P_K = Phi * P_k * Phi + Q_kminus1;
    %% 计算测量值，更新卡尔曼增益
    for N = 1:IMU_num
       [Z_k(N*4-3:N*4, 1), R_k(N*4-3:N*4,N*4-3:N*4)]= Func_getMeasurementValue(a(:,N), m(:,N), Sigma_u);
       if dot(X_k(N*4-3:N*4, 1),Z_k(N*4-3:N*4, 1)) < 0
           Z_k(N*4-3:N*4, 1) = -Z_k(N*4-3:N*4, 1);
       end
    end
    K_k = (P_K) / (P_K+R_k);
    %% 计算后验估计，更新估计误差协方差
    X_K = X_k + K_k*(Z_k-X_k);
    %结果归一化处理
    for N=1:IMU_num
        X_K(4*(N-1)+1:4*(N-1)+4) = X_K(4*(N-1)+1:4*(N-1)+4)./norm(X_K(4*(N-1)+1:4*(N-1)+4));
    end
    P_K = (eye(IMU_num*4)-K_k)*P_K;
end