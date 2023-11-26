%% 用于加载9位同学特征，然后进行数据预处理等，画图展示的。

clc;clear;

load('9位同学的特征.mat');
% 是难度x轮数x人数x6x特征个数
%FistFea = reshape(Features_Tar(1,:,:,:,:),[30*9,6*14]);
% //用来提取某一个难度的特征的
% 怎么分的呢，先按照轮数，1-30轮，往后是人数，
% 后面是，先按照IMU的6个参数，再按照特征去划分。
%1均值,2均方根,3-5四分位点【1，2，3】，6标准差，7峰值，
% 8峰峰值，4-6hz强度，6-12hz强度、11:颤抖的主频率（Dominant Frequency of Tremor，FT）
%12:篇度，13峰度，14，自回归系数
%按照六轴来的，6*n个

%%临时保存所有的特征，然后求九个人的均值。或者是求3*9=27个，都可以
FistFea_Tar = reshape(Features_Tar(1,:,:,:,:),[30*9,6*14]);
SecFea_Tar = reshape(Features_Tar(2,:,:,:,:),[30*9,6*14]);
ThrFea_Tar = reshape(Features_Tar(3,:,:,:,:),[30*9,6*14]);

FistFea_Rst = reshape(Features_Rst(1,:,:,:,:),[30*9,6*14]);
SecFea_Rst = reshape(Features_Rst(2,:,:,:,:),[30*9,6*14]);
ThrFea_Rst = reshape(Features_Rst(3,:,:,:,:),[30*9,6*14]);

FistFea_Act = reshape(Features_Act(1,:,:,:,:),[30*9,6*14]);
SecFea_Act = reshape(Features_Act(2,:,:,:,:),[30*9,6*14]);
ThrFea_Act = reshape(Features_Act(3,:,:,:,:),[30*9,6*14]);

% 找到所有元素均为0的行
rowsToDelete = all(FistFea_Tar == 0, 2);
% 删除所有元素均为0的行
FistFea_Tar(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(SecFea_Tar == 0, 2);
% 删除所有元素均为0的行
SecFea_Tar(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(ThrFea_Tar == 0, 2);
% 删除所有元素均为0的行
ThrFea_Tar(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(FistFea_Rst == 0, 2);
% 删除所有元素均为0的行
FistFea_Rst(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(SecFea_Rst == 0, 2);
% 删除所有元素均为0的行
SecFea_Rst(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(ThrFea_Act == 0, 2);
% 删除所有元素均为0的行
ThrFea_Act(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(FistFea_Act == 0, 2);
% 删除所有元素均为0的行
FistFea_Act(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(SecFea_Act == 0, 2);
% 删除所有元素均为0的行
SecFea_Act(rowsToDelete, :) = [];

% 找到所有元素均为0的行
rowsToDelete = all(ThrFea_Act == 0, 2);
% 删除所有元素均为0的行
ThrFea_Act(rowsToDelete, :) = [];

nurmgorup = 27;
FistFea_Tar = Func_cacluAver(FistFea_Tar,nurmgorup);
SecFea_Tar = Func_cacluAver(SecFea_Tar,nurmgorup);
ThrFea_Tar = Func_cacluAver(ThrFea_Tar,nurmgorup);
FistFea_Rst = Func_cacluAver(FistFea_Rst,nurmgorup);
SecFea_Rst = Func_cacluAver(SecFea_Rst,nurmgorup);
ThrFea_Rst = Func_cacluAver(ThrFea_Rst,nurmgorup);
FistFea_Act = Func_cacluAver(FistFea_Act,nurmgorup);
SecFea_Act = Func_cacluAver(SecFea_Act,nurmgorup);
ThrFea_Act = Func_cacluAver(ThrFea_Act,nurmgorup);

%% 画11，主频率的值，把加速度放到一起，角速度放到一起
titlesName = ["三轴加速度","三轴角速度"]
figure;
for IMUindex = 0:1
    subplot(1,2,IMUindex+1)
%     
    % 这个是画加速度的
    scatter3(FistFea_Act(:,10*6+1+IMUindex*3),FistFea_Act(:,10*6+2+IMUindex*3),FistFea_Act(:,10*6+3+IMUindex*3),'b^');
    hold on
    scatter3(SecFea_Act(:,10*6+1+IMUindex*3),SecFea_Act(:,10*6+2+IMUindex*3),SecFea_Act(:,10*6+3+IMUindex*3),'b^');
    scatter3(ThrFea_Act(:,10*6+1+IMUindex*3),ThrFea_Act(:,10*6+2+IMUindex*3),ThrFea_Act(:,10*6+3+IMUindex*3),'b^');
    
%     scatter3(FistFea_Rst(:,10*6+1+IMUindex*3),FistFea_Rst(:,10*6+2+IMUindex*3),FistFea_Rst(:,10*6+3+IMUindex*3),'gd');
%     scatter3(SecFea_Rst(:,10*6+1+IMUindex*3),SecFea_Rst(:,10*6+2+IMUindex*3),SecFea_Rst(:,10*6+3+IMUindex*3),'gd');
%     scatter3(ThrFea_Rst(:,10*6+1+IMUindex*3),ThrFea_Rst(:,10*6+2+IMUindex*3),ThrFea_Rst(:,10*6+3+IMUindex*3),'gd');
    

%     scatter3(FistFea_Tar(:,10*6+1+IMUindex*3),FistFea_Tar(:,10*6+2+IMUindex*3),FistFea_Tar(:,10*6+3+IMUindex*3),'rs');
%     scatter3(SecFea_Tar(:,10*6+1+IMUindex*3),SecFea_Tar(:,10*6+2+IMUindex*3),SecFea_Tar(:,10*6+3+IMUindex*3),'rs');
%     scatter3(ThrFea_Tar(:,10*6+1+IMUindex*3),ThrFea_Tar(:,10*6+2+IMUindex*3),ThrFea_Tar(:,10*6+3+IMUindex*3),'rs');
    xlabel('x轴');
    ylabel('y轴');
    zlabel('z轴')
    title(titlesName(IMUindex+1));
end



%% 画14，差异立方的值，把加速度放到一起，角速度放到一起
titlesName = ["三轴加速度","三轴角速度"]
figure;
for IMUindex = 0:1
    subplot(1,2,IMUindex+1)
%     
    % 这个是画加速度的
    scatter3(FistFea_Act(:,13*6+1+IMUindex*3),FistFea_Act(:,13*6+2+IMUindex*3),FistFea_Act(:,13*6+3+IMUindex*3),'b^');
    hold on    
    scatter3(FistFea_Tar(:,13*6+1+IMUindex*3),FistFea_Tar(:,13*6+2+IMUindex*3),FistFea_Tar(:,13*6+3+IMUindex*3),'rs');
    scatter3(FistFea_Rst(:,13*6+1+IMUindex*3),FistFea_Rst(:,13*6+2+IMUindex*3),FistFea_Rst(:,13*6+3+IMUindex*3),'gd');
    
    
    scatter3(SecFea_Act(:,13*6+1+IMUindex*3),SecFea_Act(:,13*6+2+IMUindex*3),SecFea_Act(:,13*6+3+IMUindex*3),'b^');
    scatter3(ThrFea_Act(:,13*6+1+IMUindex*3),ThrFea_Act(:,13*6+2+IMUindex*3),ThrFea_Act(:,13*6+3+IMUindex*3),'b^');
    
    scatter3(SecFea_Tar(:,13*6+1+IMUindex*3),SecFea_Tar(:,13*6+2+IMUindex*3),SecFea_Tar(:,13*6+3+IMUindex*3),'rs');
    scatter3(ThrFea_Tar(:,13*6+1+IMUindex*3),ThrFea_Tar(:,13*6+2+IMUindex*3),ThrFea_Tar(:,13*6+3+IMUindex*3),'rs');
    
    scatter3(SecFea_Rst(:,13*6+1+IMUindex*3),SecFea_Rst(:,13*6+2+IMUindex*3),SecFea_Rst(:,13*6+3+IMUindex*3),'gd');
    scatter3(ThrFea_Rst(:,13*6+1+IMUindex*3),ThrFea_Rst(:,13*6+2+IMUindex*3),ThrFea_Rst(:,13*6+3+IMUindex*3),'gd');
    

    xlabel('x轴');
    ylabel('y轴');
    zlabel('z轴');
    title(titlesName(IMUindex+1));
end
legend({'行动阶段', '维持阶段', '静止阶段'}, 'Location', 'best');



%%画9和10，4-6hz和6-12hz的功率强度
titlesName = ["加速度x轴","加速度Y轴","加速度Z轴","角速度x轴","角速度Y轴","角速度Z轴"];
FirV = 9;
SecV = 10;
figure;
for IMUindex = 1:6
    subplot(2,3,IMUindex)
    hold on
    plot(FistFea_Act(:,(FirV-1)*6+IMUindex),FistFea_Act(:,(SecV-1)*6+IMUindex),'b*')    
%     plot(FistFea_Tar(:,(FirV-1)*6+IMUindex),FistFea_Tar(:,(SecV-1)*6+IMUindex),'rs')
%     plot(FistFea_Rst(:,(FirV-1)*6+IMUindex),FistFea_Rst(:,(SecV-1)*6+IMUindex),'gd')

    plot(SecFea_Act(:,(FirV-1)*6+IMUindex),SecFea_Act(:,(SecV-1)*6+IMUindex),'rx')
%     plot(SecFea_Tar(:,(FirV-1)*6+IMUindex),SecFea_Tar(:,(SecV-1)*6+IMUindex),'rs')
%     plot(SecFea_Rst(:,(FirV-1)*6+IMUindex),SecFea_Rst(:,(SecV-1)*6+IMUindex),'gd')

    plot(ThrFea_Act(:,(FirV-1)*6+IMUindex),ThrFea_Act(:,(SecV-1)*6+IMUindex),'g+')
%     plot(ThrFea_Tar(:,(FirV-1)*6+IMUindex),ThrFea_Tar(:,(SecV-1)*6+IMUindex),'rs')
%     plot(ThrFea_Rst(:,(FirV-1)*6+IMUindex),ThrFea_Rst(:,(SecV-1)*6+IMUindex),'gd')
    title(titlesName(IMUindex));
    xlabel('4-6hz');
    ylabel('6-12hz');
end
% 设置图例位置
% 自定义图例内容
legend({'行动阶段', '维持阶段', '静止阶段'}, 'Location', 'best');





%% 画峰度偏度图，把三个ACT的【（12-1）*6+i；（13-1）*6+i】 i表示第几个轴
titlesName = ["加速度x轴","加速度Y轴","加速度Z轴","角速度x轴","角速度Y轴","角速度Z轴"];
figure;
for IMUindex = 1:6
    subplot(2,3,IMUindex)
    hold on
    plot(FistFea_Act(:,(12-1)*6+IMUindex),FistFea_Act(:,(13-1)*6+IMUindex),'b*')    
    plot(FistFea_Tar(:,(12-1)*6+IMUindex),FistFea_Tar(:,(13-1)*6+IMUindex),'rs')
    plot(FistFea_Rst(:,(12-1)*6+IMUindex),FistFea_Rst(:,(13-1)*6+IMUindex),'gd')

    plot(SecFea_Act(:,(12-1)*6+IMUindex),SecFea_Act(:,(13-1)*6+IMUindex),'b*')
    plot(SecFea_Tar(:,(12-1)*6+IMUindex),SecFea_Tar(:,(13-1)*6+IMUindex),'rs')
    plot(SecFea_Rst(:,(12-1)*6+IMUindex),SecFea_Rst(:,(13-1)*6+IMUindex),'gd')

    plot(ThrFea_Act(:,(12-1)*6+IMUindex),ThrFea_Act(:,(13-1)*6+IMUindex),'b*')
    plot(ThrFea_Tar(:,(12-1)*6+IMUindex),ThrFea_Tar(:,(13-1)*6+IMUindex),'rs')
    plot(ThrFea_Rst(:,(12-1)*6+IMUindex),ThrFea_Rst(:,(13-1)*6+IMUindex),'gd')
    title(titlesName(IMUindex));
    xlabel('偏度');
    ylabel('峰度');
end
% 设置图例位置
% 自定义图例内容
legend({'难度：5.67', '难度：4.14', '难度：3.22'}, 'Location', 'best');

