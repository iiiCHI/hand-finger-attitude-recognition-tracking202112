function [c,ceq] = Func_getHandJointConstraints(X)
%Func_getHandJointConstraints 表示对X约束求解的函数
%   拇指外关节约束为[0,75]
%   食指外关节约束为[0,110]
%   中指外关节约束为[0,110]
%   拇指自外向内关节编号为1，2，3
%   食指自外向内关节编号为4，5，6
%   中指自外向内关节编号为8，7，6
%   当前约束仅针对12关节，45关节，87关节进行弯曲角度的约束
% c  保存的是不等式; 即 < 0 的部分
% ceq = 保存的是等式约束;
%
% ceq=[q1^2+q2^2+q3^2+q4^2 - 1;
%    Q1^2+Q2^2+Q3^2+Q4^2 - 1 ];
ceq = [ Get_q3(X,2,1);
        Get_q3(X,5,4);
        Get_q3(X,7,8);
        % 上是外关节Q3
        Get_q4(X,2,1);
        Get_q4(X,5,4);
        Get_q4(X,7,8);        
        % 上是外关节Q4
        Get_q3(X,6,5);
        Get_q3(X,6,7); 
        % 上是食指中指内关节Q3
        ];
        %% 取符号
signal = [sign(Get_q1(X,2,1));sign(Get_q1(X,5,4));sign(Get_q1(X,7,8));sign(Get_q1(X,6,5));sign(Get_q1(X,6,7))];
c = [  - Get_q2(X,2,1) * signal(1);
       Get_q2(X,2,1) * signal(1) - sin(deg2rad(75/2)) ;
       %拇指外关节
       - Get_q2(X,5,4) * signal(2);
       Get_q2(X,5,4) * signal(2) - sin(deg2rad(110/2)) ;
       %食指外关节
       - Get_q2(X,7,8) * signal(3);
       Get_q2(X,7,8) * signal(3) - sin(deg2rad(110/2));       
       %中指外关节 
       - Get_q2(X,6,5) * signal(4) + sin(deg2rad(-30/2));
       Get_q2(X,6,5) * signal(4) - sin(deg2rad(90/2));          
       %食指内关节 弯曲
       - Get_q2(X,6,7) * signal(5) + sin(deg2rad(-30/2));
       Get_q2(X,6,7) * signal(5) - sin(deg2rad(90/2));          
       %中指内关节 弯曲
       - Get_q4(X,6,5) * signal(4);
       Get_q4(X,6,5) * signal(4) - sin(deg2rad(60/2));        
       %食指内关节 外展\内收    
       - Get_q4(X,6,7) * signal(5);
       Get_q4(X,6,7) * signal(5) - sin(deg2rad(60/2));     
       %中指内关节 外展\内收
       
       ];

end

function [answer] = Get_q1(X,a,b)
q1 = X(a * 4 - 3);
q2 = X(a * 4 - 2);
q3 = X(a * 4 - 1);
q4 = X(a * 4);
Q1 = X(b * 4 - 3);
Q2 = X(b * 4 - 2);
Q3 = X(b * 4 - 1);
Q4 = X(b * 4);
answer = Q1*q1 + Q2*q2 + Q3*q3 + Q4*q4;
% Q1*q2 - Q2*q1 + Q3*q4 - Q4*q3
end

function [answer] = Get_q2(X,a,b)
q1 = X(a * 4 - 3);
q2 = X(a * 4 - 2);
q3 = X(a * 4 - 1);
q4 = X(a * 4);
Q1 = X(b * 4 - 3);
Q2 = X(b * 4 - 2);
Q3 = X(b * 4 - 1);
Q4 = X(b * 4);
answer = Q1*q2 - Q2*q1 + Q3*q4 - Q4*q3;
% Q1*q2 - Q2*q1 + Q3*q4 - Q4*q3
end

function [answer] = Get_q3(X,a,b)
q1 = X(a * 4 - 3);
q2 = X(a * 4 - 2);
q3 = X(a * 4 - 1);
q4 = X(a * 4);
Q1 = X(b * 4 - 3);
Q2 = X(b * 4 - 2);
Q3 = X(b * 4 - 1);
Q4 = X(b * 4);
answer = Q1*q3 - Q3*q1 - Q2*q4 + Q4*q2;
% Q1*q2 - Q2*q1 + Q3*q4 - Q4*q3
end

function [answer] = Get_q4(X,a,b)
q1 = X(a * 4 - 3);
q2 = X(a * 4 - 2);
q3 = X(a * 4 - 1);
q4 = X(a * 4);
Q1 = X(b * 4 - 3);
Q2 = X(b * 4 - 2);
Q3 = X(b * 4 - 1);
Q4 = X(b * 4);
answer = Q1*q4 + Q2*q3 - Q3*q2 - Q4*q1;
end



