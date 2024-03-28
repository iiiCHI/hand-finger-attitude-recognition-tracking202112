function [X,P] = CaculatConsenstXandP(X,P,ConstraintEquationD,ConstraintEquationd,ConstraintNotEquationD,ConstraintNotEquationd)
%% 用于求解约束下的X_K，主要用的方法是有效集法（Active Set Method） ， 将不等式约束转化为等式约束进行计算
%输入参数：
%       X:  系统状态计算值
%       P:  系统状态误差协方差矩阵
%       ConstraintEquationD：等式约束的系数矩阵
%       ConstraintEquationd：等式约束的常数矩阵
%       ConstraintNotEquationD：不等式约束的系数矩阵
%       ConstraintNotEquationd：不等式约束的常数矩阵
%输出结果：
%       X：  约束求解后的误差协方差矩阵
%       P:   约束求解后系统状态误差协方差矩阵
%   作者：马永伟
        
%         W = diag([1,1,1,1]);
    W = P;
    X = X - W*ConstraintEquationD'*inv(ConstraintEquationD* W * ConstraintEquationD')*(ConstraintEquationD*X - ConstraintEquationd);
    IKd = diag([1,1,1,1]) - W*ConstraintEquationD'*inv(ConstraintEquationD* W * ConstraintEquationD')*ConstraintEquationD;
    P = IKd * P * IKd';
%%  进行不等式约束
    

end

