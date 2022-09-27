
%% 用于计算一个四元数的旋转矩阵
function [M]=Func_getQuarRotateMatrix(Q)

    q0 = Q(1);
    q1 = Q(2);
    q2 = Q(3);
    q3 = Q(4);

    M = [q0^2+q1^2-q2^2-q3^2, 2*(q1*q2-q0*q3),    2*(q1*q3+q0*q2);
         2*(q1*q2+q0*q3),    q0^2-q1^2+q2^2-q3^2, 2*(q2*q3-q0*q1);
         2*(q1*q3-q0*q2),    2*(q2*q3+q0*q1),    q0^2-q1^2-q2^2+q3^2];
    
end