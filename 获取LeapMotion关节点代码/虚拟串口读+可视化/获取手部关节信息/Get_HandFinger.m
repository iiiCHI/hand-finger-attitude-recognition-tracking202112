clc;clear;
HandFigAttitude = readmatrix("..\..\DataSet\HumanId1\HumanId1GestureId1\弯曲.csv");
% for i = 1:20
%     HandFigAttitude(:,i*4-3:i*4) = Func_crossProductFuAll([cos(pi/4),0,-sin(pi/4),0],HandFigAttitude(:,i*4-3:i*4));
% end
% 里面包含了80个数据，为4*4*5 表示 五根手指（拇指、食指、中指、无名指、小指）的四个骨节姿态
HandPosture = Func_getHandPosture(HandFigAttitude,3,2);
RowData = readmatrix("G:\myw\code\GitCodeOf-hand-finger-attitude-recognition-tracking202112\hand-finger-attitude-recognition-tracking202112\获取LeapMotion关节点代码\虚拟串口读+可视化\读串口\data\myw\WANQU\原始数据28476557252.csv");
load('Xishu.mat');%把系数加载进来，名字为NiheA  一共有IMU_num列，6行，分别对应系数与偏差
[Hand_posture_ans,Unconstrained_Hand_posture_ans] = Func_GetKalManData(RowData,8,NiheA);
Eul = [];
UncEul = [];
ConEul = [];
for i=1:6
    Eul = [Eul,quat2eul(HandPosture(:,i*4-3:i*4),'XYZ')/pi*180];%食指掌指关节
    UncEul = [UncEul,quat2eul(Unconstrained_Hand_posture_ans(:,4+i*4-3:4+i*4),'XYZ')/pi*180];%食指掌指关节
    ConEul = [ConEul,quat2eul(Hand_posture_ans(:,4+i*4-3:4+i*4),'XYZ')/pi*180];%食指掌指关节
end

EulValue = [max(Eul);min(Eul)];
UncEulValue = [max(UncEul);min(UncEul)];
ConEulValue = [max(ConEul);min(ConEul)];

