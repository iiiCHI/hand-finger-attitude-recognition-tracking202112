% This file plot attitude by using a reference obj.
% For example, singule vector, tri-axis, or tri-axis+box.
% the rotation is represented by quaternion
% By haipeng.wang@gmail, Nov., 2018.
% 
function iplot_q(q, hx, hy, hz)
%     h is animatedline object, q is rotation quaternion, in row vector.
% 
%     Define following code outside this function
%     h = animatedline;
% 
%     axis([-2 2 -2 2 -2 2]);
    
    % Demo style: 1) tri-axis, or 2) individual vector, or 3) tri-axis + box
    vx = [2;0;0]; vy = [0;2;0]; vz = [0;0;2];

    % rotate the tri-axis
    vx = quatrotate(q, vx')'; vy = quatrotate(q, vy')'; vz = quatrotate(q, vz')';

    % redraw
    clearpoints(hx);
    addpoints(hx, 0, 0, 0);
    addpoints(hx, vx(1), vx(2), vx(3));
    
    clearpoints(hy);
    addpoints(hy, 0, 0, 0);
    addpoints(hy, vy(1), vy(2), vy(3));
    
    clearpoints(hz);
    addpoints(hz, 0, 0, 0);
    addpoints(hz, vz(1), vz(2), vz(3));
    
%     pause(1/100);

    % with 'limitrate nocallbacks' will improve performance dramatically.
    drawnow limitrate nocallbacks
end