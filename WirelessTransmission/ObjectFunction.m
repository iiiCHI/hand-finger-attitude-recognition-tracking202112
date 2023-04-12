function outputArg1 = ObjectFunction(X,x0)
%OBJECTFUNCTION 此处显示有关此函数的摘要
%   此处显示详细说明
% q1 = X(1);
% q2 = X(2);
% q3 = X(3);
% q4 = X(4);
% Q1 = X(5);
% Q2 = X(6);
% Q3 = X(7);
% Q4 = X(8);
% 
% q1x0 = x0(1);
% q2x0 = x0(2);
% q3x0 = x0(3);
% q4x0 = x0(4);
% Q1x0 = x0(5);
% Q2x0 = x0(6);
% Q3x0 = x0(7);
% Q4x0 = x0(8);
% M = Func_crossProductFu(X(1:4),X(5:8)) - Func_crossProductFu(x0(1:4),x0(5:8));
M = [ Q1*q1 + Q2*q2 + Q3*q3 + Q4*q4;
 Q1*q2 - Q2*q1 + Q3*q4 - Q4*q3;
 Q1*q3 - Q3*q1 - Q2*q4 + Q4*q2;
 Q1*q4 + Q2*q3 - Q3*q2 - Q4*q1];
% M2 = [ Q1x0*q1x0 + Q2x0*q2x0 + Q3x0*q3x0 + Q4x0*q4x0;
%          Q1x0*q2x0 - Q2x0*q1x0 + Q3x0*q4x0 - Q4x0*q3x0;
%          Q1x0*q3x0 - Q3x0*q1x0 - Q2x0*q4x0 + Q4x0*q2x0;
%          Q1x0*q4x0 + Q2x0*q3x0 - Q3x0*q2x0 - Q4x0*q1x0];
% outputArg1 = M-M2;
end

