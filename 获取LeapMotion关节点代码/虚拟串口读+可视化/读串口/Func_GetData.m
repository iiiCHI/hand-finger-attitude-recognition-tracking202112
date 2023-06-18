%% 对得到的数据进行约束求解；

% addpath('quaternion_library');      % include quaternion library
close all;                          % close all figures
clear;                              % clear all variables
clc;                                % clear the command terminal

% 定义接入程序的IMU硬件数目
IMU_num = 8;

ti=tic;

%% 网络串口参数设置
disp('…………开始设置串口…………');
s = tcpserver('192.168.1.103',8080,"Timeout",3);
s.InputBufferSize = 30000;
disp('等待网络串口接入：\n');
while s.Connected == 0
   pause(0.5);
end
disp('串口接入成功，循环读取数据:\n');
flush(s)


%% 新建或打开数据文件,文件路径根据实际
str1 = '%f';
% str2 = '%f';
% str3 = '%f';
% str4 = '%f';
for i = 2:IMU_num*9
    str1=strcat(str1, ',%f');
%     if(i<=IMU_num*3)
%        str2 = strcat(str2, ',%f'); 
%     end
%     if(i<=IMU_num*4)
%        str3 = strcat(str3, ',%f'); 
%     end
%     if(i<=4)
%        str4 = strcat(str4, ',%f'); 
%     end
end
str1 = strcat(str1, ',%f\n');
% str2 = strcat(str2, '\n');
% str3 = strcat(str3, '\n');
% str4 = strcat(str4, '\n');
FileName = strcat('.\data\myw\SHENZHAN\','原始数据',num2str(ti),'.csv');
[folder, ~, ~] = fileparts(FileName);
if exist(folder, 'dir') == 0
    mkdir(folder);
    disp('文件夹已创建。');
else
    disp('文件夹已存在。');
end
fileID1 = fopen(FileName,'a');
% fileID2 = fopen(strcat('.\data\','角度结果',num2str(ti),'.csv'),'a');
% fileID3 = fopen(strcat('G:\myw\研究生阶段文档\毕业流程规范\约束求解方法\data\绕单个轴旋转约束\仅约束P4结果\','仅约束P4四元数结果',num2str(ti),'.csv'),'a');
% fileID8 = fopen(strcat('.\data\','两个IMU姿态差异结果',num2str(ti),'.csv'),'a');
count=1;
flag=0;
Dis_Count = 0;
ti=tic;
%% 采集数据
% while tc.Connected > 0
while true
    count = count+1;
%     try
%         Input = fscanf(tc,'%f')';
        Input = fscanf(s,'%f')';   
        if length(Input)==IMU_num*9+1
            %% 文件输出
    %         str4 = Input+datestr(now);
            fprintf(fileID1, str1, Input);
    %         fprintf(fileID2, str2, Euler_k);
    %         fprintf(fileID3, str3, X_k);
    %         fprintf(fileID3, str4, F_Z);
    %         fprintf(fileID8, str4, Q_diff);
    %         disp(X_k(5:8)');
    
        else
            flag = flag + 1;
            disp(string(count)+'->'+string(flag)+'->'+string(length(Input)));
            count_pre = count;
            disp(Input');
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

disp('运行结束');
%关闭文件
fclose(fileID1);
fclose('all');
close all
disp('End...');