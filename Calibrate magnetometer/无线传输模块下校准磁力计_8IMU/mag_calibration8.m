function mag_calibration8(data_rcv)
%     function [x0,y0,z0,xScale,yScale,zScale]=mag_calibration(IMU_num, datafilename)
% x_column = 1+3*(IMU_num-1);y_column = x_column+1;z_column =x_column+2;
IMU_num = 8;
before = data_rcv;
% before = load(datafilename);
% before = csvread(datafilename);
% before = mtx;
NiheA = zeros(6,IMU_num);
for N = 1:IMU_num    
    x_column = N*9-9+7;y_column = x_column+1;z_column =x_column+2;
    
    x = before(:,x_column);
    y = before(:,y_column);
    z = before(:,z_column);
    [max_x,~] = max(x,[],1);
    [min_x,~] = min(x,[],1);
    [max_y,~] = max(y,[],1);
    [min_y,~] = min(y,[],1);
    [max_z,~] = max(z,[],1);
    [min_z,~] = min(z,[],1);
    
    AA = (max_x-min_x)/2;
    BB = (max_y-min_y)/2;
    CC = (max_z-min_z)/2;
    x00 = (max_x+min_x)/2;
    y00 = (max_y+min_y)/2;
    z00 = (max_z+min_z)/2;
    
    
    %�ռ������������㷨
    num_points = length(x);
    %һ����ͳ��ƽ��
    x_avr = sum(x)/num_points;
    y_avr = sum(y)/num_points;
    z_avr = sum(z)/num_points;
    %������ͳ��ƽ��
    xx_avr = sum(x.*x)/num_points;
    yy_avr = sum(y.*y)/num_points;
    zz_avr = sum(z.*z)/num_points;
    xy_avr = sum(x.*y)/num_points;
    xz_avr = sum(x.*z)/num_points;
    yz_avr = sum(y.*z)/num_points;
    %������ͳ��ƽ��
    xxx_avr = sum(x.*x.*x)/num_points;
    xxy_avr = sum(x.*x.*y)/num_points;
    xxz_avr = sum(x.*x.*z)/num_points;
    xyy_avr = sum(x.*y.*y)/num_points;
    xzz_avr = sum(x.*z.*z)/num_points;
    yyy_avr = sum(y.*y.*y)/num_points;
    yyz_avr = sum(y.*y.*z)/num_points;
    yzz_avr = sum(y.*z.*z)/num_points;
    zzz_avr = sum(z.*z.*z)/num_points;
    %�Ĵ���ͳ��ƽ��
    yyyy_avr = sum(y.*y.*y.*y)/num_points;
    zzzz_avr = sum(z.*z.*z.*z)/num_points;
    xxyy_avr = sum(x.*x.*y.*y)/num_points;
    xxzz_avr = sum(x.*x.*z.*z)/num_points;
    yyzz_avr = sum(y.*y.*z.*z)/num_points;
    
    %����������Է��̵�ϵ������
    A0 = [yyyy_avr yyzz_avr xyy_avr yyy_avr yyz_avr yy_avr;
        yyzz_avr zzzz_avr xzz_avr yzz_avr zzz_avr zz_avr;
        xyy_avr  xzz_avr  xx_avr  xy_avr  xz_avr  x_avr;
        yyy_avr  yzz_avr  xy_avr  yy_avr  yz_avr  y_avr;
        yyz_avr  zzz_avr  xz_avr  yz_avr  zz_avr  z_avr;
        yy_avr   zz_avr   x_avr   y_avr   z_avr   1;];
    %����������
    b = [-xxyy_avr;
        -xxzz_avr;
        -xxx_avr;
        -xxy_avr;
        -xxz_avr;
        -xx_avr];
    
    resoult = A0\b;
    %resoult = solution_equations_n_yuan(A0,b);
    
    x0 = -resoult(3)/2;                  %��ϳ���x����
    y0 = -resoult(4)/(2*resoult(1));     %��ϳ���y����
    z0 = -resoult(5)/(2*resoult(2));     %��ϳ���z����
    
    A = sqrt(x0*x0 + resoult(1)*y0*y0 + resoult(2)*z0*z0 - resoult(6));   % ��ϳ���x�����ϵ���뾶
    B = A/sqrt(resoult(1));                                               % ��ϳ���y�����ϵ���뾶
    C = A/sqrt(resoult(2));                                               % ��ϳ���z�����ϵ���뾶
    
    %����������ԭ��
    x = x-x0;
    y = y-y0;
    z = z-z0;
    
    %�������ᰴ��������
    xScale=((A+B+C)/3)/A;
    yScale=((A+B+C)/3)/B;
    zScale=((A+B+C)/3)/C;
    
    x = x*xScale;
    y = y*yScale;
    z = z*zScale;
    
    figure;
    axis on;
    % scatter3(before(:,1),before(:,2),before(:,3),'r');
    plot3(before(:,1),before(:,2),before(:,3),'r');
    hold on;
    plot3(x,y,z,'g');
    % scatter3(x,y,z,'g');
    
%     fprintf('IMU_'+N+'_��Ͻ��\n');
    NiheA(1,N) = x00;
    NiheA(2,N) = y00;
    NiheA(3,N) = z00;
    NiheA(4,N) = xScale;
    NiheA(5,N) = yScale;
    NiheA(6,N) = zScale;
    fprintf('a = %f, b = %f, c = %f, d = %f, e = %f, f = %f\n',resoult);
    fprintf('x0 = %f, ������%f\n',x00,abs((x00-x0)/x0));
    fprintf('y0 = %f, ������%f\n',y00,abs((y00-y0)/y0));
    fprintf('z0 = %f, ������%f\n',z00,abs((z00-z0)/z0));
    fprintf('xScale = %f\n',xScale);
    fprintf('yScale = %f\n',yScale);
    fprintf('zScale = %f\n',zScale);
    fprintf('A = %f,  ������%f\n',AA,abs((A-AA)/A));
    fprintf('B = %f,  ������%f\n',BB,abs((B-BB)/B));
    fprintf('C = %f,  ������%f\n',CC,abs((C-CC)/C));
end
save(strcat('./Xishu_',num2str(IMU_num)),'NiheA');
end