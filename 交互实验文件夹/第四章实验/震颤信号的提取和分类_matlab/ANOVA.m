%% 进行显著性检验文件
IMUindex = 3;
% 加速度z轴上难度5.67与难度4.14任务
data1 = FistFea_Act(:,9*6+IMUindex);
data2 = SecFea_Act(:,9*6+IMUindex);
data3 = ThrFea_Act(:,9*6+IMUindex);
% 难度5.67和难度3.22任务

% 正态性检验 服从正态分布
alpha = 0.05;  % 设置显著性水平

% Jarque-Bera检验
[~, p_value1] = jbtest(data1, alpha);
[~, p_value2] = jbtest(data2, alpha);
[~, p_value3] = jbtest(data3, alpha);

disp(['p-value for Data1: ', num2str(p_value1)]);
disp(['p-value for Data2: ', num2str(p_value2)]);
disp(['p-value for Data3: ', num2str(p_value3)]);



%% 加速度Z轴峰度显著性检验
IMUindex = 3;

data1 = [FistFea_Act(:,(13-1)*6+IMUindex);SecFea_Act(:,(13-1)*6+IMUindex);ThrFea_Act(:,(13-1)*6+IMUindex)];
data2 = [FistFea_Tar(:,(13-1)*6+IMUindex);SecFea_Tar(:,(13-1)*6+IMUindex);ThrFea_Tar(:,(13-1)*6+IMUindex)];
data3 = [FistFea_Rst(:,(13-1)*6+IMUindex);SecFea_Rst(:,(13-1)*6+IMUindex);ThrFea_Rst(:,(13-1)*6+IMUindex)];

alpha = 0.05;  % 显著性水平
% 比较Data1和Data2
[p_value12, h12,stats12] = ranksum(data1, data2, 'Alpha', alpha);
% 比较Data1和Data3
[p_value13, h13,stats13] = ranksum(data1, data3, 'Alpha', alpha);
% 比较Data2和Data3
[p_value23, h23,stats23] = ranksum(data2, data3, 'Alpha', alpha);
disp(['p-value for Data1 vs. Data2: ', num2str(p_value12)]);
disp(['Z statistic: ', num2str(stats12.zval)]);
disp(['p-value for Data1 vs. Data3: ', num2str(p_value13)]);
disp(['Z statistic: ', num2str(stats13.zval)]);
disp(['p-value for Data2 vs. Data3: ', num2str(p_value23)]);
disp(['Z statistic: ', num2str(stats23.zval)]);

%% 加速度Y轴峰度显著性检验
IMUindex = 2;

data1 = [FistFea_Act(:,(13-1)*6+IMUindex);SecFea_Act(:,(13-1)*6+IMUindex);ThrFea_Act(:,(13-1)*6+IMUindex)];
data2 = [FistFea_Tar(:,(13-1)*6+IMUindex);SecFea_Tar(:,(13-1)*6+IMUindex);ThrFea_Tar(:,(13-1)*6+IMUindex)];
data3 = [FistFea_Rst(:,(13-1)*6+IMUindex);SecFea_Rst(:,(13-1)*6+IMUindex);ThrFea_Rst(:,(13-1)*6+IMUindex)];

alpha = 0.05;  % 显著性水平
% 比较Data1和Data2
[p_value12, h12,stats12] = ranksum(data1, data2, 'Alpha', alpha);
% 比较Data1和Data3
[p_value13, h13,stats13] = ranksum(data1, data3, 'Alpha', alpha);
% 比较Data2和Data3
[p_value23, h23,stats23] = ranksum(data2, data3, 'Alpha', alpha);
disp(['p-value for Data1 vs. Data2: ', num2str(p_value12)]);
disp(['Z statistic: ', num2str(stats12.zval)]);
disp(['p-value for Data1 vs. Data3: ', num2str(p_value13)]);
disp(['Z statistic: ', num2str(stats13.zval)]);
disp(['p-value for Data2 vs. Data3: ', num2str(p_value23)]);
disp(['Z statistic: ', num2str(stats23.zval)]);


%% 用户3的显著性检验
% 要先执行FeatureDeal_singleMan
IMUindex = 2;
data1 = FistFea_Act(:,(13-1)*6+IMUindex);
data2 = SecFea_Act(:,(13-1)*6+IMUindex);
data3 = ThrFea_Act(:,(13-1)*6+IMUindex);

% 正态性检验 服从正态分布
alpha = 0.05;  % 设置显著性水平

% Jarque-Bera检验
[~, p_value1] = jbtest(data1, alpha);
[~, p_value2] = jbtest(data2, alpha);
[~, p_value3] = jbtest(data3, alpha);

disp(['p-value for Data1: ', num2str(p_value1)]);
disp(['p-value for Data2: ', num2str(p_value2)]);
disp(['p-value for Data3: ', num2str(p_value3)]);


% 进行单因素方差分析
[p, tbl, stats] = anova1([data1, data2, data3], [], 'off');

% 输出 F 值和 p 值
disp(['F值: ', num2str(tbl{2,5})]);
disp(['P值: ', num2str(p)]);