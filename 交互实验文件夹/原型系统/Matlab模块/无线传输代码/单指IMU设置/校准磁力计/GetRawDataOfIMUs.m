%数据采集分为两部分：1）微处理器读取传感器数据；2）计算机读取微处理器传来的数据
%该程序为第二部分"2)"的数据采集,计算机端的数据读取。
%% 程序入口
clear;
clc;
IMU_num = 1;

%% 解除串口占用
delete(instrfindall);
delay = .000001;

%% 串口参数设置
serialPort = 'COM3';   %串口号，根据设备实际连接
s = serial(serialPort, 'BaudRate', 115200);
fopen(s);
disp('Start...');
ti=tic;
format long g;
% %% 新建或打开数据文件,文件路径根据实际
% saveformat = '%f';
% for i = 2:IMU_num*9
%     saveformat=strcat(saveformat, ',%f');
% end
% saveformat = strcat(saveformat, ',%f\n');
% fileID1 = fopen(strcat('..\data\multi_IMUs_9dofdata_beforeCalib35937387949.csv'),'a');
%% 开始
before = [];
count=1;
flag = 0;
while true
    rawData = fscanf(s,'%f')';
    if length(rawData)==IMU_num*9+1
        % check NaN data
        if any(isnan(rawData))
            disp('NaN found in rawData')
            %rawData
            continue
        end
        before(end+1,:) = rawData;        
    else
        flag = flag + 1;
        disp(rawData');
        if flag >= 2 + IMU_num
            break;
        end
    end
end
% before = csvread('8IMUdata.csv') ;
mag_calibration(before,IMU_num)
%关闭文件

% 


fclose('all');
fclose(s);
disp('End...');