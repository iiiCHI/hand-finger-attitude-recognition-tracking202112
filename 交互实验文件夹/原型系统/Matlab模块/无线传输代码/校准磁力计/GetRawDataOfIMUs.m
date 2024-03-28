%���ݲɼ���Ϊ�����֣�1��΢��������ȡ���������ݣ�2���������ȡ΢����������������
%�ó���Ϊ�ڶ�����"2)"�����ݲɼ�,������˵����ݶ�ȡ��
%% �������
clear;
clc;
IMU_num = 2;

%% �������ռ��
delete(instrfindall);
delay = .000001;

%% ���ڲ�������
serialPort = 'COM3';   %���ںţ������豸ʵ������
s = serial(serialPort, 'BaudRate', 115200);
fopen(s);
disp('Start...');
ti=tic;
format long g;
%% �½���������ļ�,�ļ�·������ʵ��
saveformat = '%f';
for i = 2:IMU_num*9
    saveformat=strcat(saveformat, ',%f');
end
saveformat = strcat(saveformat, ',%f\n');
fileID1 = fopen(strcat('..\data\multi_IMUs_9dofdata_beforeCalib35937387949.csv'),'a');
before = [];
count=1;
flag = 0;
while flag<3000
    flag= flag+1;
    rawData = fscanf(s,'%f')';
    if length(rawData)==IMU_num*9+1
        % check NaN data
        if any(isnan(rawData))
            disp('NaN found in rawData')
            %rawData
            continue
        end
        fprintf( fileID1, saveformat, rawData);
        before(flag,:) = rawData;
        if mod(flag,1) == 0
            disp(flag);  %��ʾ���ݣ���ȡ״̬�ɼ������п���
        end
        
    else
        disp(rawData);  %��ʾ���ݣ���ȡ״̬�ɼ������п���
        disp('error data');
        count = count+1;
        if count > 5
            disp('count>5, break...');
            break;
        end
    end
end
% before = csvread('8IMUdata.csv') ;
mag_calibration(before)
%�ر��ļ�

% 


fclose('all');
fclose(s);
clear fileID1;
disp('End...');