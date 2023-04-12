%% �ýű��ǽ��������۲�ʵ�����ݵģ�û�����Լ��
%% ������� 
% addpath('quaternion_library');      % include quaternion library
close all;                          % close all figures
clear;                              % clear all variables
clc;                                % clear the command terminal

% �����������IMUӲ����Ŀ
IMU_num = 8;
PI = 3.1415926;
sigma_g = 0.004; % �����ǵ�������׼��
sigma_a = 0.014; % ���ٶȼƵ�������׼��
sigma_m = 0.001; % �����Ƶ�f������׼��

Sigma_g = eye(IMU_num*3)*sigma_g*sigma_g; % �����ǵı�׼�����
Sigma_a = eye(3)*(sigma_a*sigma_a)/(9.81)^2; % ���ص��������ٶȣ�ʹ��9.8m/s2
Sigma_m = eye(3)*(sigma_m*sigma_m)/(0.53)^2; % ����վ��ȡ�����еĴų�ǿ��0.53G

Sigma_u = [Sigma_a,  zeros(3);
           zeros(3), Sigma_m];

% Ԥ�����ڴ�ռ䣬���ڴ洢���յ���IMUԭʼ����
a = zeros(3, IMU_num);
g = zeros(3, IMU_num);
m = zeros(3, IMU_num);
rotateMatrix = zeros(IMU_num*4, IMU_num*4);
P_k = eye(IMU_num*4, IMU_num*4);
% R_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);
Z_k = zeros(IMU_num*4, 1);
Euler_k = zeros(IMU_num*3, 1);
load('Xishu8IMU.mat');%��ϵ�����ؽ���������ΪNiheA  һ����IMU_num�У�6�У��ֱ��Ӧϵ����ƫ��

%% ���ƿ��ӻ�ͼ�εĳ�ʼ������


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
%% �������ռ��
delete(instrfindall);
delay = .000001;

%% ���ڲ�������
serialPort = 'COM3';   %���ںţ������豸ʵ������
s = serial(serialPort, 'BaudRate', 115200);

% s.BytesAvailableFcnMode='byte';  % ��������
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
%% �ɼ�����
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
        
        % ��IMU��ԭʼ���ݽ��յ��ڴ�ռ�ı�����
        for N = 1:IMU_num
            a(:,N) = Input(N*9-9+1:N*9-9+3)';
            g(:,N) = Input(N*9-9+4:N*9-9+6)'*PI/180;
            % ���ڴ����Ƶ����ݣ���Ҫע�⣺
            % �����Ƶ�����ϵ�������Ǽ��ٶȼƵ�����ϵ��ͬ��
            % ��Ҫ�������ʱ�򽫴����Ƶ�����ϵת�����������Ǻͼ��ٶȼ���ͬ������ϵ�� X��Y������Zȡ��
            % ���뵥λΪuT��1e-6T��,�ر�ų�ǿ�ȷ�Χ0.25--0.65 gauss��1e-4T��
            m(1,N) = ((Input(N*9-9+8)-NiheA(2,N))*NiheA(5,N))*(1e-3);% here use 1e-3.
            m(2,N) = ((Input(N*9-9+7)-NiheA(1,N))*NiheA(4,N))*(1e-3);
            m(3,N) = -(Input(N*9-9+9)-NiheA(3,N))*NiheA(6,N)*(1e-3);
            a(:,N) = a(:,N)./norm(a(:,N));
            m(:,N) = m(:,N)./norm(m(:,N));
        end
        deltatTime = Input(IMU_num*9+1);%����ط����ˣ������
        %% ����IMU��̬���        
        [X_k,P_k,Z_k] = Func_getSingleIMUattitude(X_k,P_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num);%%����Ǹ��µġ�
        % ���Ҫ����̬���� ����Ԫ���������ʽ������̬����
%         Q_diff = Func_crossProductFu(X_k(5:8),X_k(1:4));%��һ��ȦX

                %% ���Լ��
%         x0 = Q_diff;
% %         fun=@(x)((x-x0)'/diag([1,1,1,1]))*(x-x0);
%         fun=@(x)((x-x0)'*(x-x0));
%         A=[0,1,0,0;0,-1,0,0];   %����ʽԼ��ϵ��  [-0.5,0.5]
%         b=[0.7;0.7];   %����ʽԼ������
% %         A=[];   %����ʽԼ��ϵ��  [-0.5,0.5]
% %         b=[];   %����ʽԼ������
% %         Aeq=[0,0,1,0;0,1,0,0]; %��ʽԼ��ϵ��
% %         beq=[0;0]; %��ʽԼ������
%         Aeq=[]; %��ʽԼ��ϵ��
%         beq=[]; %��ʽԼ������
%         lb=[];  %�½�
%         ub=[];  %�Ͻ�
%         nonlcon=@nonfunction;% ������ڷ����ԵĲ���ʽԼ��������ģΪ1;
%         options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'active-set');% interior-point % sqp
% %         options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');% interior-point % sqp
%         [Q_diff_const, fval, exitflag, output, lambda, grad, hessian]=fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
        
        
        
        %% �ǶȻ���
%         Euler_k = zeros(IMU_num*3,1);
%         for N = 1:IMU_num
%             X_k(N*4-3:N*4) = X_k(N*4-3:N*4)./norm(X_k(N*4-3:N*4));
%             % ת��Ϊŷ����
%             [yaw, pitch, roll]=quat2angle(X_k(N*4-3:N*4)','XYZ');%'ZYX'
%             Euler_k(N*3-2:N*3)=[yaw, pitch, roll]*(180/pi);
% %             disp(Euler_k');
%         end
        
%         Q_diff = Func_crossProductFu(X_k(1:4),X_k(5:8));
        
%         Angle = [yaw, pitch, roll,0];
        
%         %% ���ӻ�
% %         for N=1:IMU_num
%         N=1;
%         iplot_q(X_k(1:4)', hx(N),hy(N),hz(N));
% %         end
%         N=2;
%         iplot_q(X_k(5:8)', hx(N),hy(N),hz(N));
%         N=3;
%         iplot_q(Q_diff', hx(N),hy(N),hz(N));
        
        for N = 1:4
            addpoints(h(N),M_ave_Count,X_k(N));%'r','g','b','k'��������
%             addpoints(h2(N),M_ave_Count,X_k(4+N));%'r','g','b','k'��������
%             addpoints(h3(N),M_ave_Count,Q_diff_const(N));%'r','g','b','k'��������
        end
        drawnow limitrate nocallbacks
%         subplot(3,1,1);
        axis([M_ave_Count-500,M_ave_Count,-1,1])
%         subplot(3,1,2);
%         axis([M_ave_Count-500,M_ave_Count,-1,1])
%         subplot(3,1,3);
%         axis([M_ave_Count-500,M_ave_Count,-1,1])

        
    else
        disp(Input);  %��ʾ���ݣ���ȡ״̬�ɼ������п���
        disp('error data');
        count = count+1;
        if count > 2+IMU_num
            disp('count error, break...');
            break;
        end
    end
end

%�ر��ļ�
% fclose('all');
fclose(s);
% clear fileID1 fileID2 fileID3;
disp('End...');