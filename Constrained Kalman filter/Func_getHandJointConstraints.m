function [c,ceq] = Func_getHandJointConstraints(X)
%Func_getHandJointConstraints ��ʾ��XԼ�����ĺ���
%   Ĵָ��ؽ�Լ��Ϊ[0,75]
%   ʳָ��ؽ�Լ��Ϊ[0,110]
%   ��ָ��ؽ�Լ��Ϊ[0,110]
%   Ĵָ�������ڹؽڱ��Ϊ1��2��3
%   ʳָ�������ڹؽڱ��Ϊ4��5��6
%   ��ָ�������ڹؽڱ��Ϊ8��7��6
%   ��ǰԼ�������12�ؽڣ�45�ؽڣ�87�ؽڽ��������Ƕȵ�Լ��
% c  ������ǲ���ʽ; �� < 0 �Ĳ���
% ceq = ������ǵ�ʽԼ��;
%
% ceq=[q1^2+q2^2+q3^2+q4^2 - 1;
%    Q1^2+Q2^2+Q3^2+Q4^2 - 1 ];
ceq = [ Get_q3(X,2,1);
        Get_q3(X,5,4);
        Get_q3(X,7,8);
        % ������ָ��ؽ�Q3
        Get_q4(X,2,1);
        Get_q4(X,5,4);
        Get_q4(X,7,8);        
        % ������ָ��ؽ�Q4        
%         Get_q3(X,6,5);
%         Get_q3(X,6,7); 
%         Get_q3(X,3,2); 
        %�����Ǹ����ؽ���ת��
        ];
        %% ȡ����
signal = [sign(Get_q1(X,2,1));sign(Get_q1(X,5,4));sign(Get_q1(X,7,8));sign(Get_q1(X,6,5));sign(Get_q1(X,6,7));sign(Get_q1(X,3,2))];
c = [         
       - Get_q2(X,3,2) * signal(6);
       Get_q2(X,3,2) * signal(6) - sin(deg2rad(75/2)) ;
        %Ĵָ�ڹؽ�
       - Get_q2(X,2,1) * signal(1) + sin(deg2rad(-5/2));
       Get_q2(X,2,1) * signal(1) - sin(deg2rad(75/2)) ;
       %Ĵָ��ؽ�
       - Get_q2(X,5,4) * signal(2);
       Get_q2(X,5,4) * signal(2) - sin(deg2rad(110/2)) ;
       %ʳָ��ؽ�
       - Get_q2(X,7,8) * signal(3);
       Get_q2(X,7,8) * signal(3) - sin(deg2rad(110/2));       
       %��ָ��ؽ� 
       - Get_q2(X,6,5) * signal(4) + sin(deg2rad(-30/2));
       Get_q2(X,6,5) * signal(4) - sin(deg2rad(90/2));          
       %ʳָ�ڹؽ� ����
       - Get_q2(X,6,7) * signal(5) + sin(deg2rad(-30/2));
       Get_q2(X,6,7) * signal(5) - sin(deg2rad(90/2));          
       %��ָ�ڹؽ� ����
%        - Get_q4(X,6,5) * signal(4);
%        Get_q4(X,6,5) * signal(4) - sin(deg2rad(60/2));        
%        - Get_q4(X,6,5) * signal(4) + sin(deg2rad(-30/2));
%        Get_q4(X,6,5) * signal(4) - sin(deg2rad(30/2));   
       abs(Get_q4(X,6,5)) - sin(deg2rad(30/2));  %����30��
       %ʳָ�ڹؽ� ��չ\����    
%        - Get_q4(X,6,7) * signal(5);
%        Get_q4(X,6,7) * signal(5) - sin(deg2rad(60/2));     
%        - Get_q4(X,6,7) * signal(5) +  sin(deg2rad(-30/2));
%        Get_q4(X,6,7) * signal(5) - sin(deg2rad(30/2));  
       abs(Get_q4(X,6,7)) - sin(deg2rad(30/2));  
       %��ָ�ڹؽ� ��չ\����Q4       
       abs(Get_q4(X,3,2)) - sin(deg2rad(45/2)) ;
       %Ĵָ��չ����
        abs(Get_q3(X,6,5)) - 0.0499502112523148;%һ����С��30���
        abs(Get_q3(X,6,7)) - 0.0499502112523148; 
        abs(Get_q3(X,3,2)) - 0.0315065771780789; 
        % ����ʳָ��ָĴָ�ڹؽ�Q3
       %��ָmcp��Լ������ָ�ڹؽڵ�q3Լ��
%       90-30��0.183
%       75-22.5�� 0.119       
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



