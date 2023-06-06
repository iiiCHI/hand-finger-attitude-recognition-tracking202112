%% ��̬Χ������ת��������x����z�� ���в��İ汾��
%% �������
clc
clear
%% ���ƿ��ӻ�ͼ�εĳ�ʼ������
figure;
set (gcf,'Position',[900,200,1400,700], 'color','w')
subplot(1,2,1);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(1) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(1) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(1) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('����ֵ, X-blue, Y-red, Z-green');
subplot(1,2,2);
grid;
axis equal;
axis([-2 2 -2 2 -2 2]);
hx(2) = animatedline('DisplayName', 'X', 'Color', 'b', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hy(2) = animatedline('DisplayName', 'Y', 'Color', 'r', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
hz(2) = animatedline('DisplayName', 'Z', 'Color', 'g', 'LineWidth', 4, 'Marker', 'd', 'MarkerSize', 9);
title('����ֵ, X-blue, Y-red, Z-green');
figure;
set (gcf,'Position',[200,200,700,900], 'color','w')
subplot(4,1,1);
Color = ['k','b','r','g'];
for N = 1:4
    h(N) = animatedline('Color',Color(N),'LineWidth',2);
end
subplot(4,1,2);
Color = ['k','b','r','g'];
for N = 1:4
    h2(N) = animatedline('Color',Color(N),'LineWidth',2);
end
subplot(4,1,3);
Color = ['k','b','r','g'];
for N = 1:4
    h3(N) = animatedline('Color',Color(N),'LineWidth',2);
end
% figure;
subplot(4,1,4);
Color = ['k','b','r','g'];
for N = 1:4
    h4(N) = animatedline('Color',Color(N),'LineWidth',2);
end
theata = [];
Beta = [];
%% ����ʼ
Qter = [1,0,0,0];           %��ʾ��ǰ״̬����Ԫ��
StageValue = [1,0,0,0];     %���ڱ����м�״̬����̬
%��ת�ĵ�λ�Ƕ���Ϣ
Theta = pi/(4*100);
P = [cos(Theta),sin(Theta),0,0]; %��x��ת
PF = [cos(Theta),-sin(Theta),0,0];
Q = [cos(Theta),0,0,sin(Theta)];%��z��ת
QF = [cos(Theta),0,0,-sin(Theta)];
VertOrder = [P;Q;P;Q;PF]; %��ת˳��

for i = 1:1000
    
    VertQuter = VertOrder(fix(i/70)+1,:);
    
    Qter = Func_crossProduct(VertQuter,Qter); 
%% ���зֽ� �ֽ�Ϊ�����ת����
%     X_Y = [sqrt(Qter(1)^2+Qter(4)^2),0,sqrt(Qter(2)^2+Qter(3)^2),0];
%     X_Z = [sqrt(Qter(1)^2+Qter(3)^2),0,0,sqrt(Qter(2)^2+Qter(4)^2)];
    
    
%     Qter_Caculate = Func_crossProduct(X_Y,X_Z).*sign(Qter);
    
%     vy = quatrotate(Qter', [0,1,0])';%�����X��������ת����
%     if abs(vx(2))<0.001 && abs(vx(1))<0.001 %����0�����
%         Z1 = asin(vx(2)/sqrt(vx(1)^2+vx(2)^2));%������Z��ת�ĽǶȵ�sinֵ
%         Y1 = 2*pi + asin(vx(3)/sqrt(vx(1)^2+vx(2)^2+vx(3)^2));%������Y��ת�ĽǶȵ�sinֵ
% 
%         if vx(1) < 0
%             Z1 = pi - Z1;
%         else
%             Z1 = 2*pi + Z1;
%         end
%     else
%         
% %         Z1 = asin(vx(2)/sqrt(vx(1)^2+vx(2)^2));                 %������Z��ת�ĽǶȵ�sinֵ
% %         Y1 = 2*pi + asin(vx(3)/sqrt(vx(1)^2+vx(2)^2+vx(3)^2));  %������Y��ת�ĽǶȵ�sinֵ
% 
%         X1 = asin(vy(3)/sqrt(vy(2)^2+vy(3)^2));                   %������y�������ת
%         Z1 = 2*pi + asin(vy(1)/sqrt(vy(1)^2+vy(2)^2+vy(3)^2));
%         
%         if vy(2) < 0
%             X1 = pi - X1;
%         else
%             X1 = 2*pi + X1;
%         end
%     end

%     theata(end+1) = Z1;
%     Beta(end+1) = Y1;
%     X_Y = [sqrt(vx(1)^2+vx(2)^2)/sqrt(vx(1)^2+vx(2)^2+vx(3)^2),0,abs(vx(3))/sqrt(vx(1)^2+vx(2)^2+vx(3)^2),0];
%     X_Y = [cos(X1/2),-sin(X1/2),0,0];
% %     X_Z = [1,0,0,0]; 
% %     if sqrt(vx(1)^2+vx(2)^2) >= 0.1
% %         X_Z = [abs(vx(1))/sqrt(vx(1)^2+vx(2)^2),0,0,abs(vx(2))/sqrt(vx(1)^2+vx(2)^2)];
%     X_Z = -[cos(Z1/2),0,0,sin(Z1/2)];
% %     end
%     Qter_Caculate = Func_crossProduct(X_Y,X_Z);
%     
%     if dot(Qter_Caculate,Qter) <0  
%        Qter_Caculate = -Qter_Caculate;
%     end
    
    
%% ���ӻ�
    for N = 1:4
        addpoints(h(N),i,Qter(N));%'r','g','b','k'��������
%         addpoints(h2(N),i,X_Y(N));%'r','g','b','k'��������
%         addpoints(h3(N),i,X_Z(N));%'r','g','b','k'��������
%         addpoints(h4(N),i,Qter_Caculate(N));%'r','g','b','k'��������
    end
%         subplot(2,1,1);   
%     drawnow limitrate nocallbacks
    for N = 1:4
        subplot(4,1,N);
        axis([i-300,i,-1,1])
    end
    iplot_q(Qter', hx(1),hy(1),hz(1));
%     iplot_q(Qter_Caculate', hx(2),hy(2),hz(2));
end

