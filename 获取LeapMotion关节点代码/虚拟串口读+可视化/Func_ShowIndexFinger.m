function Func_ShowIndexFinger(buffer,hx,hy,hz)
%% 函数是对于单指进行姿态输出的，
% 输入变量：
%       buffer：单指三骨节的姿态
%       hx，hy，hz：绘制骨节的句柄
% 输出变量：
% 
% 作者：马永伟
%% 执行开始 预设 %LeftOrRight为0则表示左手
    q_hand = buffer(1:1*4);
    q_i1 = buffer(1*4+1:2*4);
    q_i2 = buffer(2*4+1:3*4);
    % Demo style: 1) tri-axis, or 2) individual vector, or 3) tri-axis + box
    Hand_i = -[0;0.6;0];
    Index_Finger_1 = -[0;0.6;0];
    Index_Finger_2 = -[0;0.6;0];
    %% 姿态变化
%     Thumb_Finger_1 = [0.5;0;0];
    % rotate the tri-axis
    % 食指
    Hand_i = quatrotate(q_hand, Hand_i')';
    Index_Finger_1 = quatrotate(q_i1, Index_Finger_1')' + Hand_i;
    Index_Finger_2 = quatrotate(q_i2, Index_Finger_2')' + Index_Finger_1;
    
    %% 输出展示
    % redraw 食指
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

