% This file plot attitude with reference obj.
% For example, singule vector, tri-axis, or tri-axis+box.
% By haipeng.wang@gmail, Nov., 2018.
% 
function iplot(r, h)
%     h is animatedline object, r is rotation DCM.
% 
%     Define following code outside this function
%     h = animatedline;
% 
%     axis([-2 2 -2 2 -2 2]);
    
    % Demo style: 1) tri-axis, or 2) individual vector, or 3) tri-axis + box
    vx = [2;0;0]; vy = [0;2;0]; vz = [0;0;2];

    % rotate the tri-axis
    vx = r*vx; vy = r*vy; vz = r*vz;

    % redraw
    clearpoints(h);
    addpoints(h, 0, 0, 0);
    addpoints(h, vx(1), vx(2), vx(3));
    
    addpoints(h, 0, 0, 0);
    addpoints(h, vy(1), vy(2), vy(3));
    
    addpoints(h, 0, 0, 0);
    addpoints(h, vz(1), vz(2), vz(3));

    % with 'limitrate nocallbacks' will improve performance dramatically.
    drawnow limitrate nocallbacks