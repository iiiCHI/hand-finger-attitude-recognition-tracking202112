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
load('Xishu_8.mat');%��ϵ�����ؽ���������ΪNiheA  һ����IMU_num�У�6�У��ֱ��Ӧϵ����ƫ��

Total_answer = zeros(20*3);
Tilt = [0,30,60];
Bend = [0,30,45,60,90];
for i = 0:14
Index_Tilt = floor(i/5)+1;
Index_Bend = mod(i,5)+1;
% Flagiii = mod(i,2);%������Լ����ż������Լ��   
Flagiii = 1; 
ReadFileName = "..\data\�ԱȽ��\"+num2str(Tilt(Index_Tilt))+"\"+num2str(Bend(Index_Bend))+".csv";
Data_row = xlsread(ReadFileName);    

P_k = eye(IMU_num*4, IMU_num*4);
X_k = zeros(IMU_num*4, 1);

Hand_posture = zeros(size(Data_row,1),7*4);%���ڴ�� �ֲ���̬��Ĵָ�����ؽ���̬��ʳָ�����ؽ���̬����ָ�����ؽ���̬
%% ��ʼ׼��
format long g;
count=1;
buffer = [];
Dis_Count = 0;
%% Լ����������������q4�ķ�ΧΪ[-0.5��0.5]
All_number = length(Data_row(:,1));
%% �ɼ�����
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

%         
         %% ���Լ��
%         %��Χ��sin 75��/2 = 0.608761429008721
%         %��Χ��sin 110��/2 = 0.819152044288992
%         %������ָ����ؽڽǽ���Լ��
        x0 = X_k;
        fun=@(x)((x-x0)'*(x-x0));
        A=[];   %����ʽԼ��ϵ��  [-0.5,0.5]
        b=[];   %����ʽԼ������
        Aeq=[]; %��ʽԼ��ϵ��
        beq=[]; %��ʽԼ������
        lb=[];  %�½�
        ub=[];  %�Ͻ�
        nonlcon=@Func_getHandJointConstraints;% ������ڷ����ԵĲ���ʽԼ�������Թؽڽǽ���Լ��;
        options=optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'active-set');% interior-point
        if Flagiii == 1
            [X_k, fval, exitflag, output, lambda, grad, hessian]=fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
        end
        %% ��һ��
        for N=1:IMU_num
            X_k(4*N-3:4*N) = X_k(4*N-3:4*N)/norm(X_k(4*N-3:4*N));
        end
        %% ��������Ҫ��7����̬��Ϣ
        Hand_posture(Dis_Count,1*4-3:1*4) =  X_k(6*4-3:6*4);%�ֲ���̬��Ϣ
        Hand_posture(Dis_Count,2*4-3:2*4) = Func_getJointPosture(X_k,2,1);%Ĵָ��ؽ�
        Hand_posture(Dis_Count,3*4-3:3*4) = Func_getJointPosture(X_k,3,2);%Ĵָ�ڹؽ�        
        Hand_posture(Dis_Count,4*4-3:4*4) = Func_getJointPosture(X_k,5,4);%ʳָ��ؽ�
        Hand_posture(Dis_Count,5*4-3:5*4) = Func_getJointPosture(X_k,6,5);%ʳָ�ڹؽ�
        Hand_posture(Dis_Count,6*4-3:6*4) = Func_getJointPosture(X_k,7,8);%��ָ��ؽ�
        Hand_posture(Dis_Count,7*4-3:7*4) = Func_getJointPosture(X_k,6,7);%��ָ�ڹؽ�
%         buffer(end+1,:) =  X_k;
end
% Cos_angle = acos(abs(Hand_posture(:,4*4-3)))/pi*360;
Cos_angle = asin(abs(Hand_posture(:,4*4-2)))/pi*360;
% ��׼��std(Cos_angle)
Rmse = sqrt(sum((Cos_angle-Bend(Index_Bend)).*(Cos_angle-Bend(Index_Bend)))/All_number);
disp(['��б�Ƕ�:',num2str(Tilt(Index_Tilt)),',�����Ƕ�:',num2str(Bend(Index_Bend)),',ƽ��ֵΪ:',num2str(mean(Cos_angle)),'��,�������Ϊ:',num2str(Rmse),',��׼��Ϊ:',num2str(std(Cos_angle))])


%�ر��ļ�
% disp('End...');
end