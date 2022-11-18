function [X_K,P_K] = Func_getSingleIMUattitude(X_k,P_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num)
%% �����ǿ������˲���������̬���ļ��ɺ���
% ���������
%       X_k����һ�ֵ���ֵ̬
%       P_k����������Э����
%       a,m,g,deltatTime ��þ��������Լ�����ʱ��
%       Sigma_g,Sigma_u,�����󣬷ֱ����������Լ����ٶȼ�������Ƶ�������
%       IMU_num ��������Ŀ
% ���������
%       X_K�� ���ֵõ�����ֵ̬
%       P_k�� ϵͳ�����Э�������
% ���ߣ��º�
% 
% %% ��ȡ����IMU��̬
% while true
    %% IMU��̬��������Ƽ������
    for N = 1:IMU_num
        rotateMatrix(N*4-3:N*4,N*4-3:N*4) =  Func_getGyroRotateMatrix(g(:,N));
        omega(N*4-3:N*4,N*3-2:N*3) = Func_getOmega(X_k(N*4-3:N*4,1));
    end
    Phi = eye(IMU_num*4) + (1/2) * rotateMatrix * deltatTime;

    %% ����������ƣ���������������Э�������
    % ע�⣺X_k�ڲ�ÿһ��IMU����Ԫ����̬��ʹ��4*1����ʽ��¼
    X_k = Phi * X_k;
    Q_kminus1 = (deltatTime/2) * (deltatTime/2) * omega * Sigma_g * omega';
    P_K = Phi * P_k * Phi + Q_kminus1;
    %% �������ֵ�����¿���������
    for N = 1:IMU_num
       [Z_k(N*4-3:N*4, 1), R_k(N*4-3:N*4,N*4-3:N*4)]= Func_getMeasurementValue(a(:,N), m(:,N), Sigma_u);
       if dot(X_k(N*4-3:N*4, 1),Z_k(N*4-3:N*4, 1)) < 0
           Z_k(N*4-3:N*4, 1) = -Z_k(N*4-3:N*4, 1);
       end
    end
    K_k = (P_K) / (P_K+R_k);
    %% ���������ƣ����¹������Э����
    X_K = X_k + K_k*(Z_k-X_k);
    %�����һ������
    for N=1:IMU_num
        X_K(4*(N-1)+1:4*(N-1)+4) = X_K(4*(N-1)+1:4*(N-1)+4)./norm(X_K(4*(N-1)+1:4*(N-1)+4));
    end
    P_K = (eye(IMU_num*4)-K_k)*P_K;
end