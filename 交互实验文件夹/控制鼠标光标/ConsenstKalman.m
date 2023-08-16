function ConsenstKalman()

%% ������ƹ����ļ�
import java.awt.Robot;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.event.InputEvent;


addpath('D:\MATLAB\WorkSpace\MaYongWei\���ߴ������\');
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

%% Ԥ�����ڴ�ռ䣬���ڴ洢���յ���IMUԭʼ����
a = zeros(3, IMU_num);
g = zeros(3, IMU_num);
m = zeros(3, IMU_num);
P_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);
Hand_posture = zeros(7*4, 1);%���ڴ�� �ֲ���̬��Ĵָ�����ؽ���̬��ʳָ�����ؽ���̬����ָ�����ؽ���̬
NiheA=load('Xishu.mat').NiheA;%��ϵ�����ؽ���������ΪNiheA  һ����IMU_num�У�6�У��ֱ��Ӧϵ����ƫ��
PreX = [1,0,0,0];%����������һʱ�̵���̬��
%% ������ֵ�˲�
% window_size = 5;
% medians = zeros(5, 4); % �������У�
IsInClickDown = false;

%% ���紮�ڲ�������
% %% TCP����
% disp('����������ʼ���ô��ڡ�������');
% s = tcpserver('192.168.1.103',8080,"Timeout",1);
% s.InputBufferSize = 30000;
% disp('�ȴ����紮�ڽ��룺\n');
% while s.Connected == 0
%    pause(0.5);
% end
% disp('���ڽ���ɹ���ѭ����ȡ����:\n');
% flush(s)
%% UDP����
% ���� UDP ����
udpPort = 8080;  % ѡ��һ��δ��ʹ�õĶ˿ں�
s = udp('192.168.1.103', udpPort, 'LocalPort', udpPort);
set(s, 'InputBufferSize', 4096); % �������뻺������С
set(s, 'Timeout', 2); % ���õȴ�ʱ��Ϊ 5 ��
% �� UDP ����
fopen(s);
disp(['Listening on UDP port ', num2str(udpPort)]);


%% Լ����������������q4�ķ�ΧΪ[-0.5��0.5]
A=[];   %����ʽԼ��ϵ��  [-0.5,0.5]
b=[];   %����ʽԼ������
Aeq=[]; %��ʽԼ��ϵ��
beq=[]; %��ʽԼ������
lb=[];  %�½�
ub=[];  %�Ͻ�
nonlcon=@Func_getHandJointConstraints;% ������ڷ����ԵĲ���ʽԼ�������Թؽڽǽ���Լ��;
options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');% interior-point % sqp


%% �½���������ļ�,�ļ�·������ʵ��
str1 = '%f';
for i = 3:(7*4)%��ʾ�߸��ؽڣ�ÿ���ؽ��ĸ�����
    str1=strcat(str1, ',%f');
end
str1 = strcat(str1, ',%f\n');
FileName = strcat('.\rowdata3.csv');
%fileID1 = fopen(FileName,'a');

%% ��ʼ׼��
drawnow limitrate nocallbacks
flag = 0;
dtm = datetime;
count_pre = 0;
count=1;
Dis_Count = 0;

% ����Robot����
robot = Robot();
%% �ɼ�����
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
                m(:,N) = m(:,N)./norm(m(:,N));
            end
            deltatTime = Input(IMU_num*9+1);%����ط����ˣ������
            %% ����IMU��̬���        
            [X_k,P_k] = Func_getSingleIMUattitude(X_k,P_k,a,m,g,deltatTime,Sigma_g,Sigma_u,IMU_num);%%����Ǹ��µġ�
             %% ���Լ��
            %fun=@(x)((x-X_k)'*(x-X_k));
            %[X_k, fval, exitflag, output, lambda, grad, hessian]=fmincon(fun,X_k,A,b,Aeq,beq,lb,ub,nonlcon,options);
            %% ��һ��
            for N=1:IMU_num
                X_k(4*N-3:4*N) = X_k(4*N-3:4*N)/norm(X_k(4*N-3:4*N));
            end
            %% ��������Ҫ��7����̬��Ϣ
            Hand_posture(1*4-3:1*4) =  X_k(6*4-3:6*4);%�ֲ���̬��Ϣ
            Hand_posture(2*4-3:2*4) = Func_getJointPosture(X_k,2,1);%Ĵָ��ؽ�
            Hand_posture(3*4-3:3*4) = Func_getJointPosture(X_k,3,2);%Ĵָ�ڹؽ�        
            Hand_posture(4*4-3:4*4) = Func_getJointPosture(X_k,5,4);%ʳָ��ؽ�
            Hand_posture(5*4-3:5*4) = Func_getJointPosture(X_k,6,5);%ʳָ�ڹؽ�
            Hand_posture(6*4-3:6*4) = Func_getJointPosture(X_k,7,8);%��ָ��ؽ�
            Hand_posture(7*4-3:7*4) = Func_getJointPosture(X_k,6,7);%��ָ�ڹؽ�
            %% ���ƹ��            
            funcControlMouse(Func_crossProductFu(Hand_posture(1:4),PreX)')
            %% �ж��Ƿ�������ִ����Ӧ��ָ�
            if ~IsInClickDown && func_MeetCondition(Hand_posture(2*4-3:2*4),2,[0.5,1]) && func_MeetCondition(Hand_posture(4*4-3:4*4),2,[0.5,1])
                funcControlMouseClickDown()
                IsInClickDown=true;
                funcControlMouseClickUp()
            end
            if IsInClickDown&& func_MeetCondition(Hand_posture(2*4-3:2*4),2,[0,0.5]) && func_MeetCondition(Hand_posture(4*4-3:4*4),2,[0,0.5])
                
                IsInClickDown=false;
            end
            PreX = Hand_posture(1:4);
        %% ���ݱ���
            %fprintf(fileID1, str1, Hand_posture);
        else
            flag = flag + 1;
            disp(string(count)+'->'+string(flag)+'->'+string(length(Input))+"ƽ��ʱ��Ϊ:"+string(seconds(datetime - dtm)/(count-count_pre)));
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

disp('���н���');
%�ر��ļ�
close all
fclose('all');
fclose(instrfindall('RemoteHost', '192.168.1.103', 'RemotePort', 8080));  % �ر�����
fclose(s);
% clear fileID1 fileID2 fileID3;
disp('End...');


function funcControlMouse(q_hand)
    % ����Ԫ��ת��Ϊ�ռ�����
    x = [-1,0,0];%ת�Ļ�Ӧ���������ɣ�
    y = [0,1,0];
%     z = [0,0,1];    
    x = quatrotate(q_hand, x);%��ʾ����//����Ϊz��ת�ĽǶ�
    y = quatrotate(q_hand, y);%��ʾ����//��������Ϊx��ת�ĽǶ�
%     z = quatrotate(q_hand, z);%��ʾƫת//����Ϊy��ת�ĽǶ�    
    % ��ȡ��ǰ����λ��
    mouseInfo = MouseInfo.getPointerInfo();
    currentLocation = mouseInfo.getLocation();
    currentX = currentLocation.getX();
    currentY = currentLocation.getY();
    % �ù���ƶ���Ŀ��λ��
    robot.mouseMove(currentX+x(2)*x(2)*x(2)*1000000, currentY+y(3)*y(3)*y(3)*1000000);
end


function funcControlMouseClickDown()
    robot.mousePress(InputEvent.BUTTON1_MASK);
end


function funcControlMouseClickUp()
    robot.mouseRelease(InputEvent.BUTTON1_MASK);
end

end


