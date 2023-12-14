function HandPosture = Func_getHandPosture(HandFigAttitude,FigNum,JointNum)
%% 该函数获取关节姿态
% % 值得注意的是，拇指没有掌骨，所以是非法值。需要单独计算。
% % 其中，在Visual Studio 2017中，Leap Motion SDK的四元数（Quaternion）通常由四个浮点数组成，表示为 (x, y, z, w)。
% 这四个值分别代表了四元数的四个分量，具体含义如下：
% x：四元数的x分量。
% y：四元数的y分量。
% z：四元数的z分量。
% w：四元数的w分量。而w分量表示旋转的角度。

% 函数输入：
% HandFigAttitude 是四元数集合，是4*N的数组,但是要注意的是，实数在最后面。
% FigNum 表示的是想要计算的手指的个数，默认拇指食指中指无名指小指，
% JointNum 表示的是计算的手指关节数目，默认掌指关节，近指关节，远指关节

% 函数输出：
% HandPosture，也就是所需的手部姿态。
% 作者：马永伟 日期： 2023年6月7日
% Metrx  = [0.5,-0.5,0.5,0.5];


% 请确保 n 能够被 4 整除，以便进行操作
[nRows, nCols] = size(HandFigAttitude);
newMatrix = zeros(nRows, nCols); % 创建一个新的矩阵来存储结果
for i = 1:4:nCols
    if i+3 <= nCols
        % 提取当前四列的数据
        subMatrix = HandFigAttitude(:, i:i+3);
        
        % 改变顺序
        newSubMatrix = [subMatrix(:, 4), subMatrix(:, 1), subMatrix(:, 2), subMatrix(:, 3)];
        
        % 将新的子矩阵放入新矩阵中
        newMatrix(:, i:i+3) = newSubMatrix;
    else
        % 如果最后一组不足四列，直接复制到新矩阵中
        newMatrix(:, i:nCols) = HandFigAttitude(:, i:nCols);
    end
end
% 现在newMatrix包含了顺序改变后的矩阵
HandFigAttitude = newMatrix;

HandPosture = [];
for i = 1:FigNum
    for j = 1:JointNum
        jit = Func_getJointPostureAll(HandFigAttitude,(i-1)*4+(j+1),(i-1)*4+(j));
        for k = 1:length(jit)
            if jit(k,1)<0
                jit(k,:) = jit(k,:)*-1;
            end
            %jit(k,:) = Func_crossProduct(Metrx,jit(k,:)); 
        end
        HandPosture = [HandPosture,jit];
    end
end

%%重新计算拇指远端关节的姿态。
i=1;
j=3;
jit = Func_getJointPostureAll(HandFigAttitude,(i-1)*4+(j+1),(i-1)*4+(j));
for k = 1:length(jit)
    if jit(k,1)<0
        jit(k,:) = jit(k,:)*-1;
    end
    %jit(k,:) = Func_crossProduct(Metrx,jit(k,:)); 
end
HandPosture(:,1:4) = HandPosture(:,5:8);
HandPosture(:,5:8) = jit;

end
% syms Q1 Q2 Q3 Q4 q1 q2 q3 q4;
% tt = Func_crossProductFu([q1 q2 q3 q4],[Q1 Q2 Q3 Q4]);