%һ�������4��ͼ�񣬷ֱ��ʾ��Klman��CkIMU֮����㷨�Ƚϡ�
%�õ�����ǰ�ܺõĴ��롣

%% ������� 
addpath('quaternion_library');      % include quaternion library
close all;                          % close all figures
clear;                              % clear all variables
clc;                                % clear the command terminal

% �����������IMUӲ����Ŀ
IMU_num = 2;
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

jointNum = 1;

rotateMatrix = zeros(IMU_num*4, IMU_num*4);
P_k = eye(IMU_num*4, IMU_num*4);
allP_k = eye(jointNum*4, jointNum*4);
R_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);

m00 = zeros(3,IMU_num);

Euler_k = zeros(IMU_num*3, 1);
load('Xishu.mat');

% load('�����ǣ���90����90��.mat');
% load('�õ����ſɱ�����ʽJandQ.mat');
%% ���ƿ��ӻ�ͼ�εĳ�ʼ������
% % ʹ��fusion������Ŀ��ӻ�����
% viewer = fusiondemo.OrientationViewer;
figure;
set (gcf,'Position',[100,0,1600,1000], 'color','w')
subplot(2,3,1);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(1) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(1) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(1) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('IKIMU1, X-blue, Y-red, Z-green');
% figure;
subplot(2,3,2);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(2) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(2) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(2) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('IKIMU2, X-blue, Y-red, Z-green');
% figure;
subplot(2,3,3);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(3) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(3) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(3) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('IKIMU_diff, X-blue, Y-red, Z-green');
subplot(2,3,4);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(4) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(4) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(4) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('MaIMU1, X-blue, Y-red, Z-green');
% figure;
subplot(2,3,5);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(5) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(5) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(5) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('MaIMU2, X-blue, Y-red, Z-green');
subplot(2,3,6);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(6) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(6) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(6) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('MaIMU_diff, X-blue, Y-red, Z-green');

%% ����׼���׶�
disp('Start...');
% format long g;
% AHRS(1) = MadgwickAHRS('SamplePeriod',0.02,'Beta',sqrt(3/4)*180*0.04/PI);%��������ǶȲ����
% AHRS(2) = MadgwickAHRS('SamplePeriod',0.02,'Beta',sqrt(3/4)*180*0.04/PI);%��������ǶȲ����
AHRS(1) = MadgwickAHRS('SamplePeriod',0.02,'Beta',sqrt(3/4)*180*0.04/PI);%��������ǶȲ����
AHRS(2) = MadgwickAHRS('SamplePeriod',0.02,'Beta',sqrt(3/4)*180*0.04/PI);%��������ǶȲ����

mager = [];
count=1;
ti=tic;

% Data_row = load('./data/����IMU����/ƫ��90��/����������ֵ/ԭʼ����9413354805789.csv');
% Data_row = load('./data/����IMU����/����90/��ת360��/ԭʼ����9429855889624.csv');
% Data_row = load('./data/����IMU����/Qmag�ϲ�/ԭʼ����9225873474198.csv');
% Data_row = load('./data/����IMU����/Qmag�ϲ�/�ϲ�2/ԭʼ����9260621504406.csv');
Data_row = load('./data/����IMU����/��������/ԭʼ����159347059366.csv');
% Data_row = load('./data/����IMU����/��ֹ����/ԭʼ����9410881611780.csv');

quaternion = zeros(IMU_num, 4);  

%% ��������
for indexNumber = 1:length(Data_row)
        Input = Data_row(indexNumber,:);
        if mod(indexNumber,100) == 0
            disp(indexNumber);
        end
        %% ��IMU��ԭʼ���ݽ��յ��ڴ�ռ�ı�����
        for N = 1:IMU_num
            a(:,N) = Input(N*9-9+1:N*9-9+3)';
            g(:,N) = Input(N*9-9+4:N*9-9+6)'*PI/180;
            m(:,N) = [Input(N*9-9+7),Input(N*9-9+8),Input(N*9-9+9)];
            m(1,N) = ((Input(N*9-9+8)-NiheA(2,N))*NiheA(5,N))*(1e-3);% here use 1e-3.
            m(2,N) = ((Input(N*9-9+7)-NiheA(1,N))*NiheA(4,N))*(1e-3);
            m(3,N) = -(Input(N*9-9+9)-NiheA(3,N))*NiheA(6,N)*(1e-3);
            
            a(:,N) = a(:,N)./norm(a(:,N));
            m(:,N) = m(:,N)./norm(m(:,N));
        end
        deltatTime = Input(IMU_num*9+1);%����ط����ˣ�����룬�������ʱ������
        %% �ܵĿ������Ĺ۲�ֵ���
        [X_k,R_k] = Func_getSingleIMUattitude(X_k,R_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num);%%����Ǹ��µġ�
        % ���Ҫ����̬���� ����Ԫ���������ʽ������̬����
        Q_diff_IK = Func_crossProductFu(X_k(5:8),X_k(1:4));%��һ��ȦX

        %% �����˲���      
        for N = 1:IMU_num
            %�ų������⣬������Ư�ƣ����զ�졣  ������IMU��⣬�����õ�%%ԭ�򣬴ų�û����Ϻ�
            AHRS(N).Update(g(:,N)', a(:,N)', m(:,N)');	% gyroscope units must be radians
            quaternion(N,:) = AHRS(N).Quaternion;
        end
        Q_diff_MA = Func_crossProductFu(quaternion(2,:),quaternion(1,:));%��һ��ȦX
        
        %% ���ӻ�
        for N=1:IMU_num
            iplot_q(quaternConj(quaternion(N,:)), hx(N+3),hy(N+3),hz(N+3));
            iplot_q(X_k(N*4-3:N*4)', hx(N),hy(N),hz(N));
        end
        iplot_q(Q_diff_IK', hx(3),hy(3),hz(3));
        iplot_q(Q_diff_MA', hx(6),hy(6),hz(6));

end
disp('End...');