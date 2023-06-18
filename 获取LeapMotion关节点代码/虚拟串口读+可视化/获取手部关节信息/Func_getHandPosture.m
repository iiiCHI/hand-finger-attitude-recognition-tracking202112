function HandPosture = Func_getHandPosture(HandFigAttitude,FigNum,JointNum)
%% 该函数获取关节姿态
% 函数输入：
% HandFigAttitude 是四元数集合，是4*N的数组
% FigNum 表示的是想要计算的手指的个数，默认拇指食指中指无名指小指，
% JointNum 表示的是计算的手指关节数目，默认掌指关节，近指关节，远指关节
% 函数输出：
% HandPosture，也就是所需的手部姿态。
% 作者：马永伟 日期： 2023年6月7日
HandPosture = [];
for i = 1:FigNum
    for j = 1:JointNum
        HandPosture = [HandPosture,Func_getJointPostureAll(HandFigAttitude,(i-1)*4+(j+1),(i-1)*4+(j))];
    end
end
end


% syms Q1 Q2 Q3 Q4 q1 q2 q3 q4;
% tt = Func_crossProductFu([q1 q2 q3 q4],[Q1 Q2 Q3 Q4]);