 
%% ������� 
% addpath('quaternion_library');      % include quaternion library
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
rotateMatrix = zeros(IMU_num*4, IMU_num*4);
P_k = eye(IMU_num*4, IMU_num*4);
% R_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);
Z_k = zeros(IMU_num*4, 1);
Euler_k = zeros(IMU_num*3, 1);
load('Xishu.mat');%��ϵ�����ؽ���������ΪNiheA  һ����IMU_num�У�6�У��ֱ��Ӧϵ����ƫ��

%% ���ƿ��ӻ�ͼ�εĳ�ʼ������
% % ʹ��fusion������Ŀ��ӻ�����
% viewer = fusiondemo.OrientationViewer;
% figure;
% set (gcf,'Position',[100,0,1600,1000], 'color','w')
% subplot(1,3,1);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(1) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(1) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(1) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('KlmanIMU1, X-blue, Y-red, Z-green');
% % figure;
% subplot(1,3,2);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(2) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(2) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(2) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('ZK, X-blue, Y-red, Z-green');
% subplot(1,3,3);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(3) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(3) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(3) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('Qacc, X-blue, Y-red, Z-green');


figure;
set (gcf,'Position',[100,0,1600,1000], 'color','w')
% subplot(2,1,1);
Color = ['r','g','b','k'];
for N = 1:4
    h(N) = animatedline('Color',Color(N),'LineWidth',2);
end
% subplot(2,2,4);
% grid;
% axis equal;
% axis([-2 2 -2 2 -2 2]);
% hx(4) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hy(4) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% hz(4) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% title('Qmag, X-blue, Y-red, Z-green');
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

%% �½���������ļ�,�ļ�·������ʵ��
str1 = '%f';
str2 = '%f';
str3 = '%f';
str4 = '%f';
for i = 2:IMU_num*9
    str1=strcat(str1, ',%f');
    if(i<=IMU_num*3)
       str2 = strcat(str2, ',%f'); 
    end
    if(i<=IMU_num*4)
       str3 = strcat(str3, ',%f'); 
    end
    if(i<=4)
       str4 = strcat(str4, ',%f'); 
    end
end
str1 = strcat(str1, ',%f\n');
str2 = strcat(str2, '\n');
str3 = strcat(str3, '\n');
str4 = strcat(str4, '\n');
fileID1 = fopen(strcat('.\data\','ԭʼ����',num2str(ti),'.csv'),'a');
fileID2 = fopen(strcat('.\data\','�ǶȽ��',num2str(ti),'.csv'),'a');
fileID3 = fopen(strcat('.\data\','��Ԫ�����',num2str(ti),'.csv'),'a');
fileID8 = fopen(strcat('.\data\','����IMU��̬������',num2str(ti),'.csv'),'a');
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
        [X_k,P_k] = Func_getSingleIMUattitude(X_k,P_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num);%%����Ǹ��µġ�
        % ���Ҫ����̬���� ����Ԫ���������ʽ������̬����
        Q_diff = Func_crossProductFu(X_k(5:8),X_k(1:4));%��һ��ȦX

%         %% �ǶȻ���
%         Euler_k = zeros(IMU_num*3,1);
%         for N = 1:IMU_num
%             X_k(N*4-3:N*4) = X_k(N*4-3:N*4)./norm(X_k(N*4-3:N*4));
%             % ת��Ϊŷ����
%             [yaw, pitch, roll]=quat2angle(X_k(N*4-3:N*4)','XYZ');%'ZYX'
%             Euler_k(N*3-2:N*3)=[yaw, pitch, roll]*(180/pi);
% %             disp(Euler_k');
%         end
%         
%         Q_diff = Func_crossProductFu(X_k(1:4),X_k(5:8));
        
        %% ���Լ��������
        
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
            addpoints(h(N),M_ave_Count,Q_diff(N));%'r','g','b','k'��������
        end
%         subplot(2,1,1);
        drawnow limitrate nocallbacks
        axis([M_ave_Count-500,M_ave_Count,-1,1])
        
        %% �ļ����
%         str4 = Input+datestr(now);
        fprintf(fileID1, str1, Input);
%         fprintf(fileID2, str2, Euler_k);
        fprintf(fileID3, str3, X_k);
        fprintf(fileID8, str4, Q_diff);
        
%         disp(X_k(5:8)');
        
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
fclose('all');
fclose(s);
% clear fileID1 fileID2 fileID3;
disp('End...');