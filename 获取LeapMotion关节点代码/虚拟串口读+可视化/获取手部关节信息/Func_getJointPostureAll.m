function Joint = Func_getJointPostureAll(X_k,L2,L1)
%% 该函数获取关节姿态
% 函数输入：
% X_k 是四元数集合，是4*N的数组
% L2是后一个的骨节位置，
% L1是前一个骨节的位置
% 函数输出：
% Joint就是将L1旋转到L2的旋转过程，也就是L1和L2之间的骨节姿态。
% 作者：马永伟 日期： 2023年6月17日
    Joint = Func_crossProductFuAll(X_k(:,L2*4-3:L2*4),X_k(:,L1*4-3:L1*4));
end


% syms Q1 Q2 Q3 Q4 q1 q2 q3 q4;
% tt = Func_crossProductFu([q1 q2 q3 q4],[Q1 Q2 Q3 Q4]);