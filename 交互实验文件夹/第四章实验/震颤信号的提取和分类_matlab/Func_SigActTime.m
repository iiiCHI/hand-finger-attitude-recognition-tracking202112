%% 这个文件是探究三种交互意图运行时间有无显著差异的
clc;clear;
IatTime = zeros(3,9);
for UserId = 1:9
    disp(['UserId:',num2str(UserId)])
    % 指定CSV文件路径
    % 使用readmatrix函数读取CSV文件数据（包括表头）
    dataAction  = readmatrix(['./DataSet/UserId_',num2str(UserId),'_UserAction.csv']);
    CountFeature = 1;
    % 获取矩阵的行数
    numRows = size(dataAction, 1);
    for index = 1:numRows
    % for index = 7:7
        currentRow = dataAction(index, :);    
        if currentRow(8) == 0
            continue;
        end        
        IatTime(floor(currentRow(1)/90)+1,UserId) = IatTime(floor(currentRow(1)/90)+1,UserId)+currentRow(6)-currentRow(5);
    end
end

IatTime = IatTime/(30*1000);

%% 判断是否符合正态分布


% 生成一些样本数据（替换为你的实际数据）

data = IatTime(1,:);

% 正态分布检验
[h, p] = lillietest(data);

% 显示结果
disp(['正态分布检验的p值为: ', num2str(p)]);
disp(['H0假设是否被拒绝: ', num2str(h)]);

% 判断是否符合正态分布
if h == 0
    disp('数据符合正态分布。');
else
    disp('数据不符合正态分布。');
end


%结果均符合正态分布

% 生成一些示例数据，实际使用时请将这两行替换为你的实际数据
data1 = IatTime(2,:)';  % 样本1
data2 = IatTime(1,:)';      % 样本2

% 将数据合并为一个矩阵
data = [data1; data2;IatTime(3,:)'];

% 创建组别标签
group = [ones(length(data1), 1); 2*ones(length(data2), 1); 3*ones(length(data2), 1)];

% 进行单因素方差分析
[p, tbl, stats] = anova1(data, group, 'off'); % 'off'参数用于关闭显示ANOVA表格

% 从ANOVA表中获取F值和p值
F_value = tbl{2, 5};  % F值在ANOVA表的第2行第5列
p_value = tbl{2, 6};  % p值在ANOVA表的第2行第6列

% 显示结果
disp(['ANOVA的F值为: ', num2str(F_value)]);
disp(['ANOVA的p值为: ', num2str(p_value)]);


data1 = IatTime(1,:)';
data2 = IatTime(2,:)';
data3 = IatTime(3,:)';
% 计算每组数据的平均值
mean_data1 = mean(data1);
mean_data2 = mean(data2);
mean_data3 = mean(data3);

% 计算每组数据的样本大小
n1 = size(data1, 1);
n2 = size(data2, 1);
n3 = size(data3, 1);

% 计算总平均值
mean_total = (mean_data1 + mean_data2 + mean_data3) / 3;

% 计算组间平方和（SSB）
SSB = n1 * (mean_data1 - mean_total)^2 + n2 * (mean_data2 - mean_total)^2 + n3 * (mean_data3 - mean_total)^2;

% 合并数据以计算总平方和（SST）
all_data = [data1; data2; data3];
mean_all = mean(all_data(:));
SST = sum((all_data(:) - mean_all).^2);

% 计算效应量（Eta-squared, \(\eta^2\)）
eta_squared = SSB / SST;

% 显示结果
fprintf('组间平方和 (SSB): %.4f\n', SSB);
fprintf('总平方和 (SST): %.4f\n', SST);
fprintf('效应量 (Eta-squared, \\eta^2): %.4f\n', eta_squared);



figure;
data = [data1, data2, data3];
% 绘制箱线图
boxplot(data, 'Labels', {'高', '中', '低'});
ylabel("运行时间/s")
xlabel("用户编号 id")
disp(mean(IatTime'))



%% Zunei对比，
% 生成一些示例数据，实际使用时请将这两行替换为你的实际数据
data1 = IatTime(1,:)';  % 样本1
data2 = IatTime(3,:)';      % 样本2

% 将数据合并为一个矩阵
data = [data1; data2];

% 创建组别标签
group = [ones(length(data1), 1); 2*ones(length(data2), 1)];

% 进行单因素方差分析
[p, tbl, stats] = anova1(data, group, 'off'); % 'off'参数用于关闭显示ANOVA表格

% 从ANOVA表中获取F值和p值
F_value = tbl{2, 5};  % F值在ANOVA表的第2行第5列
p_value = tbl{2, 6};  % p值在ANOVA表的第2行第6列

% 显示结果
disp(['ANOVA的F值为: ', num2str(F_value)]);
disp(['ANOVA的p值为: ', num2str(p_value)]);

% 计算每组数据的平均值
mean_data1 = mean(data1);
mean_data2 = mean(data2);

% 计算每组数据的样本大小
n1 = size(data1, 1);
n2 = size(data2, 1);

% 计算总平均值
mean_total = (mean_data1 + mean_data2) / 2;

% 计算组间平方和（SSB）
SSB = n1 * (mean_data1 - mean_total)^2 + n2 * (mean_data2 - mean_total)^2;

% 合并数据以计算总平方和（SST）
all_data = [data1; data2];
mean_all = mean(all_data(:));
SST = sum((all_data(:) - mean_all).^2);

% 计算效应量（Eta-squared, \(\eta^2\)）
eta_squared = SSB / SST;

% 显示结果
fprintf('组间平方和 (SSB): %.4f\n', SSB);
fprintf('总平方和 (SST): %.4f\n', SST);
fprintf('效应量 (Eta-squared, \\eta^2): %.4f\n', eta_squared);

