function [X,P] = CaculatConsenstXandP(X,P,ConstraintEquationD,ConstraintEquationd,ConstraintNotEquationD,ConstraintNotEquationd)
%% �������Լ���µ�X_K����Ҫ�õķ�������Ч������Active Set Method�� �� ������ʽԼ��ת��Ϊ��ʽԼ�����м���
%���������
%       X:  ϵͳ״̬����ֵ
%       P:  ϵͳ״̬���Э�������
%       ConstraintEquationD����ʽԼ����ϵ������
%       ConstraintEquationd����ʽԼ���ĳ�������
%       ConstraintNotEquationD������ʽԼ����ϵ������
%       ConstraintNotEquationd������ʽԼ���ĳ�������
%��������
%       X��  Լ����������Э�������
%       P:   Լ������ϵͳ״̬���Э�������
%   ���ߣ�����ΰ
        
%         W = diag([1,1,1,1]);
    W = P;
    X = X - W*ConstraintEquationD'*inv(ConstraintEquationD* W * ConstraintEquationD')*(ConstraintEquationD*X - ConstraintEquationd);
    IKd = diag([1,1,1,1]) - W*ConstraintEquationD'*inv(ConstraintEquationD* W * ConstraintEquationD')*ConstraintEquationD;
    P = IKd * P * IKd';
%%  ���в���ʽԼ��
    

end

