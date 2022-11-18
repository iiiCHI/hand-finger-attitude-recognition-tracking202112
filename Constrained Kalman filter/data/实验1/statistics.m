clc;clear;
Tilt = [0,30,60];
Bend = [0,30,60];
meanAngle = [];
h_var = [];
p_var = [];
h_mean = [];
p_mean = [];
Error_angle=[];
CountError = [];%����ͳ����������µ����
Rmse=[];
for i = 0:8
    Index_Tilt = floor(i/3)+1;
    Index_Bend = mod(i,3)+1;
    constraintReadFileName = ".\"+num2str(Tilt(Index_Tilt))+"\constraint_"+num2str(Bend(Index_Bend))+".xls";
    unconstraintReadFileName = ".\"+num2str(Tilt(Index_Tilt))+"\unconstraint_"+num2str(Bend(Index_Bend))+".xls";
    WriteFile = ".\����¼\";
    constraintData_row = xlsread(constraintReadFileName);    
    unconstraintData_row = xlsread(unconstraintReadFileName);   
    Error_angle = abs([constraintData_row(:,4*4-3:4*4) - [cos(Bend(Index_Bend)/360*pi),sin(Bend(Index_Bend)/360*pi),0,0],unconstraintData_row(:,4*4-3:4*4) - [cos(Bend(Index_Bend)/360*pi),sin(Bend(Index_Bend)/360*pi),0,0]]);
%     Error_angle = [Error_angle;abs([constraintData_row(:,4*4-3:4*4) - [cos(Bend(Index_Bend)/360*pi),sin(Bend(Index_Bend)/360*pi),0,0],unconstraintData_row(:,4*4-3:4*4) - [cos(Bend(Index_Bend)/360*pi),sin(Bend(Index_Bend)/360*pi),0,0]])];
%     Error_angle2 = [constraintData_row(:,4*4-3:4*4),unconstraintData_row(:,4*4-3:4*4)];
    meanAngle(end+1,:) = mean(Error_angle);
    CountError = [CountError;Error_angle];
    All_number = length(Error_angle);
    Rmse(end+1,:) = sqrt(sum(Error_angle.*Error_angle)/All_number);
    fclose("all");
end
%% ��������ͼ
figure;
set (gcf,'Position',[500,150,2000,1150], 'color','w')
for i = 1:4
subplot(2,2,i);
boxplot(meanAngle(:,[i,4+i]),'Labels',{'�ں�Լ��������̬���','δ�ں�Լ��������̬���'});
% xlabel(['3','4'])
title(['��̬��Ԫ��q',num2str(i)])
end
% suptitle('�������ܱ��⡯');
