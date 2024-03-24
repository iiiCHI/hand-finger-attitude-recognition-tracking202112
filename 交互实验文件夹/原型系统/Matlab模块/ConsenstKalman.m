function ConsenstKalman()

%% ������ƹ����ļ�
import java.awt.Robot;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.event.InputEvent;


%addpath('D:\MATLAB\WorkSpace\MaYongWei\���ߴ������\');
addpath('E:\WorkSpace\MaYongWei\���ߴ������\');
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
window_size = 3;
windowX = zeros(1, window_size); % �������е�X��
windowY = zeros(1, window_size); % �������е�Y��
IsInClickDown = false;


%% ���ƿ��ӻ�ͼ�εĳ�ʼ������
% %% ��Լ��ָ���Ϳ��ӻ�
% viewer = fusiondemo.OrientationViewer;
FigHandAll = figure(1);
set(FigHandAll,'MenuBar', 'none', 'ToolBar', 'none');
set (gcf,'Position',[500,500,900,900], 'color','w')
axis([-2 2 -2 2 -2 2]);
view(-30, 10);
grid on; % ��ʾ����
% axis VIS3D;
ha1 = animatedline('DisplayName', 'hand_1', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hi1 = animatedline('DisplayName', 'index_1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hi2 = animatedline('DisplayName', 'index_2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
ha2 = animatedline('DisplayName', 'hand_2', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hm1 = animatedline('DisplayName', 'middle_1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hm2 = animatedline('DisplayName', 'middle_2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
ht0 = animatedline('DisplayName', 'ht0', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
ht1 = animatedline('DisplayName', 'ht1', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
ht2 = animatedline('DisplayName', 'ht2', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
% ��2��ʼ��2-7�ֱ���Ĵָ��ʳָ����ָ��mcp��pip 

%% �������߿��ӻ�
Axis_num = 425;
figure (2);
title('ĴָPIP�ؽ�');
Color = ['r','g','b','k'];
for N = 1:4
    h2(N) = animatedline('Color',Color(N),'LineWidth',2);
end
%legend('Q1','Q2','Q3','Q4');
axis([0,Axis_num,-1,1])

figure (3);
title('ĴָMCP�ؽ�');
Color = ['r','g','b','k'];
for N = 1:4
    h3(N) = animatedline('Color',Color(N),'LineWidth',2);
end
%legend('Q1','Q2','Q3','Q4');
axis([0,Axis_num,-1,1])

figure (4);
title('ʳָPIP�ؽ�');
Color = ['r','g','b','k'];
for N = 1:4
    h4(N) = animatedline('Color',Color(N),'LineWidth',2);
end
%legend('Q1','Q2','Q3','Q4');
axis([0,Axis_num,-1,1])

figure (5);
title('ʳָMCP�ؽ�');
Color = ['r','g','b','k'];
for N = 1:4
    h5(N) = animatedline('Color',Color(N),'LineWidth',2);
end
%legend('Q1','Q2','Q3','Q4');
axis([0,Axis_num,-1,1])

figure (6);
title('��ָPIP�ؽ�');
Color = ['r','g','b','k'];
for N = 1:4
    h6(N) = animatedline('Color',Color(N),'LineWidth',2);
end
%legend('Q1','Q2','Q3','Q4');
axis([0,Axis_num,-1,1])

figure (7);
title('��ָMCP�ؽ�');
Color = ['r','g','b','k'];
for N = 1:4
    h7(N) = animatedline('Color',Color(N),'LineWidth',2);
end
%legend('Q1','Q2','Q3','Q4');
axis([0,Axis_num,-1,1])



% ��ȡ��ǰ�򿪵����� figure
figs = findobj('Type', 'figure');

% ����ÿ�� figure�����رղ˵����͹�����
for i = 1:length(figs)
    set(figs(i), 'MenuBar', 'none', 'ToolBar', 'none');
end

%% ���紮�ڲ�������
% %% TCP����
% disp('����������ʼ���ô��ڡ�������');
% s = tcpserver('192.168.1.103',8080,"Timeout",1);
% s.InputBufferSize = 30000;
% disp('�ȴ����紮�ڽ��룺\n');
% while s.Connected == 0
%    pause(0.5);
% end
% disp('���ڽ���ɹ���ѭ����ȡ����:\n');z
% flush(s)
%% UDP����
% ���� UDP ����
udpPort = 8080;  % ѡ��һ��δ��ʹ�õĶ˿ں�
try
fclose(instrfindall('RemoteHost', '192.168.1.103', 'RemotePort', 8080));  % �ر�����
catch
end
%% 
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
str2 = '%f';
for i = 3:(7*4)%��ʾ�߸��ؽڣ�ÿ���ؽ��ĸ�����
    str1=strcat(str1, ',%f');
end
for i = 3:(9*8+1)%��ʾ�߸��ؽڣ�ÿ���ؽ��ĸ�����
    str2=strcat(str2, ',%f');
end
str1 = strcat(str1, ',%f');
str2 = strcat(str2, ',%f');
FileName = strcat('.\rowdataHandPosture.csv');
FileNameIMU = strcat('.\rowdataIMU.csv');
fileID1 = fopen(FileName,'a');
fileIDIMU = fopen(FileNameIMU,'a');

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
    %try
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
            fun=@(x)((x-X_k)'*(x-X_k));
%             [X_k, fval, exitflag, output, lambda, grad, hessian]=fmincon(fun,X_k,A,b,Aeq,beq,lb,ub,nonlcon,options);
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
%             if ~IsInClickDown && func_MeetCondition(Hand_posture(2*4-3:2*4),2,[0.5,1]) && func_MeetCondition(Hand_posture(4*4-3:4*4),2,[0.5,1])
            if ~IsInClickDown && func_MeetCondition(Hand_posture(4*4-3:4*4),2,[0.5,1])
                funcControlMouseClickDown()
                IsInClickDown=true;
                funcControlMouseClickUp()
            end
%             if IsInClickDown&& func_MeetCondition(Hand_posture(2*4-3:2*4),2,[0,0.5]) || func_MeetCondition(Hand_posture(4*4-3:4*4),2,[0,0.5])
            if IsInClickDown&& func_MeetCondition(Hand_posture(4*4-3:4*4),2,[0,0.5])
                IsInClickDown=false;
            end
            PreX = Hand_posture(1:4);


        %% ���ӻ�
        % ��Լ��ָ���Ϳ��ӻ�
        Func_ShowHand(X_k',ha1,hi1,hi2,ha2,hm1,hm2,ht0,ht1,ht2,1)

        for N = 1:4
            %�鿴����ؽ���̬��
%             addpoints(h(N),indexNumber,Hand_posture(N));
            addpoints(h2(N),count,Hand_posture(1*4+N));
            addpoints(h3(N),count,Hand_posture(2*4+N));
            addpoints(h4(N),count,Hand_posture(3*4+N));
            addpoints(h5(N),count,Hand_posture(4*4+N));
            addpoints(h6(N),count,Hand_posture(5*4+N));
            addpoints(h7(N),count,Hand_posture(6*4+N));
        end
        if mod(count,Axis_num) == 0
            for N = 2:7
                figure (N);
    %             axis([indexNumber-500,indexNumber,-1,1])
                axis([floor(count/Axis_num)*Axis_num,Axis_num*(1+floor(count/Axis_num)),-1,1])
            end
        end
        drawnow limitrate nocallbacks

        %% ���ݱ���
%             t = posixtime(datetime('now', 'TimeZone', 'UTC')) * 1000;
%             fprintf(fileID1, str1, Hand_posture);
%             fprintf(fileID1,',%f\n',t);
%             fprintf(fileIDIMU, str2, Input);
%             fprintf(fileIDIMU, ',%f\n', t);
            %fprintf(fileIDIMU, ',%s\n', datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
        else
            if length(Input) == 0
                flag = flag + 1;
            end
            disp(string(count)+'->'+string(flag)+'->'+string(length(Input))+"ƽ��ʱ��Ϊ:"+string(seconds(datetime - dtm)/(count-count_pre)));
            count_pre = count;
            %disp(Input');
            dtm = datetime;
            if flag >= 11 
                break;
            end
        end
%     catch err
%         disp(err);
%         disp('Error');
%         break;
%     end
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
% funcControlMouse ����Ԫ��ת��Ϊ�ռ�����
% ���룺
%     ����Ԫ���ı仯ֵ
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
    %disp("----")
    x1 = sign(x(2))*(x(2)*x(2)*30000)+0.05;
    y1 = sign(y(3))*(y(3)*y(3)*30000);
    if abs(x1) < 0.1
        x1 = 0;
    end
    if abs(y1) < 0.1
        y1 = 0;
    end
    %��ֵ�˲� window
    windowX = windowX(:,2:end);
    windowX = [windowX,x1];
    windowY = windowY(:,2:end);
    windowY = [windowY,y1];

    robot.mouseMove(currentX+median(sort(windowX)), currentY+median(sort(windowY)));
end


function funcControlMouseClickDown()
    robot.mousePress(InputEvent.BUTTON1_MASK);
end


function funcControlMouseClickUp()
    robot.mouseRelease(InputEvent.BUTTON1_MASK);
end

end


