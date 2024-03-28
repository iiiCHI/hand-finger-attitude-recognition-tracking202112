function Func_ShowHand(buffer,hx,hy,hz,h2,hm1,hm2,ht0,ht1,ht2,LeftOrRight)
%% 执行开始 预设 %LeftOrRight为0则表示左手
    q_hand = buffer(6*4-3:6*4);
    q_i1 = buffer(4*4+1:5*4);
    q_i2 = buffer(3*4+1:4*4);
    q_m1 = buffer(6*4+1:7*4);
    q_m2 = buffer(7*4+1:8*4);
    q_t0 = buffer(2*4+1:3*4);
    q_t1 = buffer(1*4+1:2*4);
    q_t2 = buffer(1:4);
    % Demo style: 1) tri-axis, or 2) individual vector, or 3) tri-axis + box
    if LeftOrRight == 0
        Hand_m = -[-0.2;0.5;0]; 
        Hand_i = -[0.2;0.5;0]; 
        Thumb_m = -[0.4;-0.1;-0.4];
    else
        Hand_m = -[0.2;0.5;0]; 
        Hand_i = -[-0.2;0.5;0]; 
        Thumb_m = [0.4;-0.1;-0.4];
    end
    Index_Finger_1 = -[0;0.5;0];
    Index_Finger_2 = -[0;0.5;0];
    Middle__Finger_1 = -[0;0.5;0];
    Middle__Finger_2 = -[0;0.5;0];
    Thumb_1 = -[0;0.5;0];
    Thumb_2 = -[0;0.3;0];
    Thumb_3 = -[0;0.3;0];
    %% 姿态变化
%     Thumb_Finger_1 = [0.5;0;0];
    % rotate the tri-axis
    % 食指
    Hand_i = quatrotate(q_hand, Hand_i')';
    Index_Finger_1 = quatrotate(q_i1, Index_Finger_1')' + Hand_i;
    Index_Finger_2 = quatrotate(q_i2, Index_Finger_2')' + Index_Finger_1;
    %中指
    Hand_m = quatrotate(q_hand, Hand_m')';
    Middle__Finger_1 = quatrotate(q_m1, Middle__Finger_1')' + Hand_m;
    Middle__Finger_2 = quatrotate(q_m2, Middle__Finger_2')' + Middle__Finger_1;
    %% 拇指
    Thumb_m = quatrotate(q_hand, Thumb_m')';
    Thumb_1 = quatrotate(q_t0, Thumb_1')' + Thumb_m;
    Thumb_2 = quatrotate(q_t1, Thumb_2')' + Thumb_1;
    Thumb_3 = quatrotate(q_t2, Thumb_3')' + Thumb_2;
    
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
    %中指
    clearpoints(h2);
    addpoints(h2, 0, 0, 0);
    addpoints(h2, Hand_m(1), Hand_m(2), Hand_m(3));
    clearpoints(hm1);
    addpoints(hm1, Hand_m(1), Hand_m(2), Hand_m(3));
    addpoints(hm1, Middle__Finger_1(1), Middle__Finger_1(2), Middle__Finger_1(3));
    clearpoints(hm2);
    addpoints(hm2, Middle__Finger_1(1), Middle__Finger_1(2), Middle__Finger_1(3));
    addpoints(hm2, Middle__Finger_2(1), Middle__Finger_2(2), Middle__Finger_2(3));
    %拇指
    clearpoints(ht0);
    addpoints(ht0, Thumb_m(1), Thumb_m(2), Thumb_m(3));
    addpoints(ht0, Thumb_1(1), Thumb_1(2), Thumb_1(3));
    clearpoints(ht1);
    addpoints(ht1, Thumb_1(1), Thumb_1(2), Thumb_1(3));
    addpoints(ht1, Thumb_2(1), Thumb_2(2), Thumb_2(3));
    clearpoints(ht2);
    addpoints(ht2, Thumb_2(1), Thumb_2(2), Thumb_2(3));
    addpoints(ht2, Thumb_3(1), Thumb_3(2), Thumb_3(3));
%     pause(1/1000);

    % with 'limitrate nocallbacks' will improve performance dramatically.
    drawnow limitrate nocallbacks
end

