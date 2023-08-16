clc;clear;
HandFigAttitude = readmatrix("..\..\DataSet\HumanId001\HumanId001GestureId3\Times0data.csv");
% HandFigAttitude = readmatrix(".\Times0data.csv");
% for i = 1:20
%     HandFigAttitude(:,i*4-3:i*4) = Func_crossProductFuAll([cos(pi/4),0,-sin(pi/4),0],HandFigAttitude(:,i*4-3:i*4));
% end
% 里面包含了80个数据，为4*4*5 表示 五根手指（拇指、食指、中指、无名指、小指）的四个骨节姿态
HandPosture = Func_getHandPosture(HandFigAttitude,3,2);
RowData = readmatrix("..\读串口\data\1\ok\rowdata1.csv");
load('Xishu.mat');%把系数加载进来，名字为NiheA  一共有IMU_num列，6行，分别对应系数与偏差
[Hand_posture_ans,Unconstrained_Hand_posture_ans] = Func_GetKalManData(RowData,8,NiheA);
rawEul = [];
UncEul = [];
ConEul = [];
for i=1:6
    rawEul = [rawEul,quat2eul(HandPosture(:,i*4-3:i*4),'XYZ')/pi*180];%分别是
    UncEul = [UncEul,quat2eul(Unconstrained_Hand_posture_ans(:,4+i*4-3:4+i*4),'XYZ')/pi*180];%食指掌指关节
    ConEul = [ConEul,quat2eul(Hand_posture_ans(:,4+i*4-3:4+i*4),'XYZ')/pi*180];%食指掌指关节
end

EulValueRaw = [max(rawEul);min(rawEul);mean(rawEul)];
EulValueUnc = [max(UncEul);min(UncEul);mean(UncEul)];
EulValueCon = [max(ConEul);min(ConEul);mean(ConEul)];

QuaRaw = [max(HandPosture);min(HandPosture);mean(HandPosture)];
QuaCon = [max(Hand_posture_ans(:,5:end));min(Hand_posture_ans(:,5:end));mean(Hand_posture_ans(:,5:end))];
QuaUncon = [max(Unconstrained_Hand_posture_ans(:,5:end));min(Unconstrained_Hand_posture_ans(:,5:end));mean(Unconstrained_Hand_posture_ans(:,5:end))];

