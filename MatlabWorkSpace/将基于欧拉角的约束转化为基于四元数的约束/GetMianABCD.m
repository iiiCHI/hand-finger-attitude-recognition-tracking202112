function [A,B,C,D] = GetMianABCD(x1,y1,z1,x2,y2,z2,x3,y3,z3)
%GETMIANABCD 已知三点获得平面参数
%   此处显示详细说明
A = y1*(z2-z3)+y2*(z3-z1)+y3*(z1-z2);
B = z1*(x2-x3)+z2*(x3-x1)+z3*(x1-x2);
C = x1*(y2-y3)+x2*(y3-y1)+x3*(y1-y2);
D = -(x1*(y2*z3-y3*z2)+ x2*(y3*z1-y1*z3) + x3*(y1*z2 -y2*z1) );
end

