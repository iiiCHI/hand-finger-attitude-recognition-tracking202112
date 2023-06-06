function Func_ShowIndexFinger(buffer,hx,hy,hz)
%% �����Ƕ��ڵ�ָ������̬����ģ�
% ���������
%       buffer����ָ���ǽڵ���̬
%       hx��hy��hz�����ƹǽڵľ��
% ���������
% 
% ���ߣ�����ΰ
%% ִ�п�ʼ Ԥ�� %LeftOrRightΪ0���ʾ����
    q_hand = buffer(1:1*4);
    q_i1 = buffer(1*4+1:2*4);
    q_i2 = buffer(2*4+1:3*4);
    % Demo style: 1) tri-axis, or 2) individual vector, or 3) tri-axis + box
    Hand_i = -[0;0.6;0];
    Index_Finger_1 = -[0;0.6;0];
    Index_Finger_2 = -[0;0.6;0];
    %% ��̬�仯
%     Thumb_Finger_1 = [0.5;0;0];
    % rotate the tri-axis
    % ʳָ
    Hand_i = quatrotate(q_hand, Hand_i')';
    Index_Finger_1 = quatrotate(q_i1, Index_Finger_1')' + Hand_i;
    Index_Finger_2 = quatrotate(q_i2, Index_Finger_2')' + Index_Finger_1;
    
    %% ���չʾ
    % redraw ʳָ
    clearpoints(hx);
    addpoints(hx, 0, 0, 0);
    addpoints(hx, Hand_i(1), Hand_i(2), Hand_i(3));
    clearpoints(hy);
    addpoints(hy, Hand_i(1), Hand_i(2), Hand_i(3));
    addpoints(hy, Index_Finger_1(1), Index_Finger_1(2), Index_Finger_1(3));
    clearpoints(hz);
    addpoints(hz, Index_Finger_1(1), Index_Finger_1(2), Index_Finger_1(3));
    addpoints(hz, Index_Finger_2(1), Index_Finger_2(2), Index_Finger_2(3));
    % with 'limitrate nocallbacks' will improve performance dramatically.
    drawnow limitrate nocallbacks
end

